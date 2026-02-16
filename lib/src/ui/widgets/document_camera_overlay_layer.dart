import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import '../../core/document_camera_style.dart';
import '../../core/enums.dart';
import '../../logic/document_camera_logic.dart';
import 'camera_guidance_overlay.dart';
import 'screen_title.dart';
import 'side_indicator.dart';
import 'two_sided_action_buttons.dart';
import 'two_sided_animated_frame.dart';
import 'two_sided_bottom_frame_container.dart';

/// A layer that handles all overlays, instructions, and action buttons.
class DocumentCameraOverlayLayer extends StatelessWidget {
  final DocumentCameraLogic logic;
  final DocumentCameraFrameStyle frameStyle;
  final DocumentCameraAnimationStyle animationStyle;
  final String? bottomHintText;
  final Widget? sideInfoOverlay;
  final DocumentCameraSideIndicatorStyle sideIndicatorStyle;
  final DocumentCameraProgressStyle progressStyle;
  final Animation<double>? progressAnimation;
  final bool showDetectionStatusText;
  final DocumentCameraInstructionStyle instructionStyle;
  final DocumentCameraTitleStyle titleStyle;
  final bool showCloseButton;
  final DocumentCameraButtonStyle buttonStyle;

  const DocumentCameraOverlayLayer({
    super.key,
    required this.logic,
    required this.frameStyle,
    required this.animationStyle,
    required this.bottomHintText,
    required this.sideInfoOverlay,
    required this.sideIndicatorStyle,
    required this.progressStyle,
    required this.progressAnimation,
    required this.showDetectionStatusText,
    required this.instructionStyle,
    required this.titleStyle,
    required this.showCloseButton,
    required this.buttonStyle,
  });

