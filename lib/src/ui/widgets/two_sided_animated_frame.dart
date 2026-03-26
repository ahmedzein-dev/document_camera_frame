import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:document_camera_frame/src/core/context_extensions.dart';
import 'package:document_camera_frame/src/ui/widgets/corner_box.dart';
import 'package:flutter/material.dart';
import '../../core/app_constants.dart';
import 'animated_document_camera_frame_painter.dart';

class TwoSidedAnimatedFrame extends StatefulWidget {
  final double frameHeight;
  final double frameWidth;
  final double outerFrameBorderRadius;
  final double innerCornerBorderRadius;
  final Duration frameFlipDuration;
  final Curve frameFlipCurve;
  final BoxBorder? border;
  final ValueNotifier<DocumentSide>? currentSideNotifier;
  final bool isDocumentAligned;

  /// When `false` the dark semi-transparent cutout overlay is not painted,
  /// allowing content behind the camera preview to show through.
  /// Used by [DocumentCameraUIMode.overlay].
  final bool showDarkOverlay;

  const TwoSidedAnimatedFrame({
    super.key,
    required this.frameHeight,
    required this.frameWidth,
    required this.outerFrameBorderRadius,
    required this.innerCornerBorderRadius,
    required this.frameFlipDuration,
    required this.frameFlipCurve,
    this.border,
    this.currentSideNotifier,
    required this.isDocumentAligned,
    this.showDarkOverlay = true,
  });

  @override
  State<TwoSidedAnimatedFrame> createState() => _TwoSidedAnimatedFrameState();
}

