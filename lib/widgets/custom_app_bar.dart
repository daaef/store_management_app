import 'package:flutter/material.dart';
import '../theme/text_styles/app_text_style.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final String? title;
  final Function()? onBackPressed;
  final bool showBackButton;

  const CustomAppBar({
    Key? key,
    this.actions,
    this.title,
    this.onBackPressed,
    this.showBackButton = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPop = parentRoute?.canPop ?? false;
    final bool useCloseButton =
        parentRoute is PageRoute<dynamic> && parentRoute.fullscreenDialog;
    
    return SafeArea(
      child: Container(
        color: Colors.white,
        height: preferredSize.height,
        child: NavigationToolbar(
          leading: showBackButton && canPop
              ? Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: CustomBackButton(
                    onPressed: onBackPressed,
                    icon: useCloseButton ? Icons.close : null,
                  ),
                )
              : const SizedBox(),
          middle: title != null
              ? Text(
                  title!,
                  style: AppTextStyle.headline4
                      .copyWith(fontWeight: FontWeight.w700),
                )
              : const SizedBox(),
          trailing: actions != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [...actions!],
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({
    Key? key,
    this.onPressed,
    this.icon,
  }) : super(key: key);

  final Function()? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: const IconThemeData(
        color: Colors.black,
      ),
      child: IconButton(
        onPressed: onPressed ??
            () {
              Navigator.of(context).pop();
            },
        splashRadius: 20,
        icon: Container(
          width: 40,
          height: 40,
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Center(
            child: Icon(
              icon ?? Icons.arrow_back_ios,
              color: Colors.black,
              size: 12,
            ),
          ),
        ),
      ),
    );
  }
}
