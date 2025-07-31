import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;
}

extension DoubleExtension on double {
  double sw(BuildContext? context) => this * (context?.screenWidth ?? 0);

  double sh(BuildContext? context) => this * (context?.screenHeight ?? 0);
}

extension IntExtension on int {
  double sw(BuildContext? context) => this * (context?.screenWidth ?? 0);

  double sh(BuildContext? context) => this * (context?.screenHeight ?? 0);
}
