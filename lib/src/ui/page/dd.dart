import 'dart:io';

import 'package:flutter/material.dart';

class Screen extends StatelessWidget {
  const Screen({super.key, required this.imgPath});

  final String imgPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Image.file(File(imgPath))));
  }
}
