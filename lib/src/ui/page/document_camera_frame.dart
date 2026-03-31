import 'package:flutter/material.dart';

import '../../../document_camera_frame.dart';
import '../../logic/document_camera_logic.dart';
import '../widgets/document_camera_preview_layer.dart';
import '../widgets/document_camera_overlay_layer.dart';

/// A customizable camera view for capturing both sides of document images.
///
/// This widget provides a predefined frame for document capture,
/// with support for capturing front and back sides of documents.
class DocumentCameraFrame extends StatefulWidget {
  /// Width of the document capture frame.
  final double frameWidth;

  /// Height of the document capture frame.
  final double frameHeight;

  /// Animation styling configuration
  final DocumentCameraAnimationStyle animationStyle;

  /// Frame styling configuration
  final DocumentCameraFrameStyle frameStyle;

  /// Button styling configuration
  final DocumentCameraButtonStyle buttonStyle;

  /// Title styling configuration
  final DocumentCameraTitleStyle titleStyle;

  /// Side indicator styling configuration
  final DocumentCameraSideIndicatorStyle sideIndicatorStyle;

  /// Progress indicator styling configuration
  final DocumentCameraProgressStyle progressStyle;

  /// Instruction text styling configuration
  final DocumentCameraInstructionStyle instructionStyle;

  /// Callback triggered when front side is captured.
  final Function(String imgPath)? onFrontCaptured;

  /// Callback triggered when back side is captured.
  final Function(String imgPath)? onBackCaptured;

  /// Callback triggered when document capture is saved (one side e.g. passport, or both sides).
  final Function(DocumentCaptureData documentData)? onDocumentSaved;

  /// Deprecated. Use [onDocumentSaved] instead.
  @Deprecated(
    'Use onDocumentSaved instead (works for one-sided and two-sided documents)',
  )
  final Function(DocumentCaptureData documentData)? onBothSidesSaved;

  /// When true, runs on-device OCR and includes [DocumentCaptureData.frontOcrText] and
  /// [DocumentCaptureData.backOcrText] in the callback result.
  final bool enableExtractText;

  /// Callback triggered when the "Retake" button is pressed.
  final VoidCallback? onRetake;

  /// Bottom container customization
  final Widget? bottomFrameContainerChild;

  /// Show close button
  final bool showCloseButton;

  /// Camera index
  final int? cameraIndex;

  /// Whether to require both sides (if false, can save with just front side)
  final bool requireBothSides;

  /// Optional bottom hint text shown in the bottom container.
  final String? bottomHintText;

  /// Optional widget shown on the right (e.g. a check icon).
  final Widget? sideInfoOverlay;

  /// Enables automatic capture when a document is aligned in the frame.
  final bool enableAutoCapture;

  /// Show the (dynamic) live detection status text (e.g. "Move closer").
  ///
  /// Has effect only when auto-capture is enabled and detection is running.
  final bool showDetectionStatusText;

  /// Callback triggered when a camera-related error occurs (e.g., initialization, streaming, or capture failure).
  final void Function(Object error)? onCameraError;

  /// Output format for captured documents (default: JPG for backward compatibility)
  final DocumentOutputFormat outputFormat;

  /// PDF page size when outputFormat is PDF (default: A4)
  final PdfPageSize pdfPageSize;

  /// Image quality for lossy formats like JPG and WebP (1-100, default: 90)
  final int imageQuality;

  /// Initial flash mode for the camera (default: FlashMode.auto)
  final FlashMode initialFlashMode;

  /// Controls which UI elements are rendered.
  ///
  /// - [DocumentCameraUIMode.defaultMode] (default): full UI.
  /// - [DocumentCameraUIMode.minimal]: camera preview + four corner indicators only.
  /// - [DocumentCameraUIMode.overlay]: full UI but without the dark cutout overlay,
  ///   side indicator and instructions are hidden.
  /// - [DocumentCameraUIMode.kiosk]: full UI but all action buttons are hidden.
  /// - [DocumentCameraUIMode.guided]: full UI with a pulsing frame border.
  /// - [DocumentCameraUIMode.textExtract]: like [DocumentCameraUIMode.defaultMode]
  ///   but with on-device OCR automatically enabled.
  final DocumentCameraUIMode uiMode;

