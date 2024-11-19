import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
}

extension DoubleExtension on double {
  double get sw => this * (appContext?.screenWidth ?? 0);
  double get sh => this * (appContext?.screenHeight ?? 0);
}
extension IntExtension on int {
  double get sw => this * (appContext?.screenWidth ?? 0);
  double get sh => this * (appContext?.screenHeight ?? 0);
}


BuildContext? appContext;

class AppContextProvider extends StatelessWidget {
  final Widget child;

  const AppContextProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    appContext = context;
    return child;
  }
}
