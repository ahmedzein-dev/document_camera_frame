import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';

enum DocumentType { idCard, passport, driverLicense }

class DocTypeInfo {
  final DocumentType type;
  final String label;
  final String subtitle;
  final IconData icon;
  final double frameWidth;
  final double frameHeight;
  final bool isTwoSided;

  const DocTypeInfo({
    required this.type,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.frameWidth,
    required this.frameHeight,
    required this.isTwoSided,
  });
}

class UiModeInfo {
  final DocumentCameraUIMode mode;
  final String label;
  final String description;
  final IconData icon;

  const UiModeInfo({
    required this.mode,
    required this.label,
    required this.description,
    required this.icon,
  });
}
