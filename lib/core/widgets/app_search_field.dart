import 'package:flutter/material.dart';

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    required this.hint,
    this.controller,
    this.onChanged,
    this.onClear,
    this.onTap,
    this.onSubmitted,
    this.readOnly = false,
    this.autofocus = false,
    this.height = 44,
    this.borderRadius = 14,
    this.fontSize = 11.5,
    this.hintFontSize = 10.5,
    this.iconSize = 18,
    this.blurRadius = 6,
    this.shadowOffset = const Offset(0, 2),
    this.searchIconColor,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final bool autofocus;

  final double height;
  final double borderRadius;
  final double fontSize;
  final double hintFontSize;
  final double iconSize;
  final double blurRadius;
  final Offset shadowOffset;
  final Color? searchIconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: blurRadius,
            offset: shadowOffset,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        onSubmitted: onSubmitted,
        readOnly: readOnly,
        autofocus: autofocus,
        cursorColor: theme.colorScheme.primary,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: fontSize,
          color: theme.colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: hintFontSize,
            color: theme.textTheme.bodySmall?.color,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            size: iconSize,
            color: searchIconColor ?? theme.colorScheme.primary,
          ),
          suffixIcon:
              controller != null &&
                  controller!.text.isNotEmpty &&
                  onClear != null
              ? IconButton(
                  onPressed: onClear,
                  icon: Icon(
                    Icons.close_rounded,
                    size: iconSize - 3,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            vertical: (height - fontSize) / 2.6,
          ),
        ),
      ),
    );
  }
}
