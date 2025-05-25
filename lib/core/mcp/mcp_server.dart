import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import 'message.dart';
import 'mcp_database.dart';

/// A Message Channel Proxy server that handles WebSocket connections
/// and acts as a message relay between clients.
class McpServer {
  final int port;
  final String host;
  final Logger _logger = Logger();
  final McpDatabase _database;
  HttpServer? _server;
  final Map<String, WebSocket> _clients = {};
  final StreamController<McpMessage> _messageController = StreamController<McpMessage>.broadcast();

  /// Stream of messages that can be listened to for monitoring
  Stream<McpMessage> get messageStream => _messageController.stream;

  McpServer({
    this.port = 8080,
    this.host = 'localhost',
    String? databaseConnectionString,
  }) : _database = McpDatabase(
        connectionString: databaseConnectionString ?? 'postgresql://postgres.tcaxonikxhxpyxsrncsj:l9rS5upMT8mBMKuZ@aws-0-eu-central-1.pooler.supabase.com:5432/postgres',
      );

  /// Start the MCP server
  Future<void> start() async {
    try {
      // Try to connect to the database first
      await _database.connect();
      _logger.i('Connected to database');
      // Create tables if needed
      await _database.createTablesIfNeeded();
      
      // Start the WebSocket server
      _server = await HttpServer.bind(host, port);
      _logger.i('MCP Server started on $host:$port');
      
      _server!.listen((HttpRequest request) {
        if (request.uri.path == '/ws') {
          _handleWebSocket(request);
        } else if (request.uri.path == '/messages' && request.method == 'GET') {
          _handleMessagesRequest(request);
        } else {
          request.response
            ..statusCode = HttpStatus.notFound
            ..close();
        }
      });
    } catch (e) {
      _logger.e('Failed to start MCP server: $e');
      rethrow;
    }
  }

