// Shared reusable widgets
import 'package:flutter/material.dart';
import '../temes/app_colors.dart';
import '../temes/app_text_styles.dart';

// ── Stat Badge ────────────────────────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const StatusBadge({super.key, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label, style: AppTextStyles.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
  );
}

// ── Section Header ─────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        Text(title, style: AppTextStyles.headlineMedium),
      ],
    ),
  );
}

// ── Card Shell ─────────────────────────────────────────────────────────────────
class CardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  const CardShell({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surf(context),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.bord(context)),
        boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: child,
    ),
  );
}

// ── Page Header (back + title) ────────────────────────────────────────────────
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  const PageHeader({super.key, required this.title, this.subtitle, this.actions});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Row(
      children: [
        if (actions != null) ...actions!,
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(title, style: AppTextStyles.titleLarge),
            if (subtitle != null) Text(subtitle!, style: AppTextStyles.caption),
          ],
        ),
        SizedBox(width: 8),
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: AppColors.surfAlt(context), borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.bord(context))),
            child: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.txtSec(context)),
          ),
        ),
      ],
    ),
  );
}

// ── Green Action Button ───────────────────────────────────────────────────────
class GreenButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool outlined;
  const GreenButton({super.key, required this.label, required this.onTap, this.icon, this.outlined = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 52,
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        border: outlined ? Border.all(color: AppColors.primary, width: 1.5) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, color: outlined ? AppColors.primary : Colors.white, size: 18), const SizedBox(width: 8)],
          Text(label, style: AppTextStyles.buttonText.copyWith(color: outlined ? AppColors.primary : Colors.white)),
        ],
      ),
    ),
  );
}

// ── Circular progress ring ────────────────────────────────────────────────────
class HealthRing extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final Color color;
  final Widget? child;
  const HealthRing({super.key, required this.progress, this.size = 140, this.strokeWidth = 12, this.color = AppColors.primary, this.child});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size, height: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: size, height: size,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: strokeWidth,
            backgroundColor: AppColors.primaryLight,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            strokeCap: StrokeCap.round,
          ),
        ),
        if (child != null) child!,
      ],
    ),
  );
}
