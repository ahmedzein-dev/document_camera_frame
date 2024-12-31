## 0.0.1

- Initial release.

## 0.0.2

- Update Readme.md.

## 0.0.3

- Resolved deprecation warning in `DocumentCameraFramePainter`:
    - Replaced `Colors.black.withOpacity(0.5)` with `Colors.black.withAlpha(127)` to avoid precision
      loss.

## 0.0.4

- Update Readme.md.

## 0.0.5

- Update metadata.

## 0.0.6

- Update Readme.md.

## 0.0.7

- Update Readme.md.

## 0.0.8

- Add example.mp4
- Update Readme.md.

## 0.0.9

- Add example.gif
- Update Readme.md.

## 0.1.0

- Enhanced widget UI for `DocumentCameraFrame` to improve design aesthetics.
- Added customizable parameters for the capture button:
    - `captureOuterCircleRadius`: Radius of the outer circle for the capture button.
    - `captureInnerCircleRadius`: Radius of the inner circle for the capture button.
- Implemented an animation for smoother transitions:
    - The container now animates from bottom to top when opened.
- Updated documentation to reflect these changes.

## 0.1.2

- Added `showCloseButton` parameter to control the visibility of the close button.
- Updated `DocumentCameraFrame` to conditionally display the close button based on `showCloseButton`
  flag.
- Update animatedFrameDuration parameter to Duration(milliseconds: 400) instead of Duration(
  milliseconds: 800) for faster frame animation speed.

## 0.1.3

- Update metadata.
