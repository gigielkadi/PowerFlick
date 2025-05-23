import 'package:logger/logger.dart';
import 'package:postgres/postgres.dart';
import 'dart:convert';

/// Database service for the MCP server
class McpDatabase {
  final String connectionString;
  final Logger _logger = Logger();
  PostgreSQLConnection? _connection;
  bool _isConnected = false;

  /// Whether the database is connected
  bool get isConnected => _isConnected;

  McpDatabase({
    this.connectionString = 'postgresql://postgres:VIItnfHk7nPtmnQS@db.svrsdxptcuimdjtsimif.supabase.co:5432/postgres',
  });

  /// Parse the connection string into components
  Map<String, dynamic> _parseConnectionString() {
    final uri = Uri.parse(connectionString);
    return {
      'host': uri.host,
      'port': uri.port,
      'database': uri.path.replaceAll('/', ''),
      'username': uri.userInfo.split(':')[0],
      'password': uri.userInfo.split(':')[1],
    };
  }

  /// Connect to the database
  Future<bool> connect() async {
    if (_isConnected) {
      _logger.i('Already connected to database');
      return true;
    }

    try {
      final params = _parseConnectionString();
      _connection = PostgreSQLConnection(
        params['host'],
        params['port'],
        params['database'],
        username: params['username'],
        password: params['password'],
        useSSL: true,
      );

      await _connection!.open();
      _isConnected = true;
      _logger.i('Connected to database at ${params['host']}');
      return true;
    } catch (e) {
      _logger.e('Failed to connect to database: $e');
      return false;
    }
  }

  /// Disconnect from the database
  Future<void> disconnect() async {
    if (_isConnected && _connection != null) {
      await _connection!.close();
      _isConnected = false;
      _logger.i('Disconnected from database');
    }
  }

  /// Execute a query that returns rows
  Future<List<Map<String, dynamic>>> query(
    String sql, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    if (!_isConnected || _connection == null) {
      throw Exception('Not connected to database');
    }

    try {
      final results = await _connection!.mappedResultsQuery(
        sql,
        substitutionValues: substitutionValues,
      );

      // Convert the results to a simpler format
      final List<Map<String, dynamic>> mappedResults = [];
      for (final row in results) {
        final Map<String, dynamic> mappedRow = {};
        row.forEach((tableName, values) {
          mappedRow.addAll(values);
        });
        mappedResults.add(mappedRow);
      }

      return mappedResults;
    } catch (e) {
      _logger.e('Query error: $e');
      rethrow;
    }
  }

  /// Execute a query that doesn't return rows
  Future<int> execute(
    String sql, {
    Map<String, dynamic>? substitutionValues,
  }) async {
    if (!_isConnected || _connection == null) {
      throw Exception('Not connected to database');
    }

    try {
      return await _connection!.execute(
        sql,
        substitutionValues: substitutionValues,
      );
    } catch (e) {
      _logger.e('Execute error: $e');
      rethrow;
    }
  }

  /// Store a message in the database
  Future<void> storeMessage(Map<String, dynamic> message) async {
    if (!_isConnected || _connection == null) {
      _logger.w('Cannot store message: not connected to database');
      return;
    }

    try {
      await _connection!.execute(
        'INSERT INTO mcp_messages (type, sender_id, content, timestamp) VALUES (@type, @senderId, @content, @timestamp)',
        substitutionValues: {
          'type': message['type'],
          'senderId': message['senderId'],
          'content': message['content'],
          'timestamp': DateTime.fromMillisecondsSinceEpoch(message['timestamp']),
        },
      );
      _logger.d('Message stored in database');
    } catch (e) {
      _logger.e('Failed to store message: $e');
    }
  }

  /// Retrieve messages from the database
  Future<List<Map<String, dynamic>>> getMessages({
    int limit = 100,
    String? type,
    String? senderId,
  }) async {
    if (!_isConnected || _connection == null) {
      throw Exception('Not connected to database');
    }

    try {
      String sql = 'SELECT * FROM mcp_messages';
      final Map<String, dynamic> substitutionValues = {};

      final List<String> conditions = [];
      if (type != null) {
        conditions.add('type = @type');
        substitutionValues['type'] = type;
      }
      if (senderId != null) {
        conditions.add('sender_id = @senderId');
        substitutionValues['senderId'] = senderId;
      }

      if (conditions.isNotEmpty) {
        sql += ' WHERE ' + conditions.join(' AND ');
      }

      sql += ' ORDER BY timestamp DESC LIMIT @limit';
      substitutionValues['limit'] = limit;

      final results = await _connection!.mappedResultsQuery(
        sql,
        substitutionValues: substitutionValues,
      );

      // Convert the results to a simpler format
      final List<Map<String, dynamic>> messages = [];
      for (final row in results) {
        final Map<String, dynamic> message = {};
        row.forEach((tableName, values) {
          message.addAll(values);
        });
        
        // Convert timestamp to int for consistency with the rest of the app
        if (message['timestamp'] is DateTime) {
          message['timestamp'] = (message['timestamp'] as DateTime).millisecondsSinceEpoch;
        }
        
        // Convert content back to Map if it's a JSON string
        if (message['content'] is String) {
          try {
            message['content'] = jsonDecode(message['content'] as String);
          } catch (_) {
            // If it can't be parsed, keep it as a string
          }
        }
        
        messages.add(message);
      }

      return messages;
    } catch (e) {
      _logger.e('Failed to retrieve messages: $e');
      rethrow;
    }
  }

  /// Create the necessary tables if they don't exist
  Future<void> createTablesIfNeeded() async {
    if (!_isConnected || _connection == null) {
      throw Exception('Not connected to database');
    }

    try {
      // Check if the table already exists
      final tableExists = await _connection!.mappedResultsQuery(
        "SELECT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'mcp_messages')",
      );

      final exists = tableExists.first.values.first['exists'] as bool;
      if (!exists) {
        await _connection!.execute('''
          CREATE TABLE mcp_messages (
            id SERIAL PRIMARY KEY,
            type VARCHAR(50) NOT NULL,
            sender_id VARCHAR(100) NOT NULL,
            content JSONB NOT NULL,
            timestamp TIMESTAMP NOT NULL
          )
        ''');
        
        await _connection!.execute(
          'CREATE INDEX idx_mcp_messages_timestamp ON mcp_messages (timestamp DESC)',
        );
        
        await _connection!.execute(
          'CREATE INDEX idx_mcp_messages_sender_id ON mcp_messages (sender_id)',
        );
        
        await _connection!.execute(
          'CREATE INDEX idx_mcp_messages_type ON mcp_messages (type)',
        );
        
        _logger.i('Created mcp_messages table');
      }
    } catch (e) {
      _logger.e('Failed to create tables: $e');
    }
  }
} 