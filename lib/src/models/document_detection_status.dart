/// Represents the alignment guidance state of a document within the camera frame.
///
/// Emitted alongside the human-readable [onStatusUpdated] string so callers
/// can branch on known states rather than parsing text.
///
/// Priority order when multiple conditions are true:
///   [aligned] > size ([tooSmall] / [tooLarge]) > overflow > directional
enum DocumentDetectionStatus {
  /// No document was detected in the camera frame.
  noDocumentFound,

  /// Document is perfectly aligned — ready for capture.
  aligned,

  /// Document fills too little of the frame — user should move closer.
  tooSmall,

  /// Document fills too much of the frame — user should move farther away.
  tooLarge,

  /// Document is too far to the left — user should move right.
  tooFarLeft,

  /// Document is too far to the right — user should move left.
  tooFarRight,

  /// Document is too high — user should tilt/move down.
  tooHigh,

  /// Document is too low — user should tilt/move up.
  tooLow,

  /// Document overflows both the top and bottom edges of the frame.
  documentOverflows,

  /// Fallback — position needs adjustment but no specific direction is dominant.
  adjustPosition,
}
