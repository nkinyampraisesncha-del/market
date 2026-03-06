import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/message_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/helpers.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MessagesScreen extends StatefulWidget {
  final String? conversationId;

  const MessagesScreen({super.key, this.conversationId});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _service = SupabaseService();
  List<ConversationModel> _conversations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversations();
    if (widget.conversationId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openConversation(widget.conversationId!);
      });
    }
  }

  Future<void> _loadConversations() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        _conversations = await _service.getConversations(user.id);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _openConversation(String conversationId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _ChatView(conversationId: conversationId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
      ),
      body: user == null
          ? EmptyStateWidget(
              title: 'Sign in to view messages',
              icon: Icons.message_outlined,
              actionLabel: 'Sign In',
              onAction: () => context.push('/login'),
            )
          : _isLoading
              ? const LoadingWidget()
              : _error != null
                  ? AppErrorWidget(message: _error!, onRetry: _loadConversations)
                  : _conversations.isEmpty
                      ? const EmptyStateWidget(
                          title: 'No messages yet',
                          message: 'Contact sellers from item listings to start chatting',
                          icon: Icons.message_outlined,
                        )
                      : RefreshIndicator(
                          onRefresh: _loadConversations,
                          child: ListView.separated(
                            itemCount: _conversations.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final conv = _conversations[i];
                              final otherName = conv.otherParticipantName(user.id);
                              return ListTile(
                                leading: CircleAvatar(child: Text(Helpers.getInitials(otherName))),
                                title: Text(otherName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text(conv.lastMessage ?? 'Start a conversation', maxLines: 1, overflow: TextOverflow.ellipsis),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (conv.lastMessageAt != null) Text(Helpers.timeAgo(conv.lastMessageAt!), style: const TextStyle(fontSize: 11)),
                                    if (conv.unreadCount > 0) ...[
                                      const SizedBox(height: 4),
                                      CircleAvatar(
                                        radius: 10,
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        child: Text('${conv.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                                      ),
                                    ],
                                  ],
                                ),
                                onTap: () => _openConversation(conv.id),
                              );
                            },
                          ),
                        ),
    );
  }
}

class _ChatView extends StatefulWidget {
  final String conversationId;
  const _ChatView({required this.conversationId});

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final _service = SupabaseService();
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<MessageModel> _messages = [];
  bool _isLoading = true;
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _subscribeToMessages();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    _channel?.unsubscribe();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _isLoading = true);
    try {
      _messages = await _service.getMessages(widget.conversationId);
    } catch (_) {}
    finally { setState(() => _isLoading = false); }
    _scrollToBottom();
  }

  void _subscribeToMessages() {
    _channel = _service.subscribeToMessages(widget.conversationId, (msg) {
      setState(() => _messages.add(msg));
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    _messageCtrl.clear();
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    try {
      await _service.sendMessage({
        'conversation_id': widget.conversationId,
        'sender_id': user.id,
        'sender_name': user.name,
        'receiver_id': '',
        'content': text,
        'message_type': 'text',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = context.watch<AuthProvider>().currentUser;

    return Column(
      children: [
        AppBar(
          title: const Text('Chat'),
          leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        ),
        Expanded(
          child: _isLoading
              ? const LoadingWidget()
              : _messages.isEmpty
                  ? const EmptyStateWidget(title: 'No messages', message: 'Send the first message!', icon: Icons.chat_bubble_outline)
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (_, i) {
                        final msg = _messages[i];
                        final isMine = msg.senderId == user?.id;
                        return Align(
                          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                            decoration: BoxDecoration(
                              color: isMine ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(msg.content, style: TextStyle(color: isMine ? Colors.white : colorScheme.onSurface)),
                                const SizedBox(height: 4),
                                Text(Helpers.timeAgo(msg.createdAt), style: TextStyle(fontSize: 10, color: isMine ? Colors.white60 : colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageCtrl,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  maxLines: null,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              FloatingActionButton.small(
                onPressed: _sendMessage,
                elevation: 0,
                child: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
