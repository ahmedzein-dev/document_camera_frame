# 2.5.4
- **Score Fix**: Fixed Swift Package Manager path — moved `Package.swift` to the correct location `ios/document_camera_frame/Package.swift` as required by the `pana` analyzer.

# 2.5.3
- **Score Fix**: Added Swift Package Manager (SPM) support for iOS to achieve full 160/160 pub points.
- **Maintenance**: Synced podspec and package metadata.

# 2.5.2
- **Score Fix**: Restored 160/160 pub points by properly registering the Android platform implementation.
- **Dependency Update**: Bumped `camera` dependency to `^0.12.0` for latest platform supports.
- **Platform support**: Enhanced Android native registration structure for better compatibility with `pana` analyzer.

#  2.5.0 - 2.5.1

## Added
- **`DocumentCameraUIMode.camScanner`**: Integrated a new mode that delegates scanning to platform-native engines for professional-grade results.
    - **Android**: Leverages Google ML Kit for automatic edge detection, perspective correction, and image filters.
    - **iOS**: Leverages Apple's VisionKit (`VNDocumentCameraViewController`) for a high-performance system-native experience.
- **Smart Sequential Flow**: Native mode now supports automated multi-side scanning. It guides the user through "Front Side" and "Back Side" sessions sequentially with built-in loading scaffolds.
- **Last-Capture Selection**: Both Android and iOS native modes now automatically favor the final (best) capture from a scanning session when `requireBothSides` is enabled.
- **`CamScannerService`**: Exposed the underlying platform service, allowing developers to trigger native scans programmatically without the full framing UI.

## Changed
- **Pubspec Update**: Updated dependencies to ensure compatibility with the latest ML Kit and VisionKit APIs.
- **Platform Support**: Explicitly registered Android platform support in `pubspec.yaml` and added minimal native Android project structure to ensure correct platform detection on pub.dev.

# 2.4.0

## Added
- **`DocumentCameraUIMode` enum** — support for five distinct UI modes: `defaultMode`, `minimal`, `overlay`, `kiosk`, and `textExtract`.
- **`uiMode` parameter on `DocumentCameraFrame`** (fully backward compatible).
- **Comprehensive UI Mode Matrix**:
  - `defaultMode`: Standard full-featured experience.
  - `minimal`: Bare-bones UI with four corner indicators and action buttons.
  - `overlay`: Focuses on the document frame and screen title.
  - `kiosk`: Automated flow for unattended environments (auto-capture only).
  - `textExtract`: Optimized layout for OCR-focused workflows.
- Replaced `MinimalCornerIndicators` with standardized **`CornerBox`** component across all modes for better consistency.
- **Smooth Flip Fading**: Implemented opacity-based fading transitions during frame flipping for a more premium feel.
- **Refined Minimal Mode Constraints**: Capture animation, image cropping, and previews are now strictly pixel-perfectly bounded by the corner indicators.
- **Matched Preview Aesthetics**: Synchronized border radius between `CornerBox` indicators and captured image previews for a seamless visual experience.

## Notes
- Default mode behavior is **unchanged** — no existing consumers are affected.
- Instructions are fully supported in minimal mode but hidden by default (minimal mode always suppresses instruction overlays).

---

# 2.3.0
added:
- **Export Format Support:** Choose output format for captured documents.
  - **`outputFormat`** parameter: Select from `DocumentOutputFormat.jpg` (default), `png`, `pdf`, `webp`, or `tiff`.
  - **`pdfPageSize`** parameter: Configure PDF page size (`PdfPageSize.a4` or `letter`) when using PDF format.
  - **`imageQuality`** parameter: Control compression quality (1-100) for JPG and WebP formats.
  - **PDF Generation:** Multi-page PDF support for two-sided documents with configurable page sizes.
  - **`DocumentCaptureData.pdfPath`**: New field containing the path to generated PDF when using PDF format.
  - **`PdfGenerationService`**: New exported service for custom PDF generation from images.
- **TIFF Format Support:** Added automatic JPG preview generation for TIFF files to resolve "Invalid image data" errors in Flutter UI.
- **TIFF OCR Fix:** OCR extraction now uses internal JPG previews to bypass ML Kit's lack of native TIFF support.
- **`DocumentCaptureData` Enhancements:**
  - Added **`frontPreviewPath`** and **`backPreviewPath`**: Access displayable (JPG) versions of documents even when the primary output is TIFF.
  - Added **`hasFrontText`** and **`hasBackText`** getters: Simplified logic for checking if OCR extracted any content.
- **`initialFlashMode` property:** Configure the starting flash mode for the camera (auto, off, on, torch).
- **Library Export:** Re-exported `FlashMode` from the core library to simplify integration for consumers.

changed:
- **Alignment Reset:** The alignment guidance (green frame) now correctly resets when tapping "Retake".
- **PDF Export Optimization:** Automatically deletes temporary JPG files after PDF generation to minimize local storage usage.
- **Example App Enhancement:** Added direct file opening for generated PDFs using `open_file`.
- **Image Processing:** Updated `ImageProcessingService` to support multiple output formats.
- **Dependencies:** Added `pdf` package (^3.11.2) for PDF generation. Downgraded `image` package to ^4.5.4 for compatibility.

notes:
- All new parameters are optional with sensible defaults.
- Existing code continues to work without modifications (JPG is default).
- PDF generation only occurs when `outputFormat` is set to `DocumentOutputFormat.pdf`.
- See `example/lib/export_format_example.dart` for usage examples of all formats.

---

# 2.2.1 - 2.2.3
- Update Readme.md
- Update metadata
- Update example

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
