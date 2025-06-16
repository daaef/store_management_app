import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../colors/app_colors.dart';
import '../text_styles/app_text_style.dart';

class CheckboxListItem extends StatelessWidget {
  const CheckboxListItem({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.trailing,
  });

  final String label;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        child: Row(
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
            ),
            const Gap(11),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.body2,
              ),
            ),
            if (trailing != null) ...[const Gap(16), trailing!]
          ],
        ),
      ),
    );
  }
}
