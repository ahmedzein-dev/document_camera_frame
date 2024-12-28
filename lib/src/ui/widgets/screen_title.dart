import 'package:flutter/material.dart';

class ScreenTitle extends StatelessWidget {
  final Widget? title;

  final Alignment? screenTitleAlignment;

  final EdgeInsets? screenTitlePadding;
  const ScreenTitle({
    super.key,
    this.title,
    this.screenTitleAlignment,
    this.screenTitlePadding,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: screenTitleAlignment ?? Alignment.topCenter,
      child: Padding(
        padding: screenTitlePadding ?? const EdgeInsets.only(top: 56 + 18),
        child: title,
      ),
    );
  }
}
