import 'dart:math' as math;

import 'package:flutter/material.dart';

Future<TimeOfDay?> showEchoDayTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  return showDialog<TimeOfDay>(
    context: context,
    builder: (context) => _EchoDayTimePickerDialog(initialTime: initialTime),
  );
}

enum _DialMode { hour, minute }

class _EchoDayTimePickerDialog extends StatefulWidget {
  const _EchoDayTimePickerDialog({required this.initialTime});

  final TimeOfDay initialTime;

  @override
  State<_EchoDayTimePickerDialog> createState() =>
      _EchoDayTimePickerDialogState();
}

class _EchoDayTimePickerDialogState extends State<_EchoDayTimePickerDialog> {
  late int _hour;
  late int _minute;
  var _mode = _DialMode.hour;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    final material = MaterialLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final maxWidth = math.min(MediaQuery.sizeOf(context).width - 32, 520.0);
    return AlertDialog(
      key: const ValueKey('echoday-time-picker'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      title: Text(material.timePickerDialHelpText),
      content: SizedBox(
        width: maxWidth,
        height: math.min(MediaQuery.sizeOf(context).height * 0.58, 330),
        child: Row(
          children: [
            SizedBox(
              width: maxWidth < 400 ? 134 : 164,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDropdown(
                        key: const ValueKey('time-hour-dropdown'),
                        label: material.timePickerHourLabel,
                        value: _hour,
                        count: 24,
                        onChanged: (value) => setState(() {
                          _hour = value;
                          _mode = _DialMode.hour;
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Text(
                          ':',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      _buildDropdown(
                        key: const ValueKey('time-minute-dropdown'),
                        label: material.timePickerMinuteLabel,
                        value: _minute,
                        count: 60,
                        onChanged: (value) => setState(() {
                          _minute = value;
                          _mode = _DialMode.minute;
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<_DialMode>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: _DialMode.hour,
                        label: Text(material.timePickerHourLabel),
                      ),
                      ButtonSegment(
                        value: _DialMode.minute,
                        label: Text(material.timePickerMinuteLabel),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (selection) =>
                        setState(() => _mode = selection.single),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: LayoutBuilder(
                    builder: (context, constraints) => GestureDetector(
                      key: const ValueKey('time-dial'),
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (details) => _selectFromDial(
                        details.localPosition,
                        constraints.biggest,
                      ),
                      child: CustomPaint(
                        painter: _TimeDialPainter(
                          mode: _mode,
                          hour: _hour,
                          minute: _minute,
                          colorScheme: colors,
                          textStyle: Theme.of(context).textTheme.labelMedium!,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(material.cancelButtonLabel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.pop(context, TimeOfDay(hour: _hour, minute: _minute)),
          child: Text(material.okButtonLabel),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required Key key,
    required String label,
    required int value,
    required int count,
    required ValueChanged<int> onChanged,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          DropdownButton<int>(
            key: key,
            value: value,
            isExpanded: true,
            menuMaxHeight: 300,
            items: [
              for (var option = 0; option < count; option++)
                DropdownMenuItem(
                  value: option,
                  child: Text(option.toString().padLeft(2, '0')),
                ),
            ],
            onChanged: (selected) {
              if (selected != null) onChanged(selected);
            },
          ),
        ],
      ),
    );
  }

  void _selectFromDial(Offset position, Size size) {
    final center = size.center(Offset.zero);
    final delta = position - center;
    final radius = math.min(size.width, size.height) / 2;
    if (delta.distance > radius || delta.distance < radius * 0.18) return;
    var angle = math.atan2(delta.dx, -delta.dy);
    if (angle < 0) angle += math.pi * 2;
    setState(() {
      if (_mode == _DialMode.hour) {
        final slot = (angle / (math.pi * 2) * 12).round() % 12;
        final outer = delta.distance > radius * 0.64;
        _hour = outer ? (slot == 0 ? 0 : slot + 12) : (slot == 0 ? 12 : slot);
        _mode = _DialMode.minute;
      } else {
        _minute = (angle / (math.pi * 2) * 60).round() % 60;
      }
    });
  }
}

class _TimeDialPainter extends CustomPainter {
  const _TimeDialPainter({
    required this.mode,
    required this.hour,
    required this.minute,
    required this.colorScheme,
    required this.textStyle,
  });

  final _DialMode mode;
  final int hour;
  final int minute;
  final ColorScheme colorScheme;
  final TextStyle textStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = colorScheme.surfaceContainerHighest,
    );
    if (mode == _DialMode.hour) {
      for (var slot = 0; slot < 12; slot++) {
        _drawLabel(
          canvas,
          center,
          radius * 0.78,
          slot,
          slot == 0 ? 0 : 12 + slot,
        );
        _drawLabel(canvas, center, radius * 0.48, slot, slot == 0 ? 12 : slot);
      }
      final slot = hour % 12;
      final selectedRadius = hour == 0 || hour > 12
          ? radius * 0.78
          : radius * 0.48;
      _drawHand(canvas, center, selectedRadius, slot);
    } else {
      for (var slot = 0; slot < 12; slot++) {
        _drawLabel(canvas, center, radius * 0.76, slot, slot * 5, pad: true);
      }
      final angle = minute / 60 * math.pi * 2;
      final end =
          center + Offset(math.sin(angle), -math.cos(angle)) * (radius * 0.7);
      _drawHandTo(canvas, center, end);
    }
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double distance,
    int slot,
    int value, {
    bool pad = false,
  }) {
    final angle = slot / 12 * math.pi * 2;
    final point = center + Offset(math.sin(angle), -math.cos(angle)) * distance;
    final selected = mode == _DialMode.hour ? value == hour : value == minute;
    if (selected) {
      canvas.drawCircle(point, 15, Paint()..color = colorScheme.primary);
    }
    final painter = TextPainter(
      text: TextSpan(
        text: pad ? value.toString().padLeft(2, '0') : '$value',
        style: textStyle.copyWith(
          color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
          fontSize: 11,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      point - Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _drawHand(Canvas canvas, Offset center, double distance, int slot) {
    final angle = slot / 12 * math.pi * 2;
    _drawHandTo(
      canvas,
      center,
      center + Offset(math.sin(angle), -math.cos(angle)) * (distance - 15),
    );
  }

  void _drawHandTo(Canvas canvas, Offset center, Offset end) {
    canvas.drawLine(
      center,
      end,
      Paint()
        ..color = colorScheme.primary
        ..strokeWidth = 2,
    );
    canvas.drawCircle(center, 4, Paint()..color = colorScheme.primary);
  }

  @override
  bool shouldRepaint(covariant _TimeDialPainter oldDelegate) =>
      mode != oldDelegate.mode ||
      hour != oldDelegate.hour ||
      minute != oldDelegate.minute ||
      colorScheme != oldDelegate.colorScheme;
}
