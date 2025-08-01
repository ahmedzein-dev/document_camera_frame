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

## 0.1.4

- Update Readme.md.

## 0.1.5

- Features
    - camera: Added camera switch icon reference.
- Fixes
    - camera: Ensured retakeButtonText and saveButtonText reflect in the UI.
    - camera: Allowed setting the camera instead of defaulting to back (ID 0).

## 0.1.6

- Update metadata.

## 1.0.0

### Added
- Support for **two-sided document capture** (front and back).
- New callback functions:
  - `onFrontCaptured` – Triggered when front side is captured.
  - `onBackCaptured` – Triggered when back side is captured.
  - `onBothSidesSaved` – Triggered when both sides are saved.
- Enhanced customization parameters:
  - `frontSideTitle`, `backSideTitle` – Custom titles for each side.
  - `frontSideInstruction`, `backSideInstruction` – Side-specific instruction text.
  - `requireBothSides` – Allow optional back side capture.
  - `sideInfoOverlay`, `bottomHintText` – Additional UI customization.
  - `showSideIndicator` – Toggle side progress indicator visibility.
  - `nextButtonText`, `previousButtonText` – Navigation button text customization.
  - `actionButtonStyle`, `actionButtonAlignment`, `actionButtonPadding` – Action button styling.
  - `progressIndicatorColor`, `progressIndicatorHeight` – Progress bar customization.
  - `sideIndicatorBackgroundColor`, `sideIndicatorActiveColor`, etc. – Side indicator styling.
- Added **side indicator widget** to visually track capture progress.
- Animated **progress bar** showing front/back capture completion.
- Flip animation with customizable duration and curve between frame sides.
- Camera switching functionality via UI button.
- Enhanced UI animations and transitions.

### Changed
- **BREAKING:** Replaced `onSaved` callback with `onBothSidesSaved` for two-sided workflow.
- Refactored internal architecture to support unified two-sided document capture.
- Improved button layout and positioning system.
- Enhanced frame animation system with flip transitions.

### Fixed
- Improved capture reset handling after saving or retaking photos.
- Better state management for multi-side capture workflow.
- Enhanced error handling for camera operations.

## 1.0.2

- Update metadata.

- ## 1.0.3

- Update metadata.

- ## 1.0.4

- Update examples.gif.
- Update Readme.md.
- Update metadata.

- ## 1.0.5

- Update examples.gif.
- Update Readme.md.
- Update metadata.

- ## 1.0.6

- Update examples.gif.
- Update Readme.md.
- Update metadata.

- ## 1.0.7

- Update examples.gif.
- Update Readme.md.
- Update metadata.

- ## 1.0.8

- Update examples.gif.
- Update Readme.md.
- Update metadata.

