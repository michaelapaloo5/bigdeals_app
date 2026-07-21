import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _msgController = TextEditingController();
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final reqRes = await ApiService.getSupportRequests();
    if (reqRes['success'] == true) {
      final requests = reqRes['requests'] as List? ?? [];
      if (requests.isNotEmpty) {
        final msgRes = await ApiService.getSupportMessages(requests[0]['id']);
        if (mounted) {
          setState(() {
            _messages = List<Map<String, dynamic>>.from(msgRes['messages'] ?? []);
            _loading = false;
          });
        }
        return;
      }
    }
    if (mounted) setState(() { _loading = false; });
  }

  Future<void> _send() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    setState(() { _sending = true; });

    final res = await ApiService.sendSupportMessage(text);
    setState(() { _sending = false; });

    if (res['success'] == true) {
      setState(() {
        _messages.add({'sender_type': 'user', 'message': text, 'created_at': DateTime.now().toString()});
        if (res['ai_reply'] != null) {
          _messages.add({'sender_type': 'ai', 'message': res['ai_reply'], 'created_at': DateTime.now().toString()});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Support Chat')),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.gold))
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.support_agent, size: 48, color: AppTheme.gold.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text('BigDeals AI Support', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            const Text('Ask anything, or type "admin" to reach a human.', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (ctx, i) => _chatBubble(_messages[i]),
                      ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(color: AppTheme.dark, border: Border(top: BorderSide(color: AppTheme.border))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sending ? null : _send,
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(color: AppTheme.gold, borderRadius: BorderRadius.circular(12)),
                    child: _sending
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.dark),
                          )
                        : const Icon(Icons.send, color: AppTheme.dark, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatBubble(Map<String, dynamic> msg) {
    final isUser = msg['sender_type'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.gold : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(14).copyWith(
            bottomRight: isUser ? const Radius.circular(4) : null,
            bottomLeft: !isUser ? const Radius.circular(4) : null,
          ),
          border: isUser ? null : Border.all(color: AppTheme.border),
        ),
        child: Text(msg['message'] ?? '', style: TextStyle(
          fontSize: 14, height: 1.4,
          color: isUser ? AppTheme.dark : AppTheme.textPrimary,
        )),
      ),
    );
  }
}
