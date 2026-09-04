import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/widgets/app_scaffold.dart';
import '../../../app/widgets/feature_placeholder.dart';
import '../../../core/config/app_config.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return AppScaffold(
      selectedIndex: 4,
      title: localizations.aboutTitle,
      body: FeaturePlaceholder(
        icon: Icons.auto_awesome_outlined,
        title: localizations.aboutTitle,
        description: localizations.aboutDescription,
        child: Text(
          'v${AppConfig.version}',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ),
    );
  }
}
