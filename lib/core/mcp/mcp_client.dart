import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import 'message.dart';

/// Client for connecting to the MCP (Message Channel Proxy) server
class McpClient {
  final String host;
  final int port;
  final Logger _logger = Logger();
  WebSocketChannel? _channel;
  String? _clientId;
  bool _isConnected = false;
  
  final StreamController<McpMessage> _messageController = StreamController<McpMessage>.broadcast();
  
  /// Stream of messages received from the server
  Stream<McpMessage> get messageStream => _messageController.stream;
  
  /// Whether the client is connected to the server
  bool get isConnected => _isConnected;
  
  /// The ID assigned to this client by the server
  String? get clientId => _clientId;

  McpClient({
    this.host = 'localhost',
    this.port = 8080,
  });

  /// Connect to the MCP server
  Future<bool> connect() async {
    if (_isConnected) {
      _logger.i('Already connected to MCP server');
      return true;
    }
    
    try {
      final uri = Uri.parse('ws://$host:$port/ws');
      _channel = WebSocketChannel.connect(uri);
      
      _logger.i('Connecting to MCP server at $uri');
      
      // Listen for messages from the server
      _channel!.stream.listen(
        _handleServerMessage,
        onDone: _handleDisconnect,
        onError: (error) {
          _logger.e('WebSocket error: $error');
          _handleDisconnect();
        },
      );
      
      _isConnected = true;
      return true;
    } catch (e) {
      _logger.e('Failed to connect to MCP server: $e');
      return false;
    }
  }

  /// Handle a message from the server
  void _handleServerMessage(dynamic data) {
    try {
      final Map<String, dynamic> jsonData = jsonDecode(data);
      final message = McpMessage.fromJson(jsonData);
      
      _logger.d('Received message: ${message.type}');
      
      // Handle welcome message to set client ID
      if (message.type == 'welcome' && message.senderId == 'server') {
        _clientId = message.content['clientId'];
        _logger.i('Connected with client ID: $_clientId');
      }
      
      // Add to message stream for listeners
      _messageController.add(message);
    } catch (e) {
      _logger.e('Error processing server message: $e');
    }
  }

  /// Handle disconnection from the server
  void _handleDisconnect() {
    _isConnected = false;
    _clientId = null;
    _logger.i('Disconnected from MCP server');
    
    // Add a disconnection message to the stream
    _messageController.add(McpMessage(
      type: 'disconnected',
      senderId: 'system',
      content: {'message': 'Disconnected from server'},
    ));
  }

  /// Send a message to the server
  bool sendMessage(String type, Map<String, dynamic> content) {
    if (!_isConnected || _channel == null) {
      _logger.w('Cannot send message: not connected to server');
      return false;
    }
    
    try {
      final message = McpMessage(
        type: type,
        senderId: _clientId ?? 'unknown',
        content: content,
      );
      
      _channel!.sink.add(jsonEncode(message.toJson()));
      return true;
    } catch (e) {
      _logger.e('Error sending message: $e');
      return false;
    }
  }

  /// Send a direct message to a specific client
  bool sendDirectMessage(String targetClientId, Map<String, dynamic> content) {
    return sendMessage('direct', {
      ...content,
      'targetId': targetClientId,
    });
  }

  /// Send a broadcast message to all clients
  bool broadcastMessage(Map<String, dynamic> content) {
    return sendMessage('broadcast', content);
  }

  /// Send a ping to the server
  bool ping() {
    return sendMessage('ping', {'timestamp': DateTime.now().millisecondsSinceEpoch});
  }

  /// Fetch message history from the server
  bool fetchHistory({int limit = 100, String? type, String? senderId}) {
    return sendMessage('fetch_history', {
      'limit': limit,
      'type': type,
      'senderId': senderId,
    });
  }

  /// Fetch message history via HTTP (alternative to WebSocket method)
  Future<List<McpMessage>> fetchHistoryHttp({int limit = 100, String? type, String? senderId}) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      
      if (type != null) queryParams['type'] = type;
      if (senderId != null) queryParams['senderId'] = senderId;
      
      final uri = Uri.parse('http://$host:$port/messages').replace(queryParameters: queryParams);
      
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        throw Exception('HTTP error ${response.statusCode}: ${response.body}');
      }
      
      final jsonData = jsonDecode(response.body) as List<dynamic>;
      
      return jsonData.map((item) {
        final Map<String, dynamic> json = item as Map<String, dynamic>;
        return McpMessage.fromJson(json);
      }).toList();
    } catch (e) {
      _logger.e('Error fetching history via HTTP: $e');
      return [];
    }
  }

  /// Disconnect from the server
  Future<void> disconnect() async {
    if (_isConnected && _channel != null) {
      try {
        await _channel!.sink.close();
      } catch (e) {
        _logger.e('Error closing WebSocket: $e');
      }
    }
    
    _handleDisconnect();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await disconnect();
    await _messageController.close();
  }
} 