import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/app_colors.dart';

class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  final List<String> _quickSuggestions = [
    'Thực đơn giảm mỡ bụng?',
    'Hôm nay tập bài gì?',
    'Tư vấn giấc ngủ',
    'Cách tăng bước chân',
  ];

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
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

  Future<void> _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    _focusNode.unfocus();
    await ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  Future<void> _handleSuggestion(String suggestion) async {
    await ref.read(chatProvider.notifier).sendMessage(suggestion);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    if (chatState.messages.isNotEmpty) _scrollToBottom();

    return Column(
      children: [
        // Danh sách tin nhắn
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: chatState.messages.length + (chatState.isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == chatState.messages.length) {
                return const TypingIndicator();
              }
              return ChatBubble(message: chatState.messages[index]);
            },
          ),
        ),

        if (chatState.errorMessage != null)
          _buildErrorBanner(chatState.errorMessage!),

        if (!chatState.isLoading) _buildQuickSuggestions(),

        _buildInputBar(),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(message,
                  style: const TextStyle(color: Colors.red, fontSize: 12))),
          GestureDetector(
            onTap: () => ref.read(chatProvider.notifier).dismissError(),
            child: const Icon(Icons.close_rounded, color: Colors.red, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestions() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _quickSuggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) => _SuggestionChip(
          label: _quickSuggestions[i],
          onTap: () => _handleSuggestion(_quickSuggestions[i]),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    final isLoading = ref.watch(chatProvider).isLoading;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.mic_none_rounded,
                color: AppColors.textSecondary),
          ),
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _focusNode,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Hỏi AI Coach điều gì đó...',
                hintStyle: const TextStyle(
                    color: AppColors.textHint, fontSize: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.cardBorder)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: AppColors.cardBorder)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(
                        color: AppColors.accent, width: 1.5)),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
              ),
              onSubmitted: (_) => _handleSend(),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: isLoading ? null : _handleSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isLoading
                    ? AppColors.accent.withValues(alpha: 0.5)
                    : AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLoading
                    ? Icons.hourglass_empty_rounded
                    : Icons.send_rounded,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
        ),
        child: Text(label,
            style: const TextStyle(
                color: AppColors.accent,
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}