class _TwoSidedAnimatedFrameState extends State<TwoSidedAnimatedFrame>
    with TickerProviderStateMixin {
  double _frameHeight = 0;
  double _cornerBorderBoxHeight = 0;

  late AnimationController _flipAnimationController;
  late Animation<double> _flipAnimation;

  DocumentSide? _previousSide;
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();

    _flipAnimationController = AnimationController(
      duration: widget.frameFlipDuration,
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _flipAnimationController,
        curve: widget.frameFlipCurve,
      ),
    );

    widget.currentSideNotifier?.addListener(_onSideChanged);
    _previousSide = widget.currentSideNotifier?.value;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openFrame();
    });
  }

  void _onSideChanged() {
    final currentSide = widget.currentSideNotifier?.value;
    if (_previousSide != null && _previousSide != currentSide && !_isFlipping) {
      _triggerFlipAnimation();
    }
    _previousSide = currentSide;
  }

  void _triggerFlipAnimation() async {
    if (_isFlipping) return;
    setState(() => _isFlipping = true);
    await _flipAnimationController.forward();
    _flipAnimationController.reset();
    setState(() => _isFlipping = false);
  }

  void _openFrame() {
    setState(() {
      _frameHeight =
          widget.frameHeight + AppConstants.bottomFrameContainerHeight;
      _cornerBorderBoxHeight =
          widget.frameHeight + AppConstants.bottomFrameContainerHeight / 2 - 34;
    });
  }

  double _getAnimatedFrameHeight() {
    if (!_isFlipping) return _frameHeight;
    if (_flipAnimation.value <= 0.5) {
      return _frameHeight * (1 - (_flipAnimation.value * 2));
    } else {
      return _frameHeight * ((_flipAnimation.value - 0.5) * 2);
    }
  }

  double _getAnimatedCornerHeight() {
    if (!_isFlipping) return _cornerBorderBoxHeight;
    if (_flipAnimation.value <= 0.5) {
      return _cornerBorderBoxHeight * (1 - (_flipAnimation.value * 2));
    } else {
      return _cornerBorderBoxHeight * ((_flipAnimation.value - 0.5) * 2);
    }
  }

  Duration get animatedFrameDuration => Duration(
    milliseconds: (widget.frameFlipDuration.inMilliseconds / 2).round(),
  );

  /// Resolves the current border colour with a smooth fade-out → fade-in
  /// during the flip animation.
  ///
  /// [flipProgress] is the raw animation value (0.0 → 1.0):
  ///   - 0.0 → 0.5 : frame shrinks  → opacity fades **out** (1.0 → 0.0)
  ///   - 0.5 → 1.0 : frame grows    → opacity fades **in**  (0.0 → 1.0)
  Color _borderColor({required double flipProgress, required bool isAligned}) {
    final Color base = isAligned
        ? Colors.green.shade400
        : (widget.border is Border
              ? (widget.border as Border).top.color
              : Colors.white);

    if (flipProgress == 0.0) return base; // not flipping — full opacity

    final double opacity = flipProgress <= 0.5
        ? 1.0 -
              (flipProgress * 2) // fade out
        : (flipProgress - 0.5) * 2; // fade in

    return base.withValues(alpha: base.a * opacity);
  }

  Widget _buildFrame(
    double animatedFrameHeight,
    double animatedCornerHeight,
    double bottomPosition,
  ) {
    return Stack(
      children: [
        /// Dark cutout overlay (skipped in overlay mode)
        if (widget.showDarkOverlay)
          Positioned.fill(
            child: CustomPaint(
              painter: AnimatedDocumentCameraFramePainter(
                isFlipping: _isFlipping,
                frameWidth: widget.frameWidth,
                frameMaxHeight: _frameHeight,
                animatedFrameHeight: animatedFrameHeight,
                bottomPosition: bottomPosition,
                borderRadius: widget.outerFrameBorderRadius,
                context: context,
              ),
            ),
          ),

        /// Frame border
        Positioned(
          bottom: bottomPosition,
          right: (1.sw(context) - widget.frameWidth) / 2,
          child: AnimatedContainer(
            width: widget.frameWidth,
            height: animatedFrameHeight,
            duration: _isFlipping ? Duration.zero : animatedFrameDuration,
            curve: widget.frameFlipCurve,
            decoration: BoxDecoration(
              border: Border.all(
                color: _borderColor(
                  flipProgress: _isFlipping ? _flipAnimation.value : 0.0,
                  isAligned: widget.isDocumentAligned,
                ),
                width: widget.border is Border
                    ? (widget.border as Border).top.width
                    : 3,
              ),
              borderRadius: BorderRadius.circular(
                widget.innerCornerBorderRadius,
              ),
            ),
          ),
        ),

        /// Corner boxes
        Positioned(
          bottom: (1.sh(context) - widget.frameHeight) / 2 + 17,
          left: 0,
          right: 0,
          child: Align(
            child: AnimatedContainer(
              height: animatedCornerHeight,
              width:
                  widget.frameWidth -
                  AppConstants.kCornerBorderBoxHorizontalPadding,
              duration: _isFlipping ? Duration.zero : animatedFrameDuration,
              curve: widget.frameFlipCurve,
              child: animatedCornerHeight > 0
                  ? Stack(
                      children: [
                        Positioned(
                          bottom:
                              widget.frameHeight +
                              AppConstants.bottomFrameContainerHeight / 2 -
                              34 -
                              18,
                          left: 0,
                          child: CornerBox(
                            topLeft: true,
                            flipProgress: _isFlipping
                                ? _flipAnimation.value
                                : 0.0,
                            isDocumentAligned: widget.isDocumentAligned,
                            innerCornerBorderRadius:
                                widget.innerCornerBorderRadius,
                          ),
                        ),
                        Positioned(
                          bottom:
                              widget.frameHeight +
                              AppConstants.bottomFrameContainerHeight / 2 -
                              34 -
                              18,
                          right: 0,
                          child: CornerBox(
                            topRight: true,
                            flipProgress: _isFlipping
                                ? _flipAnimation.value
                                : 0.0,
                            isDocumentAligned: widget.isDocumentAligned,
                            innerCornerBorderRadius:
                                widget.innerCornerBorderRadius,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: CornerBox(
                            bottomLeft: true,
                            flipProgress: _isFlipping
                                ? _flipAnimation.value
                                : 0.0,
                            isDocumentAligned: widget.isDocumentAligned,
                            innerCornerBorderRadius:
                                widget.innerCornerBorderRadius,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CornerBox(
                            bottomRight: true,
                            flipProgress: _isFlipping
                                ? _flipAnimation.value
                                : 0.0,
                            isDocumentAligned: widget.isDocumentAligned,
                            innerCornerBorderRadius:
                                widget.innerCornerBorderRadius,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final animatedFrameHeight = _getAnimatedFrameHeight();
        final animatedCornerHeight = _getAnimatedCornerHeight();
        final bottomPosition =
            (1.sh(context) -
                widget.frameHeight -
                AppConstants.bottomFrameContainerHeight) /
            2;
        return _buildFrame(
          animatedFrameHeight,
          animatedCornerHeight,
          bottomPosition,
        );
      },
    );
  }

  @override
  void dispose() {
    _flipAnimationController.dispose();
    widget.currentSideNotifier?.removeListener(_onSideChanged);
    super.dispose();
  }
}
