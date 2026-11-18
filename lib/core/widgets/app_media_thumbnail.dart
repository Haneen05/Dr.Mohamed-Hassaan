import 'package:flutter/material.dart';

class AppMediaThumbnail extends StatelessWidget {
  const AppMediaThumbnail({
    super.key,
    required this.path,
    required this.fallbackIcon,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
    this.overlayAlpha = 0,
    this.showPlayButton = false,
    this.fallbackIconSize = 28,
  });

  final String path;
  final IconData fallbackIcon;
  final BoxFit fit;
  final double borderRadius;
  final double overlayAlpha;
  final bool showPlayButton;
  final double fallbackIconSize;

  @override
  Widget build(BuildContext context) {
    final cleanPath = path.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (cleanPath.isEmpty)
            _MediaFallback(icon: fallbackIcon, iconSize: fallbackIconSize)
          else if (cleanPath.startsWith('assets/'))
            Image.asset(
              cleanPath,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return _MediaFallback(
                  icon: fallbackIcon,
                  iconSize: fallbackIconSize,
                );
              },
            )
          else
            Image.network(
              cleanPath,
              fit: fit,
              errorBuilder: (context, error, stackTrace) {
                return _MediaFallback(
                  icon: fallbackIcon,
                  iconSize: fallbackIconSize,
                );
              },
            ),
          if (overlayAlpha > 0)
            Container(color: Colors.black.withValues(alpha: overlayAlpha)),
          if (showPlayButton)
            Center(
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.58),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MediaFallback extends StatelessWidget {
  const _MediaFallback({required this.icon, required this.iconSize});

  final IconData icon;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surfaceContainer,
      child: Center(
        child: Icon(icon, size: iconSize, color: theme.colorScheme.primary),
      ),
    );
  }
}
