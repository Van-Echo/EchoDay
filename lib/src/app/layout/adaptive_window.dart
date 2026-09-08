import 'package:flutter/widgets.dart';

enum AdaptiveWindowClass { compact, medium, expanded }

abstract final class AdaptiveWindow {
  static const double mediumBreakpoint = 600;
  static const double expandedBreakpoint = 840;
  static const double extendedNavigationBreakpoint = 960;

  static AdaptiveWindowClass classify(double width) {
    if (width < mediumBreakpoint) return AdaptiveWindowClass.compact;
    if (width < expandedBreakpoint) return AdaptiveWindowClass.medium;
    return AdaptiveWindowClass.expanded;
  }

  static AdaptiveWindowClass of(BuildContext context) =>
      AdaptiveWindowScope.maybeOf(context) ??
      classify(MediaQuery.sizeOf(context).width);
}

class AdaptiveWindowScope extends InheritedWidget {
  const AdaptiveWindowScope({
    required this.windowClass,
    required super.child,
    super.key,
  });

  final AdaptiveWindowClass windowClass;

  static AdaptiveWindowClass? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AdaptiveWindowScope>()
      ?.windowClass;

  @override
  bool updateShouldNotify(AdaptiveWindowScope oldWidget) =>
      windowClass != oldWidget.windowClass;
}

extension AdaptiveWindowClassX on AdaptiveWindowClass {
  bool get isCompact => this == AdaptiveWindowClass.compact;
  bool get isMedium => this == AdaptiveWindowClass.medium;
  bool get isExpanded => this == AdaptiveWindowClass.expanded;
}
