import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';

import '../../core/app_constants.dart';

class AnimatedFrame extends StatefulWidget {
  final double frameHeight;
  final double frameWidth;
  final double outerFrameBorderRadius;
  final double innerCornerBroderRadius;
  final Duration animatedFrameDuration;
  final Curve animatedFrameCurve;
  final BoxBorder? border;

  const AnimatedFrame({
    super.key,
    required this.frameHeight,
    required this.frameWidth,
    required this.outerFrameBorderRadius,
    required this.innerCornerBroderRadius,
    required this.animatedFrameDuration,
    required this.animatedFrameCurve,
    this.border,
  });

  @override
  State<AnimatedFrame> createState() => _AnimatedFrameState();
}

class _AnimatedFrameState extends State<AnimatedFrame> {
  double _frameHeight = 0;
  double _cornerBorderBoxHeight = 0;

  @override
  void initState() {
    super.initState();
    // Trigger the animation after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _frameHeight = widget.frameHeight + AppConstants.bottomFrameContainerHeight;
        _cornerBorderBoxHeight = widget.frameHeight + AppConstants.bottomFrameContainerHeight / 2 - 34;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Border of the document frame
        Positioned(
          bottom: (1.sh(context) - widget.frameHeight - AppConstants.bottomFrameContainerHeight) / 2,
          right: (1.sw(context) - widget.frameWidth) / 2,
          child: AnimatedContainer(
            width: widget.frameWidth,
            height: _frameHeight,
            duration: widget.animatedFrameDuration,
            curve: widget.animatedFrameCurve,
            decoration: BoxDecoration(
              border: widget.border ?? Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.circular(widget.innerCornerBroderRadius),
            ),
          ),
        ),

        // CornerBorderBox of the document frame
        Positioned(
          bottom: (1.sh(context) - widget.frameHeight) / 2 + 17,
          left: 0,
          right: 0,
          child: Align(
            child: AnimatedContainer(
              height: _cornerBorderBoxHeight,
              width: widget.frameWidth - AppConstants.kCornerBorderBoxHorizontalPadding,
              duration: widget.animatedFrameDuration,
              curve: widget.animatedFrameCurve,
              child: Stack(
                children: [
                  // Top-left corner
                  Positioned(
                    bottom: widget.frameHeight + AppConstants.bottomFrameContainerHeight / 2 - 34 - 18,
                    left: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                          left: BorderSide(color: Colors.white, width: 2),
                          right: BorderSide.none,
                          bottom: BorderSide.none,
                        ),
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(widget.innerCornerBroderRadius)),
                      ),
                    ),
                  ),

                  // Top-right corner
                  Positioned(
                    bottom: widget.frameHeight + AppConstants.bottomFrameContainerHeight / 2 - 34 - 18,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Colors.white, width: 2),
                          right: BorderSide(color: Colors.white, width: 2),
                          left: BorderSide.none,
                          bottom: BorderSide.none,
                        ),
                        borderRadius: BorderRadius.only(topRight: Radius.circular(widget.innerCornerBroderRadius)),
                      ),
                    ),
                  ),

                  // Bottom-left corner
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide.none,
                          right: BorderSide.none,
                          left: BorderSide(color: Colors.white, width: 2),
                          bottom: BorderSide(color: Colors.white, width: 2),
                        ),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(widget.innerCornerBroderRadius)),
                      ),
                    ),
                  ),

                  // Bottom-right corner
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide.none,
                          left: BorderSide.none,
                          right: BorderSide(color: Colors.white, width: 2),
                          bottom: BorderSide(color: Colors.white, width: 2),
                        ),
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(widget.innerCornerBroderRadius)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
