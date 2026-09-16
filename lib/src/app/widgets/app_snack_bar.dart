import 'package:flutter/material.dart';

/// Short, non-queued feedback shared by task and backup actions.
void showAppSnackBar(
  BuildContext context,
  String message, {
  SnackBarAction? action,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.removeCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      action: action,
      duration: const Duration(seconds: 3),
      persist: false,
    ),
  );
}