  /// Handle a request to retrieve messages
  void _handleMessagesRequest(HttpRequest request) async {
    if (!_database.isConnected) {
      request.response
        ..statusCode = HttpStatus.serviceUnavailable
        ..write(jsonEncode({'error': 'Database not connected'}))
        ..close();
      return;
    }
    
    try {
      final queryParams = request.uri.queryParameters;
      final limit = int.tryParse(queryParams['limit'] ?? '100') ?? 100;
      final type = queryParams['type'];
      final senderId = queryParams['senderId'];
      
      final messages = await _database.getMessages(
        limit: limit,
        type: type,
        senderId: senderId,
      );
      
      request.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode(messages))
        ..close();
    } catch (e) {
      _logger.e('Error handling messages request: $e');
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write(jsonEncode({'error': 'Failed to retrieve messages'}))
        ..close();
    }
  }

  /// Handle incoming WebSocket connections
  void _handleWebSocket(HttpRequest request) async {
    try {
      final socket = await WebSocketTransformer.upgrade(request);
      final clientId = const Uuid().v4();
      _clients[clientId] = socket;
      
      _logger.i('Client connected: $clientId');
      
      // Send welcome message to the client
      _sendToClient(clientId, McpMessage(
        type: 'welcome',
        senderId: 'server',
        content: {'clientId': clientId},
      ));
      
      // Broadcast new client connection
      _broadcastMessage(McpMessage(
        type: 'client_connected',
        senderId: 'server',
        content: {'clientId': clientId},
      ), excludeClientId: clientId);
      
      // Listen for messages from this client
      socket.listen(
        (data) => _handleClientMessage(clientId, data),
        onDone: () => _handleClientDisconnect(clientId),
        onError: (error) {
          _logger.e('Error from client $clientId: $error');
          _handleClientDisconnect(clientId);
        },
      );
    } catch (e) {
      _logger.e('Error upgrading to WebSocket: $e');
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..close();
    }
  }

  /// Handle a message from a client
  void _handleClientMessage(String clientId, dynamic data) {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(data);
      final message = McpMessage.fromJson(jsonData);
      
      // Override the sender ID with the actual client ID for security
      final verifiedMessage = message.copyWith(senderId: clientId);
      
      _logger.d('Message from $clientId: ${message.type}');
      
      // Add to message stream for monitoring
      _messageController.add(verifiedMessage);
      
      // Store the message in the database if connected
      if (_database.isConnected) {
        _database.storeMessage(verifiedMessage.toJson());
      }
      
      // Handle different message types
      switch (message.type) {
        case 'broadcast':
          _broadcastMessage(verifiedMessage);
          break;
        case 'direct':
          final targetId = message.content['targetId'];
          if (targetId != null && _clients.containsKey(targetId)) {
            _sendToClient(targetId, verifiedMessage);
          } else {
            _sendToClient(clientId, McpMessage(
              type: 'error',
              senderId: 'server',
              content: {'message': 'Client $targetId not found'},
            ));
          }
          break;
        case 'ping':
          _sendToClient(clientId, McpMessage(
            type: 'pong',
            senderId: 'server',
            content: {'timestamp': DateTime.now().millisecondsSinceEpoch},
          ));
          break;
        case 'fetch_history':
          _handleFetchHistory(clientId, message);
          break;
        default:
          // By default, broadcast the message to all clients
          _broadcastMessage(verifiedMessage);
      }
    } catch (e) {
      _logger.e('Error processing message from $clientId: $e');
      _sendToClient(clientId, McpMessage(
        type: 'error',
        senderId: 'server',
        content: {'message': 'Invalid message format'},
      ));
    }
  }

  /// Handle a fetch history request
  void _handleFetchHistory(String clientId, McpMessage message) async {
    if (!_database.isConnected) {
      _sendToClient(clientId, McpMessage(
        type: 'error',
        senderId: 'server',
        content: {'message': 'Database not connected, history not available'},
      ));
      return;
    }
    
    try {
      final limit = message.content['limit'] as int? ?? 100;
      final type = message.content['type'] as String?;
      final senderId = message.content['senderId'] as String?;
      
      final messages = await _database.getMessages(
        limit: limit,
        type: type,
        senderId: senderId,
      );
      
      _sendToClient(clientId, McpMessage(
        type: 'history_response',
        senderId: 'server',
        content: {'messages': messages},
      ));
    } catch (e) {
      _logger.e('Error fetching history: $e');
      _sendToClient(clientId, McpMessage(
        type: 'error',
        senderId: 'server',
        content: {'message': 'Failed to fetch message history'},
      ));
    }
  }

  /// Handle a client disconnection
  void _handleClientDisconnect(String clientId) {
    _clients.remove(clientId);
    _logger.i('Client disconnected: $clientId');
    
    // Broadcast client disconnection
    _broadcastMessage(McpMessage(
      type: 'client_disconnected',
      senderId: 'server',
      content: {'clientId': clientId},
    ));
  }

  /// Send a message to a specific client
  void _sendToClient(String clientId, McpMessage message) {
    final client = _clients[clientId];
    if (client != null) {
      try {
        client.add(jsonEncode(message.toJson()));
      } catch (e) {
        _logger.e('Error sending message to client $clientId: $e');
        _handleClientDisconnect(clientId);
      }
    }
  }

  /// Broadcast a message to all connected clients
  void _broadcastMessage(McpMessage message, {String? excludeClientId}) {
    for (final clientId in _clients.keys) {
      if (clientId != excludeClientId) {
        _sendToClient(clientId, message);
      }
    }
  }

  /// Send a message to all clients
  void broadcast(String type, Map<String, dynamic> content) {
    final message = McpMessage(
      type: type,
      senderId: 'server',
      content: content,
    );
    _broadcastMessage(message);
    
    // Store the message in the database if connected
    if (_database.isConnected) {
      _database.storeMessage(message.toJson());
    }
  }

  /// Send a message to a specific client
  void sendToClient(String clientId, String type, Map<String, dynamic> content) {
    final message = McpMessage(
      type: type,
      senderId: 'server',
      content: content,
    );
    _sendToClient(clientId, message);
    
    // Store the message in the database if connected
    if (_database.isConnected) {
      _database.storeMessage(message.toJson());
    }
  }

  /// Get the number of connected clients
  int get clientCount => _clients.length;

  /// Get a list of connected client IDs
  List<String> get connectedClients => _clients.keys.toList();

  /// Stop the MCP server
  Future<void> stop() async {
    for (final clientId in List.from(_clients.keys)) {
      try {
        _clients[clientId]?.close();
      } catch (e) {
        _logger.e('Error closing client $clientId: $e');
      }
    }
    _clients.clear();
    
    await _server?.close();
    await _messageController.close();
    
    // Disconnect from the database
    await _database.disconnect();
    
    _logger.i('MCP Server stopped');
  }
} 