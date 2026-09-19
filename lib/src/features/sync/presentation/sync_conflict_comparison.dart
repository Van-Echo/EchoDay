import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import 'sync_conflict_description.dart';

class SyncConflictComparison extends StatelessWidget {
  const SyncConflictComparison({
    super.key,
    required this.description,
    required this.onChoose,
    this.busy = false,
  });

  final SyncConflictDescription description;
  final Future<void> Function(bool useLosingVersion) onChoose;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(description.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final version in description.versions) ...[
          Card.outlined(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    '${version.label}：【${version.summary}】',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 6),
                  SelectableText(version.details),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: busy
                          ? null
                          : () => onChoose(version.useLosingVersion),
                      child: Text(strings.syncConflictUseVersion),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
