/// Enum to define animation phases
enum AnimationPhase { downward, flipToBack, upward }

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
