import 'package:flutter/material.dart';
import 'custom_text_field.dart';

class TimePickerWidget extends StatefulWidget {
  const TimePickerWidget({
    super.key,
    required this.onTimePicked,
    required this.label,
    this.initialValue,
  });

  final ValueChanged<String> onTimePicked;
  final String label;
  final String? initialValue;

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  final controller = TextEditingController();

  @override
  void initState() {
    if (widget.initialValue != null) {
      controller.text = widget.initialValue!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: controller,
      labelText: widget.label,
      isRequired: true,
      onTap: () async {
        var text = '';
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          text = time.format(context);
        }

        controller.text = text;
        widget.onTimePicked.call(text);
      },
      readOnly: true,
    );
  }
}
