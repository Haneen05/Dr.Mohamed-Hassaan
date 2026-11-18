import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/duration_formatter.dart';
import '../../../../core/widgets/app_media_thumbnail.dart';
import '../../domain/entities/sermon_entity.dart';

class SermonCard extends StatelessWidget {
  const SermonCard({super.key, required this.sermon, required this.onTap});

  final SermonEntity sermon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final title = isArabic
        ? sermon.titleArabic
        : sermon.titleEnglish.trim().isNotEmpty
        ? sermon.titleEnglish
        : sermon.titleArabic;

    final description = isArabic
        ? sermon.descriptionArabic
        : sermon.descriptionEnglish.trim().isNotEmpty
        ? sermon.descriptionEnglish
        : sermon.descriptionArabic;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 92,
                height: 69,
                child: AppMediaThumbnail(
                  path: sermon.thumbnailPath,
                  fallbackIcon: Icons.campaign_rounded,
                  borderRadius: 12,
                  overlayAlpha: 0.12,
                  showPlayButton: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        height: 1.4,
                      ),
                    ),
                    if (description.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 9,
                          height: 1.45,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (sermon.durationSeconds > 0) ...[
                      const SizedBox(height: 5),
                      Text(
                        formatDurationSeconds(sermon.durationSeconds),
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 8.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                isArabic
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
