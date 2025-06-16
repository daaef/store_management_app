import 'package:flutter/material.dart';
import '../colors/app_colors.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor,
    this.isLoading = false,
    this.textColor,
  });

  final String label;
  final Function()? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final buttonTextColor = textColor ?? Colors.white;
    final buttonBackgroundColor = backgroundColor ?? AppColors.primary;
    final disabledButtonBackgroundColor = Colors.grey.shade400;
    
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ).copyWith(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.disabled) && !isLoading) {
            return disabledButtonBackgroundColor;
          } else {
            return buttonBackgroundColor;
          }
        }),
        foregroundColor: MaterialStateProperty.all(buttonTextColor),
      ),
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            )
          : Text(
              label,
            ),
    );
  }
}
