# 2.2.0

added:
- **Major internal refactoring:** Separated UI and business logic for better maintainability.
- **Improved Architecture:**
  - UI split into `DocumentCameraPreviewLayer` and `DocumentCameraOverlayLayer`.
  - State management and business logic extracted into `DocumentCameraLogic`.
- **New styling parameters:**
  - `showDetectionStatusText` in `DocumentCameraFrame`: Toggle live detection guidance text.
  - `showInstructionText` in `DocumentCameraInstructionStyle`: Toggle top instruction text.
  - `topPosition` and `rightPosition` in `DocumentCameraSideIndicatorStyle`: Precise control over side indicator placement.
- **Enhanced Internal Services:**
  - **`DocumentDetectionService` Optimization**:
    - Added **Letterbox Correction**: Accounts for camera sensor aspect ratio vs display area to ensure precise frame alignment.
    - Added **Best-Candidate Selection**: Intelligently picks the best document candidate based on aspect ratio and area.
    - Added **Live Guidance Engine**: Generates real-time user hints ("Move closer", "Move right", etc.) via `detectionStatusNotifier`.
    - Added **Screen-Space Mapping**: Automatically maps detection coordinates to screen pixels for overlay rendering, including mirroring support for front cameras.
  - **`ImageConverterService` Robustness**:
    - Hardened conversion paths for `BGRA8888` (iOS) and `NV21/YUV420` (Android).
    - Added **Stride (BytesPerRow) Handling** to prevent image skewing/distortion on various hardware.

changed:
- `DocumentCameraFrame` widget is now more efficient and easier to customize.
- Refactored internal components for a cleaner codebase.

# 2.1.0 - 2.1.1

added:
- **On-device OCR (text extraction):** Optional text recognition via `enableExtractText`.
- **`enableExtractText`** parameter: When `true`, runs OCR after capture and sets `DocumentCaptureData.frontOcrText` and `backOcrText` before calling the save callback (no API key or internet required).
- **`OcrService`** class: Reusable on-device OCR using Google ML Kit (Latin script; English and other Latin-based languages). Exported from the package for custom use.
- **`DocumentCaptureData.frontOcrText`** and **`DocumentCaptureData.backOcrText`**: Optional extracted text when `enableExtractText` is true.
- Dependency: `google_mlkit_text_recognition` for OCR.

changed:
- **`onDocumentSaved`**: New preferred callback name (replaces `onBothSidesSaved`). Fits both one-sided documents (e.g. passport) and two-sided (e.g. ID). Callback receives `DocumentCaptureData` with image paths and, when `enableExtractText` is true, `frontOcrText` and `backOcrText`.
- **`onBothSidesSaved`** is deprecated; use `onDocumentSaved`. The deprecated callback still works for backward compatibility.
- **`DocumentCaptureData`** model: Now holds optional `frontOcrText` and `backOcrText`; doc comment updated for one-sided vs two-sided use.

notes:
- OCR supports **Latin script only** (English, etc.). Arabic is not supported by ML Kit's on-device model.
- Android: `minSdk` 21+ required. iOS: platform 15.5+ and armv7 exclusion recommended for ML Kit.

# 2.0.1 - 2.0.4
- Update Readme.md
- Update metadata

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
