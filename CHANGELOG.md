# 2.0.0
added:
- Modular styling system with dedicated style classes:
  - `DocumentCameraAnimationStyle`
  - `DocumentCameraFrameStyle`
  - `DocumentCameraButtonStyle`
  - `DocumentCameraTitleStyle`
  - `DocumentCameraSideIndicatorStyle`
  - `DocumentCameraProgressStyle`
  - `DocumentCameraInstructionStyle`
- Auto-capture functionality via `enableAutoCapture` parameter.
- Error handling with `onCameraError` callback.
- Enhanced animation using `FrameCaptureAnimation`.
- Performance boost using `ValueListenableBuilder` with `child`.
- Complete Dart documentation for all style properties.

changed:
- BREAKING: Replaced individual style params with grouped `style` objects.
- BREAKING: Constructor now uses style classes (`buttonStyle`, `animationStyle`, etc.).
- Optimized animation rendering and reduced rebuilds.
- Refactored code for better structure and performance.

migration_guide:
before: |
```dart
DocumentCameraFrame(
  captureButtonStyle: buttonStyle,
  captureButtonAlignment: Alignment.center,
  captureButtonPadding: EdgeInsets.all(16),
  capturingAnimationDuration: Duration(seconds: 1),
)
```
after: |
```dart
  DocumentCameraFrame(
  buttonStyle: DocumentCameraButtonStyle(
  captureButtonStyle: buttonStyle,
  captureButtonAlignment: Alignment.center,
  captureButtonPadding: EdgeInsets.all(16),
  ),
  animationStyle: DocumentCameraAnimationStyle(
  capturingAnimationDuration: Duration(seconds: 1),
  ),
)
```

# 1.0.9 - 1.0.4
- Update `examples.gif`
- Update Readme.md
- Update metadata

# 1.0.3
- Update metadata

# 1.0.2
- Update metadata

# 1.0.0
added:
- Two-sided document capture: front and back.
- Callbacks: `onFrontCaptured`, `onBackCaptured`, `onBothSidesSaved`.
- Custom titles and instructions per side.
- Navigation controls and side indicator UI.
- Animated progress bar and frame flip transitions.
- Camera switching via button.

changed:
- BREAKING: Replaced `onSaved` with `onBothSidesSaved`.
- Refactored to support two-sided logic and flow.
- Enhanced transitions and layout handling.

fixed:
- Better capture reset flow.
- Improved multi-side state handling.
- Camera-related error recovery.

# 0.1.6
- Update metadata.

# 0.1.5
features:
- Added camera switch icon.
  fixes:
- `retakeButtonText` and `saveButtonText` now display correctly.
- Custom camera selection (not hardcoded to ID 0).

# 0.1.4
- Update Readme.md.

# 0.1.3
- Update metadata.

# 0.1.2
- Added `showCloseButton` flag.
- Frame animation duration reduced to `400ms`.

# 0.1.0
- Redesigned `DocumentCameraFrame` UI.
- Added:
  - `captureOuterCircleRadius`
  - `captureInnerCircleRadius`
- Smooth container open animation (bottom to top).
- Documentation updated accordingly.

# 0.0.9
- Add `example.gif`
- Update Readme.md.

# 0.0.8
- Add `example.mp4`
- Update Readme.md.

# 0.0.7 to 0.0.2
- README and metadata updates.

# 0.0.3
- Fixed deprecated usage in `DocumentCameraFramePainter`:
  - Changed `Colors.black.withOpacity(0.5)` to `Colors.black.withAlpha(127)`.

# 0.0.1
- Initial release.
