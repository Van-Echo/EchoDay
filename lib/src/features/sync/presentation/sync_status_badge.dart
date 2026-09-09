import 'package:flutter/material.dart';

/// A compact, accessible indicator shared by the sync card and app shell.
class SyncStatusBadge extends StatelessWidget {
  const SyncStatusBadge({
    required this.icon,
    required this.semanticLabel,
    this.issueCount = 0,
    this.hasWarning = false,
    super.key,
  });

  final IconData icon;
  final String semanticLabel;
  final int issueCount;
  final bool hasWarning;

  @override
  Widget build(BuildContext context) {
    final child = Icon(icon);
    if (issueCount <= 0 && !hasWarning) return child;
    final badge = issueCount > 0
        ? Badge.count(count: issueCount, child: child)
        : Badge(smallSize: 8, child: child);
    return Semantics(
      label: semanticLabel,
      child: ExcludeSemantics(child: badge),
    );
  }
}
