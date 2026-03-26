import 'package:flutter/material.dart';

/// Animation styling configuration for DocumentCameraFrame
class DocumentCameraAnimationStyle {
  /// Duration for the capturing animation (optional).
  final Duration? capturingAnimationDuration;

  /// Color for the capturing animation (optional).
  final Color? capturingAnimationColor;

  /// Curve for the capturing animation (optional).
  final Curve? capturingAnimationCurve;

  /// Duration for the flip animation between front and back sides.
  final Duration frameFlipDuration;

  /// Curve for the flip animation between front and back sides.
  final Curve frameFlipCurve;

  const DocumentCameraAnimationStyle({
    this.capturingAnimationDuration,
    this.capturingAnimationColor,
    this.capturingAnimationCurve,
    this.frameFlipDuration = const Duration(milliseconds: 1200),
    this.frameFlipCurve = Curves.easeInOut,
  });
}

/// Frame styling configuration for DocumentCameraFrame
class DocumentCameraFrameStyle {
  /// Border radius for the outer frame.
  final double outerFrameBorderRadius;

  /// Border radius for the inner corners of the frame.
  final double innerCornerBorderRadius;

  /// Border for the displayed frame (optional).
  final BoxBorder? frameBorder;

  const DocumentCameraFrameStyle({
    this.outerFrameBorderRadius = 12,
    this.innerCornerBorderRadius = 8,
    this.frameBorder,
  });
}

/// Button styling configuration for DocumentCameraFrame
class DocumentCameraButtonStyle {
  /// Radius of the outer circle of the capture button (optional).
  final double? captureOuterCircleRadius;

  /// Radius of the inner circle of the capture button (optional).
  final double? captureInnerCircleRadius;

  /// Text for the "Capture" button (optional).
  final String? captureButtonText;

  /// Text for capture button when capturing front side (optional).
  final String? captureFrontButtonText;

  /// Text for capture button when capturing back side (optional).
  final String? captureBackButtonText;

  /// Text for the "Save" button (optional).
  final String? saveButtonText;

  /// Text for "Next" button when moving from front to back (optional).
  final String? nextButtonText;

  /// Text for "Previous" button when going back to front from back (optional).
  final String? previousButtonText;

  /// Text for the "Retake" button (optional).
  final String? retakeButtonText;

  /// Style for the "Capture" button (optional).
  final ButtonStyle? captureButtonStyle;

  /// Style for action buttons (optional).
  final ButtonStyle? actionButtonStyle;

  /// Style for the "Retake" button (optional).
  final ButtonStyle? retakeButtonStyle;

  /// Alignment of the "Capture" button (optional).
  final Alignment? captureButtonAlignment;

  /// Padding for the "Capture" button (optional).
  final EdgeInsets? captureButtonPadding;

  /// Width for the "Capture" button (optional).
  final double? captureButtonWidth;

  /// Height for the "Capture" button (optional).
  final double? captureButtonHeight;

  /// Alignment of action buttons (optional).
  final Alignment? actionButtonAlignment;

  /// Padding for action buttons (optional).
  final EdgeInsets? actionButtonPadding;

  /// Width for action buttons (optional).
  final double? actionButtonWidth;

  /// Height for action buttons (optional).
  final double? actionButtonHeight;

  /// Text style for the capture button (optional).
  final TextStyle? captureButtonTextStyle;

  /// Text style for action buttons (optional).
  final TextStyle? actionButtonTextStyle;

  /// Text style for the retake button (optional).
  final TextStyle? retakeButtonTextStyle;

  const DocumentCameraButtonStyle({
    this.captureOuterCircleRadius,
    this.captureInnerCircleRadius,
    this.captureButtonText,
    this.captureFrontButtonText,
    this.captureBackButtonText,
    this.saveButtonText,
    this.nextButtonText,
    this.previousButtonText,
    this.retakeButtonText,
    this.captureButtonStyle,
    this.actionButtonStyle,
    this.retakeButtonStyle,
    this.captureButtonAlignment,
    this.captureButtonPadding,
    this.captureButtonWidth,
    this.captureButtonHeight,
    this.actionButtonAlignment,
    this.actionButtonPadding,
    this.actionButtonWidth,
    this.actionButtonHeight,
    this.captureButtonTextStyle,
    this.actionButtonTextStyle,
    this.retakeButtonTextStyle,
  });
}

