import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/providers/data_providers.dart';
import '../../../app/widgets/app_snack_bar.dart';
import '../application/app_preferences.dart';

class TickerSettingsSection extends ConsumerStatefulWidget {
  const TickerSettingsSection({super.key});

  @override
  ConsumerState<TickerSettingsSection> createState() =>
      _TickerSettingsSectionState();
}

class _TickerSettingsSectionState extends ConsumerState<TickerSettingsSection> {
  final _form = GlobalKey<FormState>();
  final _interval = TextEditingController();
  int? _savedInterval;
  bool _saving = false;

  @override
  void dispose() {
    _interval.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final interval =
        ref.watch(futureTodoTickerIntervalSecondsProvider).value ??
        defaultFutureTodoTickerIntervalSeconds;
    final numbered = ref.watch(futureTodoTickerNumberedProvider).value ?? false;
    if (_savedInterval != interval) {
      _savedInterval = interval;
      _interval.text = '$interval';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: _form,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextFormField(
                  key: const ValueKey('ticker-interval-seconds'),
                  controller: _interval,
                  enabled: !_saving,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: strings.tickerIntervalLabel,
                    suffixText: strings.tickerSecondsUnit,
                    errorMaxLines: 3,
                  ),
                  validator: (source) {
                    final value = int.tryParse(source?.trim() ?? '');
                    return value == null ||
                            value < minimumFutureTodoTickerIntervalSeconds ||
                            value > maximumFutureTodoTickerIntervalSeconds
                        ? strings.tickerIntervalInvalid
                        : null;
                  },
                  onFieldSubmitted: (_) => _saveInterval(),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                key: const ValueKey('ticker-interval-save'),
                onPressed: _saving ? null : _saveInterval,
                icon: const Icon(Icons.save_outlined),
                label: Text(strings.save),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          strings.tickerIntervalHint,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        CheckboxListTile(
          key: const ValueKey('ticker-numbered-toggle'),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(strings.tickerNumberedLabel),
          subtitle: Text(strings.tickerNumberedHint),
          value: numbered,
          onChanged: _saving
              ? null
              : (value) {
                  if (value != null) {
                    _save(AppPreferenceKeys.futureTodoTickerNumbered, '$value');
                  }
                },
        ),
      ],
    );
  }

  Future<void> _saveInterval() async {
    if (_saving || !(_form.currentState?.validate() ?? false)) return;
    final saved = await _save(
      AppPreferenceKeys.futureTodoTickerIntervalSeconds,
      '${int.parse(_interval.text.trim())}',
    );
    if (saved && mounted) {
      showAppSnackBar(
        context,
        AppLocalizations.of(context).tickerIntervalSaved,
      );
    }
  }

  Future<bool> _save(String key, String value) async {
    if (_saving) return false;
    setState(() => _saving = true);
    try {
      await ref.read(settingsRepositoryProvider).set(key, value);
      return true;
    } on Object {
      if (mounted) {
        showAppSnackBar(
          context,
          AppLocalizations.of(context).tickerSettingsSaveFailed,
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