  /// Constructor for the [DocumentCameraFrame].
  const DocumentCameraFrame({
    super.key,
    required this.frameWidth,
    required this.frameHeight,
    this.animationStyle = const DocumentCameraAnimationStyle(),
    this.frameStyle = const DocumentCameraFrameStyle(),
    this.buttonStyle = const DocumentCameraButtonStyle(),
    this.titleStyle = const DocumentCameraTitleStyle(),
    this.sideIndicatorStyle = const DocumentCameraSideIndicatorStyle(),
    this.progressStyle = const DocumentCameraProgressStyle(),
    this.instructionStyle = const DocumentCameraInstructionStyle(),
    this.onFrontCaptured,
    this.onBackCaptured,
    this.onDocumentSaved,
    this.onBothSidesSaved,
    this.enableExtractText = false,
    this.onRetake,
    this.bottomFrameContainerChild,
    this.showCloseButton = false,
    this.cameraIndex,
    this.requireBothSides = true,
    this.bottomHintText,
    this.sideInfoOverlay,
    this.enableAutoCapture = false,
    this.showDetectionStatusText = true,
    this.onCameraError,
    this.outputFormat = DocumentOutputFormat.jpg,
    this.pdfPageSize = PdfPageSize.a4,
    this.imageQuality = 90,
    this.initialFlashMode = FlashMode.auto,
    this.uiMode = DocumentCameraUIMode.defaultMode,
  });

  bool get _isCamScanner => uiMode == DocumentCameraUIMode.camScanner;

  bool get _effectiveAutoCapture =>
      uiMode != DocumentCameraUIMode.minimal &&
      uiMode != DocumentCameraUIMode.camScanner;

  bool get _effectiveShowDetectionText =>
      uiMode != DocumentCameraUIMode.minimal &&
      uiMode != DocumentCameraUIMode.camScanner;

  bool get _effectiveEnableExtractText =>
      uiMode == DocumentCameraUIMode.textExtract ? true : enableExtractText;

  bool get _effectiveShowSideIndicator =>
      sideIndicatorStyle.showSideIndicator &&
      uiMode != DocumentCameraUIMode.minimal &&
      uiMode != DocumentCameraUIMode.overlay &&
      uiMode != DocumentCameraUIMode.camScanner;

  bool get _effectiveShowInstruction =>
      instructionStyle.showInstructionText &&
      uiMode != DocumentCameraUIMode.minimal &&
      uiMode != DocumentCameraUIMode.overlay &&
      uiMode != DocumentCameraUIMode.camScanner;

  /// Whether the screen title should be rendered.
  /// Respects [DocumentCameraTitleStyle.showScreenTitle] and is always
  /// false in `minimal` and `camScanner` modes.
  bool get _effectiveShowScreenTitle =>
      titleStyle.showScreenTitle &&
      uiMode != DocumentCameraUIMode.minimal &&
      uiMode != DocumentCameraUIMode.camScanner;

  @override
  State<DocumentCameraFrame> createState() => _DocumentCameraFrameState();
}