  Widget _buildProgressIndicator(BuildContext context) {
    if (progressAnimation == null) return const SizedBox.shrink();

    return Container(
      height: progressStyle.progressIndicatorHeight,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: progressAnimation!,
        builder: (context, child) {
          return LinearProgressIndicator(
            value: progressAnimation!.value,
            backgroundColor: Colors.white.withAlpha((0.3 * 255).toInt()),
            valueColor: AlwaysStoppedAnimation<Color>(
              progressStyle.progressIndicatorColor ??
                  Theme.of(context).primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentTitle() {
    return ValueListenableBuilder<DocumentSide>(
      valueListenable: logic.currentSideNotifier,
      builder: (context, currentSide, child) {
        Widget? currentTitle;

        if (currentSide == DocumentSide.front &&
            titleStyle.frontSideTitle != null) {
          currentTitle = titleStyle.frontSideTitle;
        } else if (currentSide == DocumentSide.back &&
            titleStyle.backSideTitle != null) {
          currentTitle = titleStyle.backSideTitle;
        } else if (titleStyle.title != null) {
          currentTitle = titleStyle.title;
        }

        return currentTitle ?? const SizedBox.shrink();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Document frame
        ValueListenableBuilder<bool>(
          valueListenable: logic.isDocumentAlignedNotifier,
          builder: (context, isAligned, child) {
            return TwoSidedAnimatedFrame(
              frameHeight: logic.updatedFrameHeight,
              frameWidth: logic.updatedFrameWidth,
              outerFrameBorderRadius: frameStyle.outerFrameBorderRadius,
              innerCornerBroderRadius: frameStyle.innerCornerBroderRadius,
              frameFlipDuration: animationStyle.frameFlipDuration,
              frameFlipCurve: animationStyle.frameFlipCurve,
              border: frameStyle.frameBorder,
              currentSideNotifier: logic.currentSideNotifier,
              isDocumentAligned: isAligned,
            );
          },
        ),

        // Bottom frame container
        TwoSidedBottomFrameContainer(
          width: logic.updatedFrameWidth,
          height: logic.updatedFrameHeight,
          borderRadius: frameStyle.outerFrameBorderRadius,
          currentSideNotifier: logic.currentSideNotifier,
          documentDataNotifier: logic.documentDataNotifier,
          bottomHintText: bottomHintText,
          sideInfoOverlay: sideInfoOverlay,
        ),

        // Progress indicator
        if (logic.requireBothSides && sideIndicatorStyle.showSideIndicator)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 0,
            right: 0,
            child: _buildProgressIndicator(context),
          ),

        // Guidance (instruction + live detection status)
        CameraGuidanceOverlay(
          showDetectionStatusText: showDetectionStatusText,
          currentSideNotifier: logic.currentSideNotifier,
          detectionStatusNotifier: logic.detectionStatusNotifier,
          instructionStyle: instructionStyle,
          top: logic.requireBothSides && sideIndicatorStyle.showSideIndicator
              ? MediaQuery.of(context).padding.top + 120
              : MediaQuery.of(context).padding.top + 60,
        ),

        // Screen title
        if (titleStyle.title != null ||
            titleStyle.frontSideTitle != null ||
            titleStyle.backSideTitle != null ||
            showCloseButton)
          ScreenTitle(
            title: _buildCurrentTitle(),
            showCloseButton: showCloseButton,
            screenTitleAlignment: titleStyle.screenTitleAlignment,
            screenTitlePadding: titleStyle.screenTitlePadding,
          ),

        // Side indicator
        if (logic.requireBothSides && sideIndicatorStyle.showSideIndicator)
          SideIndicator(
            currentSideNotifier: logic.currentSideNotifier,
            documentDataNotifier: logic.documentDataNotifier,
            rightPosition: sideIndicatorStyle.rightPosition,
            topPosition: sideIndicatorStyle.topPosition,
            backgroundColor:
                sideIndicatorStyle.sideIndicatorBackgroundColor ??
                Colors.black.withAlpha((0.8 * 255).toInt()),
            borderColor: sideIndicatorStyle.sideIndicatorBorderColor,
            activeColor:
                sideIndicatorStyle.sideIndicatorActiveColor ?? Colors.blue,
            inactiveColor:
                sideIndicatorStyle.sideIndicatorInactiveColor ?? Colors.grey,
            completedColor:
                sideIndicatorStyle.sideIndicatorCompletedColor ?? Colors.green,
            textStyle: sideIndicatorStyle.sideIndicatorTextStyle,
          ),

        // Action buttons
        TwoSidedActionButtons(
          captureOuterCircleRadius: buttonStyle.captureOuterCircleRadius,
          captureInnerCircleRadius: buttonStyle.captureInnerCircleRadius,
          captureButtonAlignment: buttonStyle.captureButtonAlignment,
          captureButtonPadding: buttonStyle.captureButtonPadding,
          captureButtonText: buttonStyle.captureButtonText,
          captureFrontButtonText: buttonStyle.captureFrontButtonText,
          captureBackButtonText: buttonStyle.captureBackButtonText,
          saveButtonText: buttonStyle.saveButtonText,
          nextButtonText: buttonStyle.nextButtonText,
          previousButtonText: buttonStyle.previousButtonText,
          retakeButtonText: buttonStyle.retakeButtonText,
          captureButtonTextStyle: buttonStyle.captureButtonTextStyle,
          actionButtonTextStyle: buttonStyle.actionButtonTextStyle,
          retakeButtonTextStyle: buttonStyle.retakeButtonTextStyle,
          captureButtonStyle: buttonStyle.captureButtonStyle,
          actionButtonStyle: buttonStyle.actionButtonStyle,
          retakeButtonStyle: buttonStyle.retakeButtonStyle,
          actionButtonPadding: buttonStyle.actionButtonPadding,
          actionButtonWidth: buttonStyle.actionButtonWidth,
          actionButtonHeight: buttonStyle.actionButtonHeight,
          captureButtonWidth: buttonStyle.captureButtonWidth,
          captureButtonHeight: buttonStyle.captureButtonHeight,
          capturedImageNotifier: logic.capturedImageNotifier,
          isLoadingNotifier: logic.isLoadingNotifier,
          currentSideNotifier: logic.currentSideNotifier,
          documentDataNotifier: logic.documentDataNotifier,
          frameWidth: logic.updatedFrameWidth,
          frameHeight: logic.updatedFrameHeight,
          bottomFrameContainerHeight: AppConstants.bottomFrameContainerHeight,
          controller: logic.controller,
          onManualCapture: logic.captureAndHandleImageUnified,
          onSave: logic.handleSave,
          onRetake: logic.handleRetake,
          onNext: logic.switchToBackSide,
          onPrevious: logic.switchToFrontSide,
          onCameraSwitched: logic.switchCamera,
          requireBothSides: logic.requireBothSides,
        ),
      ],
    );
  }
}
