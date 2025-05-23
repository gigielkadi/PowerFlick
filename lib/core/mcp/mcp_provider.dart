import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mcp_client.dart';
import 'mcp_server.dart';
import 'message.dart';

/// Provider for the MCP client
final mcpClientProvider = Provider<McpClient>((ref) {
  final client = McpClient();
  ref.onDispose(() {
    client.dispose();
  });
  return client;
});

/// Provider for the MCP server
final mcpServerProvider = Provider<McpServer>((ref) {
  final server = McpServer();
  ref.onDispose(() {
    server.stop();
  });
  return server;
});

/// Provider for the MCP client connection state
final mcpClientConnectionProvider = StreamProvider<bool>((ref) {
  final client = ref.watch(mcpClientProvider);
  
  // Create a stream that emits the current connection state
  // and updates when the connection state changes
  return Stream.periodic(const Duration(seconds: 1), (_) => client.isConnected)
      .distinct()
      .asBroadcastStream();
});

/// A notifier class that maintains a list of messages
class McpMessagesNotifier extends StateNotifier<List<McpMessage>> {
  McpMessagesNotifier() : super([]);
  
  void addMessage(McpMessage message) {
    // Handle different types of messages
    if (message.type == 'history_response' && message.content.containsKey('messages')) {
      final historyMessages = message.content['messages'] as List<dynamic>;
      
      final List<McpMessage> parsedMessages = [];
      for (final item in historyMessages) {
        try {
          final Map<String, dynamic> json = item as Map<String, dynamic>;
          parsedMessages.add(McpMessage.fromJson(json));
        } catch (e) {
          // Skip invalid messages
        }
      }
      
      // Add all history messages at once, preserving order
      if (parsedMessages.isNotEmpty) {
        state = [...parsedMessages, ...state];
      }
    } else {
      // Add a single message
      state = [...state, message];
    }
    
    // Keep only the last 100 messages
    if (state.length > 100) {
      state = state.sublist(state.length - 100);
    }
  }
}

/// Provider for messages received from the MCP server
final mcpMessagesProvider = StateNotifierProvider<McpMessagesNotifier, List<McpMessage>>((ref) {
  final client = ref.watch(mcpClientProvider);
  final notifier = McpMessagesNotifier();
  
  // Listen to the message stream and add messages to the notifier
  ref.listen<AsyncValue<List<McpMessage>>>(
    mcpClientMessageStreamProvider,
    (_, next) {
      next.whenData((messages) {
        if (messages.isNotEmpty) {
          final latestMessage = messages.last;
          notifier.addMessage(latestMessage);
        }
      });
    },
  );
  
  return notifier;
});

/// Provider for the raw message stream from the client
final mcpClientMessageStreamProvider = StreamProvider<List<McpMessage>>((ref) {
  final client = ref.watch(mcpClientProvider);
  final messages = <McpMessage>[];
  
  return client.messageStream.map((message) {
    messages.add(message);
    return List<McpMessage>.unmodifiable(messages);
  });
});

/// Provider for the client ID
final mcpClientIdProvider = Provider<String?>((ref) {
  final client = ref.watch(mcpClientProvider);
  return client.clientId;
});

/// Provider that returns information about connected clients (from server)
final mcpConnectedClientsProvider = StreamProvider<List<String>>((ref) {
  final server = ref.watch(mcpServerProvider);
  
  // Create a stream that emits the list of connected clients every second
  return Stream.periodic(const Duration(seconds: 1), (_) => server.connectedClients)
      .distinct(listEquals)
      .asBroadcastStream();
});

/// Helper function to compare two lists for equality
bool listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
} 