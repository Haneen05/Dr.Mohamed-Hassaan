import 'package:flutter/material.dart';

class AuthLoadingDialogController {
  bool _isShown = false;

  void show(BuildContext context) {
    if (_isShown) {
      return;
    }

    _isShown = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;

        return Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        );
      },
    ).whenComplete(() {
      _isShown = false;
    });
  }

  void hide(BuildContext context) {
    if (!_isShown) {
      return;
    }

    _isShown = false;

    Navigator.of(context, rootNavigator: true).pop();
  }
}
