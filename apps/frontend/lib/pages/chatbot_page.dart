// lib/pages/chatbot_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';
import '../providers/settings_provider.dart';
import '../services/gemini_service.dart';

String _t(String lang, String ar, String fr) => lang == 'fr' ? fr : ar;

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});
  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final GeminiService _gemini = GeminiService();
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_Msg> _msgs = [];
  bool _loading = false;
  bool _initialized = false;

  static const _quickAr = [
    'أفضل سماد للأرز؟',
    'كيف أعالج صدأ الفاصولياء؟',
    'احتياجات الذرة المائية؟',
    'كيف أصحح حموضة التربة؟',
    'متى أضيف سماد النيتروجين؟',
  ];

  static const _quickFr = [
    'Meilleur engrais pour le riz?',
    'Comment traiter la rouille du haricot?',
    'Besoins en eau du maïs?',
    'Comment corriger le pH du sol?',
    'Quand ajouter de l\'azote?',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      final lang = context.read<SettingsProvider>().settings.language;
      _msgs.add(_Msg(
        role: 'bot',
        text: _t(
          lang,
          'مرحباً! أنا مساعدك الزراعي الذكي 🌾\n\nيمكنني مساعدتك في:\n• تشخيص أمراض المحاصيل\n• توصيات الري والتسميد\n• إدارة التربة والحقول\n• نصائح موسمية زراعية\n\nاكتب سؤالك!',
          'Bonjour! Je suis votre assistant agricole intelligent 🌾\n\nJe peux vous aider avec:\n• Diagnostic des maladies des cultures\n• Conseils d\'irrigation et de fertilisation\n• Gestion du sol et des champs\n• Conseils agricoles saisonniers\n\nPosez votre question!',
        ),
      ));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _ctrl.text).trim();
    if (text.isEmpty || _loading) return;
    _ctrl.clear();

    setState(() {
      _msgs.add(_Msg(role: 'user', text: text));
      _loading = true;
    });
    _scrollDown();

    final response = await _gemini.ask(text);

    setState(() {
      _msgs.add(_Msg(
        role: 'bot',
        text: response.answer,
        confidence: response.confidence,
        sources: response.sources,
        isError: !response.success,
      ));
      _loading = false;
    });
    _scrollDown();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<SettingsProvider>().settings.language;
    final isRtl = lang != 'fr';
    final quick = lang == 'fr' ? _quickFr : _quickAr;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bg(context),
        appBar: AppBar(
          backgroundColor: AppColors.surf(context),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              isRtl
                  ? Icons.arrow_forward_ios_rounded
                  : Icons.arrow_back_ios_rounded,
              color: AppColors.primary,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                _t(lang, 'المساعد الزراعي', 'Assistant Agricole'),
                style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.txt(context),
                    fontWeight: FontWeight.w600),
              ),
              Row(children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text('Gemini RAG', style: AppTextStyles.caption),
              ]),
            ]),
          ]),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: AppColors.bord(context)),
          ),
        ),
        body: Column(children: [
          // ── Quick prompts ───────────────────────────────────────────
          Container(
            height: 44,
            color: AppColors.surf(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: quick.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _send(quick[i]),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Text(quick[i],
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ),
          Container(height: 1, color: AppColors.bord(context)),

          // ── Messages ────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _msgs.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _msgs.length && _loading) {
                  return _TypingBubble(lang: lang);
                }
                return _ChatBubble(msg: _msgs[i]);
              },
            ),
          ),

          // ── Input bar ───────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: BoxDecoration(
              color: AppColors.surf(context),
              border:
                  Border(top: BorderSide(color: AppColors.bord(context))),
            ),
            child: Row(children: [
              if (isRtl) ...[
                _sendButton(context),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  textDirection:
                      isRtl ? TextDirection.rtl : TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: _t(lang, 'اسأل عن محاصيلك...', 'Posez votre question...'),
                    hintStyle: AppTextStyles.bodySmall,
                    filled: true,
                    fillColor: AppColors.bg(context),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          BorderSide(color: AppColors.bord(context)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide:
                          BorderSide(color: AppColors.bord(context)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 1.5),
                    ),
                  ),
                  onSubmitted: (_) => _send(),
                  maxLines: null,
                ),
              ),
              if (!isRtl) ...[
                const SizedBox(width: 10),
                _sendButton(context),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _sendButton(BuildContext context) => GestureDetector(
        onTap: _loading ? null : _send,
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: _loading ? AppColors.textMuted : AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: _loading
                ? []
                : [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ],
          ),
          child: const Icon(Icons.send_rounded,
              color: Colors.white, size: 20),
        ),
      );
}

// ── Message model ─────────────────────────────────────────────────────────────

class _Msg {
  final String role;
  final String text;
  final double? confidence;
  final List<String>? sources;
  final bool isError;

  const _Msg({
    required this.role,
    required this.text,
    this.confidence,
    this.sources,
    this.isError = false,
  });
}

// ── Chat bubble ───────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final _Msg msg;
  const _ChatBubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.role == 'user';

    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primaryFade
                    : msg.isError
                        ? const Color(0xFFFEF2F2)
                        : AppColors.surf(context),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 4 : 18),
                  bottomRight: Radius.circular(isUser ? 18 : 4),
                ),
                border: Border.all(
                  color: isUser
                      ? AppColors.primary.withOpacity(0.2)
                      : msg.isError
                          ? AppColors.error.withOpacity(0.2)
                          : AppColors.bord(context),
                ),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.shad(context),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ],
              ),
              child: Text(
                msg.text,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isUser
                      ? AppColors.primaryDark
                      : msg.isError
                          ? AppColors.error
                          : AppColors.txt(context),
                  height: 1.55,
                ),
              ),
            ),
            if (!isUser && msg.confidence != null) ...[
              const SizedBox(height: 5),
              Row(mainAxisSize: MainAxisSize.min, children: [
                if (msg.sources != null && msg.sources!.isNotEmpty) ...[
                  Text(msg.sources!.join(' · '),
                      style: AppTextStyles.caption),
                  const SizedBox(width: 6),
                ],
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _confidenceColor(msg.confidence!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${(msg.confidence! * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Color _confidenceColor(double c) {
    if (c >= 0.7) return AppColors.success;
    if (c >= 0.4) return AppColors.warning;
    return AppColors.error;
  }
}

// ── Typing indicator ──────────────────────────────────────────────────────────

class _TypingBubble extends StatefulWidget {
  final String lang;
  const _TypingBubble({required this.lang});
  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surf(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(color: AppColors.border),
          ),
          child: FadeTransition(
            opacity: _anim,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(
                _t(widget.lang, 'يفكر...', 'En train de réfléchir...'),
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(width: 8),
              const Icon(Icons.more_horiz_rounded,
                  color: AppColors.primary, size: 18),
            ]),
          ),
        ),
      );
}