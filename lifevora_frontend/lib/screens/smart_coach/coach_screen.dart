import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/coach_provider.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  final List<String> _suggestions = [
    '🏃 Plan pour courir 5km',
    '🥗 Plan nutrition équilibré',
    '⚖️ Comment perdre du poids?',
    '💪 Exercices pour débutant',
    '😴 Récupération après sport',
    '🧘 Programme yoga débutant',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoachProvider>().initConversation();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: Consumer<CoachProvider>(
              builder: (context, coach, _) {
                _scrollToBottom();
                return Column(
                  children: [
                    // Suggestions uniquement au début
                    if (coach.messages.length == 1)
                      _buildSuggestions(coach),
                    
                    // Liste des messages
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: coach.messages.length +
                            (coach.isTyping ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i == coach.messages.length && coach.isTyping) {
                            return _buildTypingIndicator();
                          }
                          final msg = coach.messages[i];
                          return _buildMessage(
                            msg.content,
                            msg.isUser,
                            i,
                            isLast: i == coach.messages.length - 1,
                          );
                        },
                      ),
                    ),

                    // Bouton réessayer si erreur
                    if (coach.hasError) _buildRetryButton(coach),
                  ],
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  // ─── AppBar ─────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Coach Lifevora',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Gemini AI • En ligne',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Bouton effacer la conversation
        Consumer<CoachProvider>(
          builder: (context, coach, _) => IconButton(
            onPressed: () => _showClearDialog(coach),
            icon: const Icon(
              Icons.refresh_rounded,
              color: AppColors.textSecondary,
            ),
            tooltip: 'Nouvelle conversation',
          ),
        ),
      ],
    );
  }

  // ─── Suggestions ────────────────────────────────────────────
  Widget _buildSuggestions(CoachProvider coach) {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(top: 8),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            child: GestureDetector(
              onTap: () {
                // Enlever l'emoji du début pour le message
                final text = _suggestions[i]
                    .replaceAll(RegExp(r'^[^\s]+ '), '');
                _textController.text = text;
                _sendMessage(coach);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  _suggestions[i],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Message bubble ─────────────────────────────────────────
  Widget _buildMessage(
    String content,
    bool isUser,
    int index, {
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar bot
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Bulle de message
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                content,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser ? Colors.white : AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            )
                .animate(
                  delay: Duration(milliseconds: isLast ? 0 : index * 30),
                )
                .fadeIn(duration: const Duration(milliseconds: 300))
                .slideX(
                  begin: isUser ? 0.3 : -0.3,
                  end: 0,
                  duration: const Duration(milliseconds: 300),
                ),
          ),

          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ─── Typing indicator ───────────────────────────────────────
  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🤖', style: TextStyle(fontSize: 14)),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _dot(0),
                const SizedBox(width: 4),
                _dot(200),
                const SizedBox(width: 4),
                _dot(400),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _dot(int delayMs) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .fadeIn(delay: Duration(milliseconds: delayMs))
        .then()
        .fadeOut();
  }

  // ─── Retry button ───────────────────────────────────────────
  Widget _buildRetryButton(CoachProvider coach) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () => coach.retryLastMessage(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.refresh_rounded, color: Colors.orange, size: 18),
              SizedBox(width: 8),
              Text(
                'Réessayer',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Input bar ──────────────────────────────────────────────
  Widget _buildInputBar() {
    return Consumer<CoachProvider>(
      builder: (context, coach, _) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(coach),
                    enabled: !coach.isTyping,
                    decoration: InputDecoration(
                      hintText: coach.isTyping
                          ? 'Coach en train de répondre...'
                          : 'Posez votre question...',
                      hintStyle: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Bouton envoyer
              GestureDetector(
                onTap: coach.isTyping ? null : () => _sendMessage(coach),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: coach.isTyping ? null : AppColors.primaryGradient,
                    color: coach.isTyping ? AppColors.surfaceVariant : null,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    coach.isTyping
                        ? Icons.hourglass_top_rounded
                        : Icons.send_rounded,
                    color: coach.isTyping
                        ? AppColors.textSecondary
                        : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Dialog effacer ─────────────────────────────────────────
  void _showClearDialog(CoachProvider coach) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Nouvelle conversation',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Effacer toute la conversation et recommencer?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              coach.clearConversation();
            },
            child: const Text(
              'Effacer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Envoyer ────────────────────────────────────────────────
  void _sendMessage(CoachProvider coach) {
    final text = _textController.text.trim();
    if (text.isEmpty || coach.isTyping) return;
    _textController.clear();
    _focusNode.unfocus();
    coach.sendMessage(text);
  }
}