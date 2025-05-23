import 'dart:convert';

/// Message model for the MCP server communication
class McpMessage {
  /// Type of message (e.g., 'broadcast', 'direct', 'ping', 'pong', 'error')
  final String type;
  
  /// ID of the sender
  final String senderId;
  
  /// Message content as a map
  final Map<String, dynamic> content;
  
  /// Timestamp when the message was created
  final int timestamp;

  McpMessage({
    required this.type,
    required this.senderId,
    required this.content,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  /// Create a copy of this message with some fields replaced
  McpMessage copyWith({
    String? type,
    String? senderId,
    Map<String, dynamic>? content,
    int? timestamp,
  }) {
    return McpMessage(
      type: type ?? this.type,
      senderId: senderId ?? this.senderId,
      content: content ?? Map<String, dynamic>.from(this.content),
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Convert the message to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
    };
  }

  /// Create a message from a JSON map
  factory McpMessage.fromJson(Map<String, dynamic> json) {
    return McpMessage(
      type: json['type'] as String,
      senderId: json['senderId'] as String,
      content: json['content'] as Map<String, dynamic>,
      timestamp: json['timestamp'] as int?,
    );
  }

  /// Create a message from a JSON string
  factory McpMessage.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return McpMessage.fromJson(json);
  }

  /// Convert the message to a JSON string
  String toJsonString() {
    return jsonEncode(toJson());
  }
  
  @override
  String toString() {
    return 'McpMessage{type: $type, senderId: $senderId, timestamp: $timestamp}';
  }
} 