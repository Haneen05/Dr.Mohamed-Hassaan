import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leadingIcon,
    this.onLeadingTap,
    this.showBackButton = false,
    this.onBack,
    this.trailingIcon,
    this.onTrailingTap,
    this.trailingBadgeCount = 0,
  });

  final String title;
  final String? subtitle;

  final IconData? leadingIcon;
  final VoidCallback? onLeadingTap;

  final bool showBackButton;
  final VoidCallback? onBack;

  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final int trailingBadgeCount;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final theme = Theme.of(context);

    final displayedSubtitle =
        subtitle ?? (isArabic ? 'الشيخ الدكتور محمد حسان' : 'Islamic Scholar');

    return Row(
      children: [
        if (showBackButton && !isArabic)
          _HeaderButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap:
                onBack ??
                () {
                  Navigator.pop(context);
                },
          )
        else if (!showBackButton && leadingIcon != null)
          _LeadingButton(icon: leadingIcon!, onTap: onLeadingTap),
        if (showBackButton || leadingIcon != null) const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayedSubtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 22,
                  height: 1.3,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        if (showBackButton && isArabic) ...[
          const SizedBox(width: 10),
          _HeaderButton(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: onBack ?? () => Navigator.pop(context),
          ),
        ],
        if (trailingIcon != null) ...[
          const SizedBox(width: 10),
          _HeaderButton(
            icon: trailingIcon!,
            onTap: onTrailingTap,
            badgeCount: trailingBadgeCount,
          ),
        ],
      ],
    );
  }
}

class _LeadingButton extends StatelessWidget {
  const _LeadingButton({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: theme.colorScheme.primary, size: 23),
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, this.onTap, this.badgeCount = 0});

  final IconData icon;
  final VoidCallback? onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.colorScheme.outline),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: theme.colorScheme.primary, size: 19),
            ),
          ),
        ),
        if (badgeCount > 0)
          PositionedDirectional(
            top: -5,
            end: -5,
            child: Container(
              constraints: const BoxConstraints(minWidth: 19, minHeight: 19),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.surface, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 8,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
