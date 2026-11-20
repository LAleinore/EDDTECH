import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/services/tts_service.dart';
import '../../auth/data/auth_repository.dart';
import '../../auth/domain/user_model.dart';
import '../../mindcare/domain/chat_message_model.dart';
import '../data/assistant_repository.dart';

class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessageModel> _messages = [];
  bool _isLoading = false;
  final TtsService _ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initWelcomeMessage();
    });
  }

  void _initWelcomeMessage() {
    final user = ref.read(authNotifierProvider).user;
    final role = user?.role ?? UserRole.student;

    String text;
    if (role == UserRole.teacher) {
      text =
          'Здравствуйте! Я ваш педагогический AI-ассистент EduMind. Я могу помочь составить план урока, разработать проверочные тесты или структурировать сложную тему.';
    } else if (role == UserRole.learner) {
      text =
          'Привет! Я твой дружелюбный помощник EduMind AI. Задавай любой вопрос простыми словами, а я объясню понятно и наглядно. Ты также можешь нажать кнопку динамика, чтобы прослушать ответ!';
    } else {
      text =
          'Привет! Я твой учебный AI-ассистент EduMind. Помогу разобраться в любой теме, подготовиться к контрольной или поддержать, если накопилась усталость.';
    }

    setState(() {
      _messages.add(
        ChatMessageModel(
          id: 'assistant-welcome',
          role: 'assistant',
          content: text,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _ttsService.stop();
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

  List<String> _getQuickPrompts(UserRole role) {
    if (role == UserRole.teacher) {
      return [
        'Предложи 3 идеи для практического задания по физике',
        'Как объяснить теорему Пифагора интерактивно?',
        'Составь критерии оценивания проекта',
      ];
    } else if (role == UserRole.learner) {
      return [
        'Объясни простыми словами, что такое Солнечная система',
        'Как работает гравитация на Земле?',
        'Расскажи пошагово правило деления дробей',
      ];
    } else {
      return [
        'Как эффективно запомнить исторические даты?',
        'Объясни разницу между ДНК и РНК',
        'Помоги составить план подготовки к экзамену',
      ];
    }
  }

  Future<void> _sendMessage([String? text]) async {
    final msg = text ?? _controller.text.trim();
    if (msg.isEmpty || _isLoading) return;

    if (text == null) _controller.clear();

    final userMsg = ChatMessageModel(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      role: 'user',
      content: msg,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final user = ref.read(authNotifierProvider).user;
      final repo = ref.read(assistantRepositoryProvider);
      final reply = await repo.sendMessage(
        message: msg,
        history: _messages,
        role: user?.role ?? UserRole.student,
        language: user?.language ?? 'ru',
      );

      setState(() {
        _messages.add(reply);
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final role = user?.role ?? UserRole.student;
    final prompts = _getQuickPrompts(role);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text('AI Ассистент (${role.title})'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final m = _messages[index];
                  final isUser = m.role == 'user';

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
                            : (m.isCrisis
                                  ? AppColors.errorLight
                                  : Theme.of(context).cardTheme.color),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isUser ? 18 : 4),
                          bottomRight: Radius.circular(isUser ? 4 : 18),
                        ),
                        border: m.isCrisis
                            ? Border.all(color: AppColors.error, width: 1.5)
                            : Border.all(color: AppColors.dividerLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (m.isCrisis) ...[
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
                            m.content,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: isUser
                                  ? Colors.white
                                  : (m.isCrisis ? AppColors.textLight : null),
                            ),
                          ),
                          if (!isUser) ...[
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (m.suggestedTechnique != null &&
                                    m.suggestedTechnique!.startsWith('/'))
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      minimumSize: const Size(0, 32),
                                    ),
                                    onPressed: () =>
                                        context.push(m.suggestedTechnique!),
                                    icon: const Icon(
                                      Icons.open_in_new_rounded,
                                      size: 14,
                                    ),
                                    label: const Text(
                                      'Открыть модуль',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  )
                                else
                                  const SizedBox.shrink(),
                                IconButton(
                                  icon: const Icon(
                                    Icons.volume_up_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    _ttsService.speak(m.content);
                                  },
                                ),
                              ],
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
                      'AI генерирует ответ...',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryTextLight,
                      ),
                    ),
                  ],
                ),
              ),

            // Quick Suggestions
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: prompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ActionChip(
                    label: Text(
                      prompts[index],
                      style: const TextStyle(fontSize: 12),
                    ),
                    backgroundColor: AppColors.primary.withOpacity(0.08),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                    onPressed: () => _sendMessage(prompts[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),

            // Input Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Задайте любой вопрос AI...',
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
                    backgroundColor: AppColors.primary,
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
