import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ai_message.dart';
import '../providers/ai_assistant_provider.dart';

/// AI Assistant screen — intelligent chat interface for dispatch operations.
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend(AiAssistantProvider provider) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    provider.sendMessage(text);
    _textController.clear();
    _scrollToBottom();

    // Scroll again after AI response arrives
    Future.delayed(const Duration(milliseconds: 900), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy, size: 24),
            SizedBox(width: 8),
            Text('AI Assistant'),
          ],
        ),
        actions: [
          Consumer<AiAssistantProvider>(
            builder: (context, ai, _) => ai.messages.length > 3
                ? IconButton(
                    icon: const Icon(Icons.delete_sweep),
                    onPressed: () => ai.clearChat(),
                    tooltip: 'Clear Chat',
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Consumer<AiAssistantProvider>(
        builder: (context, ai, _) {
          _scrollToBottom();
          return Column(
            children: [
              // Chat messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  itemCount: ai.messages.length + (ai.isProcessing ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == ai.messages.length && ai.isProcessing) {
                      return const _TypingIndicator();
                    }
                    return _MessageBubble(message: ai.messages[index]);
                  },
                ),
              ),

              // Quick suggestion chips
              _SuggestionBar(
                onSuggestionTap: (text) {
                  _textController.text = text;
                  _handleSend(ai);
                },
              ),

              const Divider(height: 1),

              // Text input
              _InputBar(
                controller: _textController,
                isProcessing: ai.isProcessing,
                onSend: () => _handleSend(ai),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AiMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final isSystem = message.role == MessageRole.system;

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.content,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 4,
          bottom: 4,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey.withAlpha(40),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : null,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.timeAgo,
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
                if (message.capability != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withAlpha(20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message.capabilityLabel,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 4, bottom: 4, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(40),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[500],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _SuggestionBar extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;

  const _SuggestionBar({required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _SuggestionChip(
              label: 'Optimize route',
              icon: Icons.map_outlined,
              onTap: () => onSuggestionTap('Optimize my route'),
            ),
            const SizedBox(width: 8),
            _SuggestionChip(
              label: 'Check HOS',
              icon: Icons.timer_outlined,
              onTap: () => onSuggestionTap('Check my hours of service'),
            ),
            const SizedBox(width: 8),
            _SuggestionChip(
              label: 'Maintenance due?',
              icon: Icons.build_outlined,
              onTap: () => onSuggestionTap('Any maintenance due?'),
            ),
            const SizedBox(width: 8),
            _SuggestionChip(
              label: 'Weather update',
              icon: Icons.cloud_outlined,
              onTap: () => onSuggestionTap('What is the weather forecast?'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onTap,
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isProcessing;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isProcessing,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Ask the AI assistant...',
                  filled: true,
                  fillColor: Colors.grey.withAlpha(20),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                enabled: !isProcessing,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: isProcessing ? null : onSend,
              icon: const Icon(Icons.send),
              color: Theme.of(context).colorScheme.primary,
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}