/// Title styling configuration for DocumentCameraFrame
class DocumentCameraTitleStyle {
  /// Whether to show the screen title. Defaults to `true`.
  ///
  /// Set to `false` to hide the title bar entirely in full UI mode.
  final bool showScreenTitle;

  /// Widget to display as the screen's title (optional).
  final Widget? title;

  /// Custom title for front side capture.
  /// Defaults to a white "Front Side" label.
  final Widget frontSideTitle;

  /// Custom title for back side capture.
  /// Defaults to a white "Back Side" label.
  final Widget backSideTitle;

  /// Alignment of the screen title (optional).
  final Alignment? screenTitleAlignment;

  /// Padding for the screen title (optional).
  final EdgeInsets? screenTitlePadding;

  const DocumentCameraTitleStyle({
    this.showScreenTitle = true,
    this.title,
    this.frontSideTitle = const Text(
      'Front Side',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    this.backSideTitle = const Text(
      'Back Side',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
    this.screenTitleAlignment,
    this.screenTitlePadding,
  });
}

/// Side indicator styling configuration for DocumentCameraFrame
class DocumentCameraSideIndicatorStyle {
  /// Show the side indicator.
  final bool showSideIndicator;

  /// Side indicator position from the top (optional).
  ///
  /// If null, defaults to `MediaQuery.padding.top + 80` (see `SideIndicator`).
  final double? topPosition;

  /// Side indicator position from the right (optional).
  ///
  /// If null, defaults to `20` (see `SideIndicator`).
  final double? rightPosition;

  /// Background color for the side indicator (optional).
  final Color? sideIndicatorBackgroundColor;

  /// Border color for the side indicator (optional).
  final Color? sideIndicatorBorderColor;

  /// Color for the active side indicator (optional).
  final Color? sideIndicatorActiveColor;

  /// Color for the inactive side indicator (optional).
  final Color? sideIndicatorInactiveColor;

  /// Color for the completed side indicator (optional).
  final Color? sideIndicatorCompletedColor;

  /// Text style for the side indicator (optional).
  final TextStyle? sideIndicatorTextStyle;

  const DocumentCameraSideIndicatorStyle({
    this.showSideIndicator = false,
    this.topPosition,
    this.rightPosition,
    this.sideIndicatorBackgroundColor,
    this.sideIndicatorBorderColor,
    this.sideIndicatorActiveColor,
    this.sideIndicatorInactiveColor,
    this.sideIndicatorCompletedColor,
    this.sideIndicatorTextStyle,
  });
}

/// Progress indicator styling configuration for DocumentCameraFrame
class DocumentCameraProgressStyle {
  /// Color for the progress indicator (optional).
  final Color? progressIndicatorColor;

  /// Height of the progress indicator.
  final double progressIndicatorHeight;

  const DocumentCameraProgressStyle({
    this.progressIndicatorColor,
    this.progressIndicatorHeight = 4.0,
  });
}

/// Instruction text styling configuration for DocumentCameraFrame
class DocumentCameraInstructionStyle {
  /// Show the (static) top instruction text.
  final bool showInstructionText;

  /// Instruction text for front side capture (optional).
  final String? frontSideInstruction;

  /// Instruction text for back side capture (optional).
  final String? backSideInstruction;

  /// Text style for instruction text (optional).
  final TextStyle? instructionTextStyle;

  const DocumentCameraInstructionStyle({
    this.showInstructionText = false,
    this.frontSideInstruction,
    this.backSideInstruction,
    this.instructionTextStyle,
  });

  DocumentCameraInstructionStyle copyWith({
    bool? showInstructionText,
    String? frontSideInstruction,
    String? backSideInstruction,
    TextStyle? instructionTextStyle,
  }) {
    return DocumentCameraInstructionStyle(
      showInstructionText: showInstructionText ?? this.showInstructionText,
      frontSideInstruction: frontSideInstruction ?? this.frontSideInstruction,
      backSideInstruction: backSideInstruction ?? this.backSideInstruction,
      instructionTextStyle: instructionTextStyle ?? this.instructionTextStyle,
    );
  }
}
