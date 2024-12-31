import 'package:flutter/material.dart';

class ScreenTitle extends StatelessWidget {
  final Widget? title;

  final bool showCloseButton;

  final Alignment? screenTitleAlignment;

  final EdgeInsets? screenTitlePadding;

  const ScreenTitle({
    super.key,
    this.title,
    this.showCloseButton = false,
    this.screenTitleAlignment,
    this.screenTitlePadding,
  });

  @override
  Widget build(BuildContext context) {
    if (showCloseButton && title != null) {
      return Align(
        alignment: screenTitleAlignment ?? Alignment.topCenter,
        child: Padding(
          padding: screenTitlePadding ?? EdgeInsets.only(top: 9),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CloseButton(
                color: Colors.white,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                ),
              ), // Back button remains on the left
              Spacer(),
              title!,
              Spacer(),
              const SizedBox(width: 48),
            ],
          ),
        ),
      );
    } else if (showCloseButton == false && title != null) {
      return Align(
        alignment: screenTitleAlignment ?? Alignment.topCenter,
        child: Padding(
          padding: screenTitlePadding ?? EdgeInsets.only(top: 9 * 2),
          child: title!,
        ),
      );
    } else {
      return Align(
        alignment: screenTitleAlignment ?? Alignment.topLeft,
        child: Padding(
          padding: screenTitlePadding ?? EdgeInsets.only(top: 9),
          child: CloseButton(
            color: Colors.white,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      );
    }
  }
}
