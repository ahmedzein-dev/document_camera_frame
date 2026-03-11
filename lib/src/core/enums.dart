/// Enum to define animation phases
enum AnimationPhase { downward, flipToBack, upward }

/// UI presentation mode for [DocumentCameraFrame].
enum DocumentCameraUIMode {
  /// Full default UI: dark overlay, frame box with flip animation, side indicators,
  /// guidance text, progress bar, and screen title.
  defaultMode,

  /// Minimal UI: camera preview + four rounded corner indicators only.
  /// All built-in overlays (dark overlay, frame box, side indicators, guidance text,
  /// progress bar, and screen title) are hidden. Action buttons remain visible.
  /// Instructions are supported but hidden by default.
  minimal,

  /// Like [defaultMode] but without the dark semi-transparent cutout overlay.
  /// The full camera preview fills the screen; all other default UI elements
  /// (frame border, guidance, indicators, buttons) remain visible.
  /// Ideal when a custom background is rendered behind the camera.
  overlay,

  /// Like [defaultMode] but all action buttons (capture, save, retake, next,
  /// previous, camera-switch) are hidden. Capture must be triggered
  /// programmatically via auto-capture or an external controller.
  /// Suitable for kiosk / embedded deployments.
  kiosk,

  /// Like [defaultMode] but with on-device OCR (text extraction) automatically
  /// enabled. The extracted text is included in [DocumentCaptureData.frontOcrText]
  /// and [DocumentCaptureData.backOcrText] when the document is saved.
  ///
  /// For all other modes, text extraction is **off** by default and can be
  /// enabled explicitly via [DocumentCameraFrame.enableExtractText].
  textExtract,

  /// Launches the platform's native document scanner UI and returns the
  /// scanned images through [onDocumentSaved].
  ///
  /// - **Android**: uses `google_mlkit_document_scanner`.
  /// - **iOS**: uses `VNDocumentCameraViewController` (requires a real device).
  ///
  /// All custom frame/styling properties are ignored in this mode.
  camScanner,
}

/// Enum to define document sides
enum DocumentSide { front, back }

/// Output format for captured documents
enum DocumentOutputFormat {
  /// JPEG format (default, backward compatible)
  jpg,

  /// PNG format (lossless compression)
  png,

  /// PDF format (multi-page document)
  pdf,

  /// TIFF format (high-quality archival format)
  tiff,
}

/// PDF page size options
enum PdfPageSize {
  /// A4 size (210 x 297 mm)
  a4,

  /// Letter size (8.5 x 11 inches)
  letter,
}
