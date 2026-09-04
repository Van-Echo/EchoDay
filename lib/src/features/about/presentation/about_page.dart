import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../app/widgets/app_scaffold.dart';
import '../../../core/config/app_config.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return AppScaffold(
      selectedIndex: 4,
      title: localizations.aboutTitle,
      body: LayoutBuilder(
        builder: (context, constraints) => Stack(
          key: const ValueKey('about-content-area'),
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 64).clamp(
                      0,
                      double.infinity,
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      key: const ValueKey('about-main-content'),
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            key: const ValueKey('about-brand-logo'),
                            height: 82,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/branding/echoday_maru.png',
                                  key: const ValueKey('about-maru-logo'),
                                  width: 82,
                                  height: 82,
                                  semanticLabel: '丸 Logo',
                                  filterQuality: FilterQuality.high,
                                ),
                                const SizedBox(width: 14),
                                Image.asset(
                                  'assets/branding/echoday_cheng.png',
                                  key: const ValueKey('about-cheng-logo'),
                                  width: 82,
                                  height: 82,
                                  semanticLabel: '成 Logo',
                                  filterQuality: FilterQuality.high,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            localizations.aboutBrand,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 14),
                          Text(
                            localizations.aboutCreator,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 2,
                            children: [
                              Text(localizations.aboutWelcome),
                              _AboutLink(
                                key: const ValueKey('about-bilibili-link'),
                                icon: FontAwesomeIcons.bilibili,
                                label: localizations.supportCharging,
                                uri: _bilibiliUri,
                              ),
                              Text(localizations.aboutAnd),
                              _AboutLink(
                                key: const ValueKey('about-github-link'),
                                icon: FontAwesomeIcons.github,
                                label: localizations.bugFeedback,
                                uri: _githubUri,
                              ),
                              Text(localizations.aboutTilde),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 2,
                            children: [
                              Text(localizations.aboutLicensePrefix),
                              _AboutActionLink(
                                key: const ValueKey('about-license-link'),
                                label: localizations.aboutLicenseName,
                                onPressed: () =>
                                    _showCommunityLicenseDialog(context),
                              ),
                              Text(localizations.aboutLicenseSuffix),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            localizations.aboutPersonalUse,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            localizations.aboutCommercialUse,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 18,
              child: Text(
                localizations.aboutVersion(
                  AppConfig.version,
                  AppConfig.releaseDate,
                ),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: const Color(0xFF767171)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _bilibiliUri = Uri.parse('https://space.bilibili.com/3461572290677609');
final _githubUri = Uri.parse('https://github.com/Van-Echo');

Future<void> _showCommunityLicenseDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const _CommunityLicenseDialog(),
  );
}

class _CommunityLicenseDialog extends StatefulWidget {
  const _CommunityLicenseDialog();

  @override
  State<_CommunityLicenseDialog> createState() =>
      _CommunityLicenseDialogState();
}

class _CommunityLicenseDialogState extends State<_CommunityLicenseDialog> {
  late final Future<String> _licenseText;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _licenseText = rootBundle.loadString('LICENSE');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final viewport = MediaQuery.sizeOf(context);
    return Dialog(
      key: const ValueKey('community-license-dialog'),
      insetPadding: const EdgeInsets.all(24),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: viewport.width.clamp(0, 780).toDouble(),
        height: (viewport.height * 0.82).clamp(320, 760).toDouble(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 12, 16),
              child: Row(
                children: [
                  Icon(
                    Icons.balance_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.communityLicenseDialogTitle,
                          key: const ValueKey('community-license-dialog-title'),
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          localizations.communityLicenseDialogSubtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: localizations.close,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<String>(
                future: _licenseText,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          localizations.communityLicenseLoadFailed,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  final license = snapshot.data;
                  if (license == null) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 14),
                          Text(localizations.communityLicenseLoading),
                        ],
                      ),
                    );
                  }
                  return Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      key: const ValueKey('community-license-scroll'),
                      controller: _scrollController,
                      padding: const EdgeInsets.all(24),
                      child: SelectableText(
                        license,
                        key: const ValueKey('community-license-text'),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.65,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonal(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(localizations.close),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutActionLink extends StatelessWidget {
  const _AboutActionLink({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label),
    );
  }
}

class _AboutLink extends StatelessWidget {
  const _AboutLink({
    required this.label,
    required this.uri,
    this.icon,
    super.key,
  });

  final FaIconData? icon;
  final String label;
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    final style = TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      minimumSize: Size.zero,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
    Future<void> open() async {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).linkOpenFailed)),
        );
      }
    }

    if (icon case final icon?) {
      return TextButton.icon(
        onPressed: open,
        style: style,
        icon: FaIcon(icon, size: 16),
        label: Text(label),
      );
    }
    return TextButton(onPressed: open, style: style, child: Text(label));
  }
}
