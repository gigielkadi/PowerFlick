import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabler_icons/tabler_icons.dart';

import '../../../../core/mcp/mcp_provider.dart';
import '../../../../core/mcp/message.dart';

class McpPage extends ConsumerStatefulWidget {
  const McpPage({super.key});

  @override
  ConsumerState<McpPage> createState() => _McpPageState();
}

class _McpPageState extends ConsumerState<McpPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _targetClientController = TextEditingController();
  bool _isServer = false;
  String _messageType = 'broadcast';
  bool _isLoadingHistory = false;

  @override
  void dispose() {
    _messageController.dispose();
    _targetClientController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final client = ref.read(mcpClientProvider);
    if (_messageType == 'direct' && _targetClientController.text.isNotEmpty) {
      client.sendDirectMessage(_targetClientController.text, {
        'message': _messageController.text,
      });
    } else {
      client.broadcastMessage({
        'message': _messageController.text,
      });
    }

    _messageController.clear();
  }

  void _toggleServer() async {
    if (_isServer) {
      await ref.read(mcpServerProvider).stop();
    } else {
      await ref.read(mcpServerProvider).start();
    }
    setState(() {
      _isServer = !_isServer;
    });
  }

  void _toggleConnection() async {
    final client = ref.read(mcpClientProvider);
    if (client.isConnected) {
      await client.disconnect();
    } else {
      await client.connect();
    }
  }

  void _loadMessageHistory() async {
    final client = ref.read(mcpClientProvider);
    
    if (!client.isConnected) {
      _showSnackBar('Cannot load history: Not connected to server');
      return;
    }
    
    setState(() {
      _isLoadingHistory = true;
    });
    
    try {
      // This will request history via WebSocket
      client.fetchHistory(limit: 100);
      
      // Alternatively, we could use HTTP:
      /*
      final messages = await client.fetchHistoryHttp(limit: 100);
      if (messages.isNotEmpty) {
        for (final message in messages) {
          ref.read(mcpMessagesProvider.notifier).addMessage(message);
        }
      }
      */
    } catch (e) {
      _showSnackBar('Error loading history: $e');
    } finally {
      setState(() {
        _isLoadingHistory = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientConnectionState = ref.watch(mcpClientConnectionProvider);
    final messages = ref.watch(mcpMessagesProvider);
    final clientId = ref.watch(mcpClientIdProvider);
    final connectedClients = _isServer ? ref.watch(mcpConnectedClientsProvider) : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MCP Demo'),
        actions: [
          IconButton(
            onPressed: _toggleServer,
            icon: Icon(_isServer ? TablerIcons.server_off : TablerIcons.server),
            tooltip: _isServer ? 'Stop Server' : 'Start Server',
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _toggleConnection,
            icon: clientConnectionState.when(
              data: (isConnected) => Icon(
                isConnected ? TablerIcons.plug_connected : TablerIcons.plug,
                color: isConnected ? Colors.green : Colors.red,
              ),
              loading: () => const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (_, __) => const Icon(TablerIcons.plug_x, color: Colors.red),
            ),
            tooltip: clientConnectionState.when(
              data: (isConnected) => isConnected ? 'Disconnect' : 'Connect',
              loading: () => 'Loading...',
              error: (_, __) => 'Error',
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Status: '),
                    clientConnectionState.when(
                      data: (isConnected) => Text(
                        isConnected ? 'Connected' : 'Disconnected',
                        style: TextStyle(
                          color: isConnected ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      loading: () => const Text('Checking...'),
                      error: (_, __) => const Text(
                        'Error',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    const Spacer(),
                    if (clientConnectionState.maybeWhen(
                      data: (isConnected) => isConnected,
                      orElse: () => false,
                    )) ...[
                      _isLoadingHistory
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : TextButton.icon(
                              onPressed: _loadMessageHistory,
                              icon: const Icon(TablerIcons.history, size: 16),
                              label: const Text('Load History'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                    ],
                  ],
                ),
                if (clientId != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Client ID: '),
                      Expanded(
                        child: Text(
                          clientId,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(TablerIcons.copy, size: 16),
                        onPressed: () {
                          // Copy to clipboard functionality would go here
                        },
                        tooltip: 'Copy ID',
                      ),
                    ],
                  ),
                ],
                if (_isServer) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Server Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Server: '),
                      Text(
                        'Running on localhost:8080',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Database: '),
                      Text(
                        'Connected to PostgreSQL',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Connected Clients:'),
                  connectedClients?.when(
                    data: (clients) => clients.isEmpty
                        ? const Text('No clients connected')
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: clients
                                .map((clientId) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                                      child: Text('• $clientId'),
                                    ))
                                .toList(),
                          ),
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const Text('Error fetching clients'),
                  ) ?? const Text('Loading...'),
                ],
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No messages yet'),
                        const SizedBox(height: 16),
                        if (clientConnectionState.maybeWhen(
                          data: (isConnected) => isConnected,
                          orElse: () => false,
                        )) ...[
                          ElevatedButton.icon(
                            onPressed: _loadMessageHistory,
                            icon: const Icon(TablerIcons.history),
                            label: const Text('Load Message History'),
                          ),
                        ],
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: messages.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return _buildMessageTile(message, clientId);
                    },
                  ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _messageType,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'broadcast',
                            child: Text('Broadcast'),
                          ),
                          DropdownMenuItem(
                            value: 'direct',
                            child: Text('Direct Message'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _messageType = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                if (_messageType == 'direct') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _targetClientController,
                    decoration: const InputDecoration(
                      labelText: 'Target Client ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(TablerIcons.send),
                      tooltip: 'Send',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(McpMessage message, String? currentClientId) {
    final isFromMe = message.senderId == currentClientId;
    final isFromServer = message.senderId == 'server';
    final isSystem = message.senderId == 'system';
    final isHistoryResponse = message.type == 'history_response';

    Color? bgColor;
    if (isFromMe) {
      bgColor = Colors.blue.withOpacity(0.1);
    } else if (isFromServer) {
      bgColor = Colors.green.withOpacity(0.1);
    } else if (isSystem) {
      bgColor = Colors.orange.withOpacity(0.1);
    } else if (isHistoryResponse) {
      bgColor = Colors.purple.withOpacity(0.1);
    }

    String displayText = '';
    if (message.content.containsKey('message')) {
      displayText = message.content['message'];
    } else if (isHistoryResponse && message.content.containsKey('messages')) {
      final messages = message.content['messages'] as List<dynamic>;
      displayText = 'Loaded ${messages.length} messages from history';
    } else {
      displayText = message.content.toString();
    }

    // Format the timestamp
    final dateTime = DateTime.fromMillisecondsSinceEpoch(message.timestamp);
    final formattedTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    return Card(
      color: bgColor,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isFromMe
                      ? 'You'
                      : isFromServer
                          ? 'Server'
                          : isSystem
                              ? 'System'
                              : 'Client ${message.senderId}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  formattedTime,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              displayText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (message.type == 'direct') ...[
              const SizedBox(height: 4),
              Text(
                'Direct message ${isFromMe ? 'to' : 'from'} ${message.content['targetId'] ?? 'unknown'}',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 