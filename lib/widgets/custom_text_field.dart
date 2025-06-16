import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import '../colors/app_colors.dart';
import '../text_styles/app_text_style.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    this.onSaved,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.initialValue,
    this.hintText,
    this.errorText,
    this.textAlign,
    this.labelText,
    this.style,
    this.iconData,
    this.obscureText,
    this.isFirst,
    this.isLast = false,
    this.suffixIcon,
    this.suffix,
    this.prefixIcon,
    this.prefix,
    this.inputFormatters,
    this.controller,
    this.maxLines,
    this.maxLength,
    this.textCapitalization = TextCapitalization.sentences,
    this.onFieldSubmitted,
    this.isRequired = false,
    this.readOnly = false,
    this.enabled = true,
    this.onTap,
  });

  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final String? initialValue;
  final String? hintText;
  final String? errorText;
  final TextAlign? textAlign;
  final String? labelText;
  final TextStyle? style;
  final IconData? iconData;
  final bool? obscureText;
  final bool? isFirst;
  final bool isLast;
  final Widget? suffixIcon;
  final Widget? suffix;
  final Widget? prefixIcon;
  final Widget? prefix;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController? controller;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final bool isRequired;
  final bool readOnly;
  final bool? enabled;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                labelText!,
                style: AppTextStyle.body2,
              ),
              if (enabled!)
                Text(
                  isRequired ? 'Required' : 'Optional',
                  style: AppTextStyle.caption,
                ),
            ],
          ),
        if (labelText != null) const Gap(8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType ?? TextInputType.text,
          onSaved: onSaved,
          onTap: onTap,
          onChanged: onChanged,
          validator: validator,
          initialValue: controller == null ? initialValue : null,
          style: style,
          enabled: enabled,
          readOnly: readOnly,
          textCapitalization: textCapitalization,
          obscureText: obscureText ?? false,
          textAlign: textAlign ?? TextAlign.start,
          textInputAction: isLast ? TextInputAction.go : TextInputAction.next,
          autovalidateMode: AutovalidateMode.disabled,
          inputFormatters: inputFormatters,
          onFieldSubmitted: onFieldSubmitted,
          maxLength: maxLength,
          maxLines: maxLines ?? 1,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
            focusedBorder: OutlineInputBorder(
              borderSide: enabled!
                  ? const BorderSide(
                      color: Color(0xFFE9E5E5),
                    )
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFFE9E5E5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Color(0xFFE9E5E5),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            hintText: hintText ?? '',
            filled: true,
            fillColor: Colors.white,
            suffixIcon: suffixIcon,
            suffix: suffix,
            errorText: errorText,
            prefix: prefix,
            prefixIcon: prefixIcon,
          ),
        ),
      ],
    );
  }
}
