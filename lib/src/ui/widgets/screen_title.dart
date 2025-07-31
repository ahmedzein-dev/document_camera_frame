import 'package:flutter/material.dart';

import '../../core/app_constants.dart';

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
      return SafeArea(
        child: Align(
          alignment: screenTitleAlignment ?? Alignment.topCenter,
          child: Padding(
            padding: screenTitlePadding ??
                EdgeInsets.only(top: AppConstants.screenVerticalPadding),
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
        ),
      );
    } else if (showCloseButton == false && title != null) {
      return SafeArea(
        child: Align(
          alignment: screenTitleAlignment ?? Alignment.topCenter,
          child: Padding(
            padding: screenTitlePadding ??
                EdgeInsets.only(top: AppConstants.screenVerticalPadding + 10),
            child: title!,
          ),
        ),
      );
    } else {
      return SafeArea(
        child: Align(
          alignment: screenTitleAlignment ?? Alignment.topLeft,
          child: Padding(
            padding: screenTitlePadding ??
                EdgeInsets.only(top: AppConstants.screenVerticalPadding),
            child: CloseButton(
              color: Colors.white,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      );
    }
  }
}
