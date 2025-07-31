import 'dart:io';

import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:document_camera_frame/src/core/app_constants.dart';
import 'package:flutter/material.dart';

class TwoSidedBottomFrameContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final Widget? bottomFrameContainerChild;

  final ValueNotifier<DocumentSide> currentSideNotifier;
  final ValueNotifier<DocumentCaptureData> documentDataNotifier;

  final String? bottomHintText;
  final Widget? sideInfoOverlay;

  const TwoSidedBottomFrameContainer({
    super.key,
    required this.width,
    required this.height,
    required this.borderRadius,
    required this.currentSideNotifier,
    required this.documentDataNotifier,
    this.bottomFrameContainerChild,
    this.bottomHintText,
    this.sideInfoOverlay,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: .5.sh(context) + (height / 2),
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          width: width,
          height: AppConstants.bottomFrameContainerHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: bottomFrameContainerChild ??
              ValueListenableBuilder<DocumentSide>(
                valueListenable: currentSideNotifier,
                builder: (context, side, _) {
                  final isFront = side == DocumentSide.front;
                  final label = isFront ? 'Front' : 'Back';
                  final icon =
                      isFront ? Icons.credit_card_outlined : Icons.credit_card;

                  final imagePath = isFront
                      ? documentDataNotifier.value.frontImagePath
                      : documentDataNotifier.value.backImagePath;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      /// Left side: Icon + label + optional hint
                      Expanded(
                        child: Row(
                          children: [
                            Icon(icon, color: Colors.black54, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              label,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            if (bottomHintText != null) ...[
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  bottomHintText!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      /// Right side: Optional image thumbnail + overlay
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (imagePath != null && imagePath.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                File(imagePath),
                                width: 36,
                                height: 22,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (sideInfoOverlay != null) ...[
                            const SizedBox(width: 8),
                            sideInfoOverlay!,
                          ],
                        ],
                      ),
                    ],
                  );
                },
              ),
        ),
      ),
    );
  }
}
