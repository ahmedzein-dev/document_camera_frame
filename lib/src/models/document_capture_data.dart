/// Model to hold captured document data for two-sided documents
class DocumentCaptureData {
  final String? frontImagePath;
  final String? backImagePath;
  final bool isComplete;

  DocumentCaptureData({
    this.frontImagePath,
    this.backImagePath,
  }) : isComplete = frontImagePath != null &&
            frontImagePath.isNotEmpty &&
            backImagePath != null &&
            backImagePath.isNotEmpty;

  /// Create a copy of this object with some fields replaced with new values
  DocumentCaptureData copyWith({
    String? frontImagePath,
    String? backImagePath,
  }) {
    return DocumentCaptureData(
      frontImagePath: frontImagePath ?? this.frontImagePath,
      backImagePath: backImagePath ?? this.backImagePath,
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
    return 'DocumentCaptureData(frontImagePath: $frontImagePath, backImagePath: $backImagePath, isComplete: $isComplete)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DocumentCaptureData &&
        other.frontImagePath == frontImagePath &&
        other.backImagePath == backImagePath;
  }

  @override
  int get hashCode => frontImagePath.hashCode ^ backImagePath.hashCode;
}