class _DocumentCameraFrameState extends State<DocumentCameraFrame>
    with TickerProviderStateMixin {
  late final DocumentCameraLogic _logic;

  AnimationController? _progressAnimationController;
  Animation<double>? _progressAnimation;

  final ValueNotifier<String> _camScannerLabel = ValueNotifier<String>(
    'Scan Front Side',
  );

  @override
  void initState() {
    super.initState();

    if (widget._isCamScanner) {
      _logic = DocumentCameraLogic(
        context: context,
        onCameraError: () => widget.onCameraError?.call('Camera error'),
        onFrontCaptured: widget.onFrontCaptured,
        onBackCaptured: widget.onBackCaptured,
        onDocumentSaved: (data) {
          (widget.onDocumentSaved ?? widget.onBothSidesSaved)?.call(data);
        },
        enableExtractText: false,
        onRetake: widget.onRetake,
        enableAutoCapture: false,
        requireBothSides: widget.requireBothSides,
        frameFlipDuration: widget.animationStyle.frameFlipDuration,
        outputFormat: widget.outputFormat,
        pdfPageSize: widget.pdfPageSize,
        imageQuality: widget.imageQuality,
        initialFlashMode: widget.initialFlashMode,
        uiMode: widget.uiMode,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) => _launchCamScanner());
      return;
    }

    _logic = DocumentCameraLogic(
      context: context,
      onCameraError: () => widget.onCameraError?.call('Camera error'),
      onFrontCaptured: widget.onFrontCaptured,
      onBackCaptured: widget.onBackCaptured,
      onDocumentSaved: (data) {
        (widget.onDocumentSaved ?? widget.onBothSidesSaved)?.call(data);
      },
      enableExtractText: widget._effectiveEnableExtractText,
      onRetake: widget.onRetake,
      enableAutoCapture: widget._effectiveAutoCapture,
      requireBothSides: widget.requireBothSides,
      frameFlipDuration: widget.animationStyle.frameFlipDuration,
      outputFormat: widget.outputFormat,
      pdfPageSize: widget.pdfPageSize,
      imageQuality: widget.imageQuality,
      initialFlashMode: widget.initialFlashMode,
      uiMode: widget.uiMode,
    );

    if (widget._effectiveShowSideIndicator) {
      _initializeProgressAnimation();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logic.initialize(
        frameWidth: widget.frameWidth,
        frameHeight: widget.frameHeight,
        cameraIndex: widget.cameraIndex,
      );
    });
  }

  // ---------------------------------------------------------------------------
  // camScanner mode — sequential front → back native scans
  // ---------------------------------------------------------------------------

  Future<void> _launchCamScanner() async {
    final service = CamScannerService();

    void popWithResult(DocumentCaptureData result) {
      if (!mounted) return;
      (widget.onDocumentSaved ?? widget.onBothSidesSaved)?.call(result);
      Navigator.of(context).pop(result);
    }

    void popCancelled() {
      if (!mounted) return;
      Navigator.of(context).maybePop();
    }

    if (widget.requireBothSides) {
      _camScannerLabel.value = 'Scan Front Side, then tap Save';
      final frontPaths = await service.scan(maxPages: 2);
      if (!mounted) return;

      if (frontPaths.isEmpty) {
        popCancelled();
        return;
      }

      final frontPath = frontPaths.last;
      widget.onFrontCaptured?.call(frontPath);

      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      _camScannerLabel.value = 'Scan Back Side, then tap Save';
      final backPaths = await service.scan(maxPages: 2);
      if (!mounted) return;

      if (backPaths.isEmpty) {
        popWithResult(
          DocumentCaptureData(
            frontImagePath: frontPath,
            frontPreviewPath: frontPath,
          ),
        );
        return;
      }

      final backPath = backPaths.last;
      widget.onBackCaptured?.call(backPath);

      popWithResult(
        DocumentCaptureData(
          frontImagePath: frontPath,
          frontPreviewPath: frontPath,
          backImagePath: backPath,
          backPreviewPath: backPath,
        ),
      );
    } else {
      _camScannerLabel.value = 'Scan Document, then tap Save';
      final paths = await service.scan(maxPages: 2);
      if (!mounted) return;

      if (paths.isEmpty) {
        popCancelled();
        return;
      }

      final frontPath = paths.last;
      widget.onFrontCaptured?.call(frontPath);

      popWithResult(
        DocumentCaptureData(
          frontImagePath: frontPath,
          frontPreviewPath: frontPath,
        ),
      );
    }
  }

  void _initializeProgressAnimation() {
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressAnimationController!,
        curve: Curves.easeInOut,
      ),
    );

    _logic.currentSideNotifier.addListener(() {
      if (_logic.currentSideNotifier.value == DocumentSide.back) {
        _progressAnimationController?.animateTo(1.0);
      } else {
        _progressAnimationController?.animateTo(0.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget._isCamScanner) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 20),
                ValueListenableBuilder<String>(
                  valueListenable: _camScannerLabel,
                  builder: (context, label, _) => Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.requireBothSides) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Scan the front, then the back.\nWe will use the last image from each session.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          DocumentCameraPreviewLayer(
            logic: _logic,
            borderRadius: widget.frameStyle.outerFrameBorderRadius,
            innerCornerBorderRadius: widget.frameStyle.innerCornerBorderRadius,
            capturingAnimationDuration:
                widget.animationStyle.capturingAnimationDuration,
            capturingAnimationColor:
                widget.animationStyle.capturingAnimationColor,
            capturingAnimationCurve:
                widget.animationStyle.capturingAnimationCurve,
            uiMode: widget.uiMode,
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _logic.isInitializedNotifier,
            builder: (context, isInitialized, child) {
              if (!isInitialized) return const SizedBox.shrink();
              return DocumentCameraOverlayLayer(
                logic: _logic,
                frameStyle: widget.frameStyle,
                animationStyle: widget.animationStyle,
                bottomHintText: widget.bottomHintText,
                sideInfoOverlay: widget.sideInfoOverlay,
                bottomFrameContainerChild: widget.bottomFrameContainerChild,
                sideIndicatorStyle: widget.sideIndicatorStyle,
                progressStyle: widget.progressStyle,
                progressAnimation: _progressAnimation,
                showDetectionStatusText: widget._effectiveShowDetectionText,
                showSideIndicator: widget._effectiveShowSideIndicator,
                showInstruction: widget._effectiveShowInstruction,
                showScreenTitle: widget._effectiveShowScreenTitle,
                instructionStyle: widget.instructionStyle,
                titleStyle: widget.titleStyle,
                showCloseButton: widget.showCloseButton,
                buttonStyle: widget.buttonStyle,
                uiMode: widget.uiMode,
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _logic.dispose();
    _progressAnimationController?.dispose();
    _camScannerLabel.dispose();
    super.dispose();
  }
}
