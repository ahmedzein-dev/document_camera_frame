/// Model to hold captured document data (one-sided e.g. passport, or two-sided e.g. ID).
class DocumentCaptureData {
  final String? frontImagePath;
  final String? backImagePath;

  /// Extracted text from the front image when [DocumentCameraFrame.enableExtractText] is true.
  final String? frontOcrText;

  /// Extracted text from the back image when [DocumentCameraFrame.enableExtractText] is true.
  final String? backOcrText;
  final bool isComplete;

  DocumentCaptureData({
    this.frontImagePath,
    this.backImagePath,
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
    String? frontOcrText,
    String? backOcrText,
  }) {
    return DocumentCaptureData(
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
      frontOcrText: frontOcrText ?? this.frontOcrText,
      backOcrText: backOcrText ?? this.backOcrText,
    );
  }

  /// Check if at least the front side is captured
  bool get hasFrontSide => frontImagePath != null && frontImagePath!.isNotEmpty;

  /// Check if the back side is captured
  bool get hasBackSide => backImagePath != null && backImagePath!.isNotEmpty;

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
    return 'DocumentCaptureData(frontImagePath: $frontImagePath, backImagePath: $backImagePath, frontOcrText: ${frontOcrText != null ? "[${frontOcrText!.length} chars]" : null}, backOcrText: ${backOcrText != null ? "[${backOcrText!.length} chars]" : null}, isComplete: $isComplete)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DocumentCaptureData &&
        other.frontImagePath == frontImagePath &&
        other.backImagePath == backImagePath &&
        other.frontOcrText == frontOcrText &&
        other.backOcrText == backOcrText;
  }

  @override
  int get hashCode =>
      frontImagePath.hashCode ^
      backImagePath.hashCode ^
      frontOcrText.hashCode ^
      backOcrText.hashCode;
}
