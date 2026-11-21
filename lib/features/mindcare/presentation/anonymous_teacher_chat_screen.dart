import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/cards.dart';
import '../../../core/widgets/inputs.dart';
import '../data/anonymous_chat_repository.dart';
import '../domain/anonymous_message_model.dart';

class AnonymousTeacherChatScreen extends ConsumerStatefulWidget {
  const AnonymousTeacherChatScreen({super.key});

  @override
  ConsumerState<AnonymousTeacherChatScreen> createState() =>
      _AnonymousTeacherChatScreenState();
}

class _AnonymousTeacherChatScreenState
    extends ConsumerState<AnonymousTeacherChatScreen> {
  final _textController = TextEditingController();
  String _selectedCategory = 'Сложность с темой';
  bool _isLoading = false;

  final List<String> _categories = [
    'Сложность с темой',
    'Несправедливая оценка',
    'Перегрузка заданиями',
    'Конфликт / Буллинг',
    'Тревога перед экзаменом',
    'Личный вопрос',
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isLoading = true);
    await ref.read(anonymousChatProvider.notifier).sendStudentMessage(
          category: _selectedCategory,
          content: text,
        );

    _textController.clear();
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Обращение анонимно отправлено преподавателям школы!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(anonymousChatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Анонимный чат с учителем',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Безопасная линия связи: ваши данные скрыты',
              style: TextStyle(fontSize: 11, color: AppColors.secondaryTextLight),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Safe Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.primary, size: 24),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Полная конфиденциальность: учителя увидят ваше сообщение под анонимным номером. Пишите честно, если вас что-то тревожит или не устраивает.',
                      style: TextStyle(fontSize: 11, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            // Messages List
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.mark_chat_read_outlined,
                            size: 48,
                            color: Colors.grey.withOpacity(0.4),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Пока нет отправленных сообщений',
                            style: TextStyle(color: AppColors.secondaryTextLight),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      reverse: false,
                      itemCount: messages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        return _buildMessageCard(msg);
                      },
                    ),
            ),

            // Bottom Composer
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category Selector
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = cat == _selectedCategory;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6, bottom: 8),
                          child: ChoiceChip(
                            label: Text(cat, style: const TextStyle(fontSize: 11)),
                            selected: isSelected,
                            selectedColor: AppColors.primary.withOpacity(0.2),
                            onSelected: (_) {
                              setState(() => _selectedCategory = cat);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _textController,
                          label: 'Текст обращения',
                          hint: 'Напишите, что вас беспокоит или не устраивает...',
                          maxLines: 3,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: _isLoading ? null : _sendMessage,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.send_rounded, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(AnonymousMessageModel msg) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  msg.category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Text(
                '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 11, color: AppColors.secondaryTextLight),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            msg.content,
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 10),

          // Teacher Reply Box
          if (msg.isReplied) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded,
                          color: AppColors.success, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        msg.teacherName ?? 'Учитель-наставник',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    msg.teacherReply!,
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.warning),
                ),
                const SizedBox(width: 6),
                Text(
                  'Доставлено учителю • Ожидает ответа',
                  style: TextStyle(fontSize: 11, color: Colors.orange.shade800),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
