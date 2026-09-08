import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<Color?> showEchoDayColorPicker({
  required BuildContext context,
  required Color initialColor,
  required String title,
  required String cancelLabel,
  required String saveLabel,
  required String hueLabel,
  required String saturationLabel,
  required String brightnessLabel,
  Key? previewKey,
}) {
  return showDialog<Color>(
    context: context,
    builder: (context) => _EchoDayColorPickerDialog(
      initialColor: initialColor,
      title: title,
      cancelLabel: cancelLabel,
      saveLabel: saveLabel,
      hueLabel: hueLabel,
      saturationLabel: saturationLabel,
      brightnessLabel: brightnessLabel,
      previewKey: previewKey,
    ),
  );
}

class _EchoDayColorPickerDialog extends StatefulWidget {
  const _EchoDayColorPickerDialog({
    required this.initialColor,
    required this.title,
    required this.cancelLabel,
    required this.saveLabel,
    required this.hueLabel,
    required this.saturationLabel,
    required this.brightnessLabel,
    this.previewKey,
  });

  final Color initialColor;
  final String title;
  final String cancelLabel;
  final String saveLabel;
  final String hueLabel;
  final String saturationLabel;
  final String brightnessLabel;
  final Key? previewKey;

  @override
  State<_EchoDayColorPickerDialog> createState() =>
      _EchoDayColorPickerDialogState();
}

class _EchoDayColorPickerDialogState extends State<_EchoDayColorPickerDialog> {
  late HSVColor _hsv;
  late final TextEditingController _hexController;
  late final TextEditingController _redController;
  late final TextEditingController _greenController;
  late final TextEditingController _blueController;

  Color get _color => _hsv.toColor().withValues(alpha: 1);

  @override
  void initState() {
    super.initState();
    _hsv = HSVColor.fromColor(widget.initialColor.withValues(alpha: 1));
    _hexController = TextEditingController();
    _redController = TextEditingController();
    _greenController = TextEditingController();
    _blueController = TextEditingController();
    _syncInputs();
  }

  @override
  void dispose() {
    _hexController.dispose();
    _redController.dispose();
    _greenController.dispose();
    _blueController.dispose();
    super.dispose();
  }

  void _syncInputs() {
    final color = _color;
    _hexController.text =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    _redController.text = '${(color.r * 255).round()}';
    _greenController.text = '${(color.g * 255).round()}';
    _blueController.text = '${(color.b * 255).round()}';
  }

  void _setHsv(HSVColor value) {
    setState(() {
      _hsv = value;
      _syncInputs();
    });
  }

  void _applyHex(String source) {
    final normalized = source.trim().replaceFirst('#', '');
    if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(normalized)) return;
    final value = int.parse(normalized, radix: 16);
    setState(() {
      _hsv = HSVColor.fromColor(Color(0xFF000000 | value));
      _redController.text = '${(_color.r * 255).round()}';
      _greenController.text = '${(_color.g * 255).round()}';
      _blueController.text = '${(_color.b * 255).round()}';
    });
  }

  void _applyRgb() {
    final red = int.tryParse(_redController.text);
    final green = int.tryParse(_greenController.text);
    final blue = int.tryParse(_blueController.text);
    if (red == null || green == null || blue == null) return;
    if (red > 255 || green > 255 || blue > 255) return;
    setState(() {
      _hsv = HSVColor.fromColor(Color.fromARGB(255, red, green, blue));
      _hexController.text =
          '#${_color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                key: widget.previewKey,
                height: 54,
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: compact ? 148 : 132,
                    child: TextField(
                      key: const ValueKey('color-hex-input'),
                      controller: _hexController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[0-9a-fA-F#]'),
                        ),
                        LengthLimitingTextInputFormatter(7),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'HEX',
                        hintText: '#RRGGBB',
                      ),
                      onChanged: _applyHex,
                    ),
                  ),
                  for (final entry in <(String, Key, TextEditingController)>[
                    ('R', const ValueKey('color-red-input'), _redController),
                    (
                      'G',
                      const ValueKey('color-green-input'),
                      _greenController,
                    ),
                    ('B', const ValueKey('color-blue-input'), _blueController),
                  ])
                    SizedBox(
                      width: compact ? 62 : 64,
                      child: TextField(
                        key: entry.$2,
                        controller: entry.$3,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        decoration: InputDecoration(labelText: entry.$1),
                        onChanged: (_) => _applyRgb(),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              _ColorSlider(
                label: widget.hueLabel,
                value: _hsv.hue,
                max: 360,
                onChanged: (value) => _setHsv(_hsv.withHue(value)),
              ),
              _ColorSlider(
                label: widget.saturationLabel,
                value: _hsv.saturation,
                onChanged: (value) => _setHsv(_hsv.withSaturation(value)),
              ),
              _ColorSlider(
                label: widget.brightnessLabel,
                value: _hsv.value,
                onChanged: (value) => _setHsv(_hsv.withValue(value)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _color),
          child: Text(widget.saveLabel),
        ),
      ],
    );
  }
}

class _ColorSlider extends StatelessWidget {
  const _ColorSlider({
    required this.label,
    required this.value,
    required this.onChanged,
    this.max = 1,
  });

  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.sizeOf(context).width < 600) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label),
          Slider(value: value, max: max, onChanged: onChanged),
        ],
      );
    }
    return Row(
      children: [
        SizedBox(width: 56, child: Text(label)),
        Expanded(
          child: Slider(value: value, max: max, onChanged: onChanged),
        ),
      ],
    );
  }
}
