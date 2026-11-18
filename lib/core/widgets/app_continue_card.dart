import 'package:flutter/material.dart';

class AppContinueCard extends StatelessWidget {
  const AppContinueCard({
    super.key,
    required this.label,
    required this.title,
    required this.onTap,
    required this.leading,
    this.subtitle,
    this.meta,
    this.progress,
  });

  final String label;
  final String title;
  final String? subtitle;
  final String? meta;
  final double? progress;
  final Widget leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final normalizedProgress = progress?.clamp(0.0, 1.0);

    final foregroundColor = colorScheme.onPrimary;
    final secondaryForegroundColor = colorScheme.onPrimary.withValues(
      alpha: 0.72,
    );

    return Material(
      color: colorScheme.primary,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              SizedBox(
                width: 62,
                height: 62,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(13),
                  child: leading,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: foregroundColor,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 8.5,
                          color: secondaryForegroundColor,
                        ),
                      ),
                    ],
                    if (normalizedProgress != null) ...[
                      const SizedBox(height: 7),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: normalizedProgress,
                          minHeight: 3,
                          backgroundColor: foregroundColor.withValues(
                            alpha: 0.24,
                          ),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                    if (meta != null && meta!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        meta!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 8,
                          color: secondaryForegroundColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 13,
                color: secondaryForegroundColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
