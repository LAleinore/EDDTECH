import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../data/mindcare_repository.dart';
import '../domain/chat_message_model.dart';

class MindcareChatScreen extends ConsumerStatefulWidget {
  const MindcareChatScreen({super.key});

  @override
  ConsumerState<MindcareChatScreen> createState() => _MindcareChatScreenState();
}

class _MindcareChatScreenState extends ConsumerState<MindcareChatScreen> {
  final _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageModel> _messages = [];
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    'Чувствую тревогу перед экзаменом',
    'Не могу сосредоточиться на учебе',
    'Хочу сделать дыхательное упражнение',
    'Сильно устал от учебной нагрузки',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessageModel(
        id: 'welcome',
        role: 'assistant',
        content:
            'Здравствуйте! Я ассистент эмоциональной поддержки MindCare. Здесь безопасное и безоценочное пространство. Расскажите, как вы себя чувствуете?',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
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

  Future<void> _sendMessage([String? text]) async {
    final msgText = text ?? _messageController.text.trim();
    if (msgText.isEmpty || _isLoading) return;

    if (text == null) _messageController.clear();

    final userMsg = ChatMessageModel(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: msgText,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final repo = ref.read(mindcareRepositoryProvider);
      final botReply = await repo.sendMessage(
        message: msgText,
        history: _messages,
      );

      setState(() {
        _messages.add(botReply);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.spa_rounded, color: AppColors.mindcareAccent, size: 22),
            SizedBox(width: 8),
            Text('MindCare Поддержка'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  ChatMessageModel(
                    id: 'welcome',
                    role: 'assistant',
                    content: 'Диалог обновлен. Чем я могу помочь вам сейчас?',
                    timestamp: DateTime.now(),
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Safety Disclaimer Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.mindcareAccent.withOpacity(0.08),
              child: const Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: AppColors.mindcareAccent,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'MindCare — эмоциональная поддержка, не заменяет психотерапевта.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.secondaryTextLight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg.role == 'user';

                  return Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? AppColors.primary
                            : (msg.isCrisis
                                  ? AppColors.errorLight
                                  : Theme.of(context).cardTheme.color),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isUser ? 18 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 18),
                        ),
                        border: msg.isCrisis
                            ? Border.all(color: AppColors.error, width: 1.5)
                            : Border.all(color: AppColors.dividerLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (msg.isCrisis) ...[
                            const Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: AppColors.error,
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'ЛИНИЯ СРОЧНОЙ ПОМОЩИ',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],
                          Text(
                            msg.content,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: isUser
                                  ? Colors.white
                                  : (msg.isCrisis ? AppColors.textLight : null),
                            ),
                          ),
                          if (msg.suggestedTechnique != null) ...[
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mindcareAccent,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 36),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                              onPressed: () =>
                                  context.push('/mindcare/exercises'),
                              icon: const Icon(Icons.air, size: 16),
                              label: Text(
                                msg.suggestedTechnique!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'MindCare формирует поддерживающий ответ...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryTextLight,
                      ),
                    ),
                  ],
                ),
              ),

            // Quick Prompt Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickPrompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ActionChip(
                    label: Text(
                      _quickPrompts[index],
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: AppColors.mindcareAccent.withOpacity(0.08),
                    side: BorderSide(
                      color: AppColors.mindcareAccent.withOpacity(0.3),
                    ),
                    onPressed: () => _sendMessage(_quickPrompts[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Message Input Field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Поделитесь, что у вас на душе...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: AppColors.mindcareAccent,
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
