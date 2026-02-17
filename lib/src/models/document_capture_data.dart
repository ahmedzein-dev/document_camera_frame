/// Model to hold captured document data (one-sided e.g. passport, or two-sided e.g. ID).
class DocumentCaptureData {
  final String? frontImagePath;
  final String? backImagePath;
  final String? frontPreviewPath;
  final String? backPreviewPath;

  /// Path to the generated PDF file when output format is PDF
  final String? pdfPath;

  /// Extracted text from the front image when [DocumentCameraFrame.enableExtractText] is true.
  final String? frontOcrText;

  /// Extracted text from the back image when [DocumentCameraFrame.enableExtractText] is true.
  final String? backOcrText;
  final bool isComplete;

  DocumentCaptureData({
    this.frontImagePath,
    this.backImagePath,
    this.frontPreviewPath,
    this.backPreviewPath,
    this.pdfPath,
    this.frontOcrText,
    this.backOcrText,
  }) : isComplete =
           frontImagePath != null &&
           frontImagePath.isNotEmpty &&
           backImagePath != null &&
           backImagePath.isNotEmpty;

  /// Create a copy of this object with some fields replaced with new values
  DocumentCaptureData copyWith({
    String? frontImagePath,
    String? backImagePath,
    String? frontPreviewPath,
    String? backPreviewPath,
    String? pdfPath,
    String? frontOcrText,
    String? backOcrText,
  }) {
    return DocumentCaptureData(
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      frontPreviewPath: frontPreviewPath ?? this.frontPreviewPath,
      backPreviewPath: backPreviewPath ?? this.backPreviewPath,
      pdfPath: pdfPath ?? this.pdfPath,
      frontOcrText: frontOcrText ?? this.frontOcrText,
      backOcrText: backOcrText ?? this.backOcrText,
    );
  }

  /// Check if at least the front side is captured
  bool get hasFrontSide => frontImagePath != null && frontImagePath!.isNotEmpty;

  /// Check if the back side is captured
  bool get hasBackSide => backImagePath != null && backImagePath!.isNotEmpty;

  /// Check if a PDF was generated
  bool get hasPdf => pdfPath != null && pdfPath!.isNotEmpty;

  /// Check if front OCR text exists
  bool get hasFrontText => frontOcrText != null && frontOcrText!.isNotEmpty;

  /// Check if back OCR text exists
  bool get hasBackText => backOcrText != null && backOcrText!.isNotEmpty;

  /// Check if document capture is complete based on requirements
  bool isCompleteFor({required bool requireBothSides}) {
    if (requireBothSides) {
      return isComplete;
    } else {
      return hasFrontSide;
    }
  }

  @override
  String toString() {
    return 'DocumentCaptureData(frontImagePath: $frontImagePath, backImagePath: $backImagePath, frontPreviewPath: $frontPreviewPath, backPreviewPath: $backPreviewPath, pdfPath: $pdfPath, frontOcrText: ${frontOcrText != null ? "[${frontOcrText!.length} chars]" : null}, backOcrText: ${backOcrText != null ? "[${backOcrText!.length} chars]" : null}, isComplete: $isComplete)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DocumentCaptureData &&
        other.frontImagePath == frontImagePath &&
        other.backImagePath == backImagePath &&
        other.frontPreviewPath == frontPreviewPath &&
        other.backPreviewPath == backPreviewPath &&
        other.pdfPath == pdfPath &&
        other.frontOcrText == frontOcrText &&
        other.backOcrText == backOcrText;
  }

  @override
  int get hashCode =>
      frontImagePath.hashCode ^
      backImagePath.hashCode ^
      frontPreviewPath.hashCode ^
      backPreviewPath.hashCode ^
      pdfPath.hashCode ^
      frontOcrText.hashCode ^
      backOcrText.hashCode;
}
