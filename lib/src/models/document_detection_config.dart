/// Configuration for document alignment detection thresholds used by
/// [DocumentDetectionService] during auto-capture.
final class DocumentDetectionConfig {
  /// Minimum ratio of the detected object area to the frame area.
  ///
  /// Objects smaller than this threshold are considered too far from the camera
  /// and trigger a "Move closer" hint. Defaults to `0.50` (50 %).
  final double minSizeRatio;

  /// Maximum ratio of the detected object area to the frame area.
  ///
  /// Objects larger than this threshold are considered too close and trigger a
  /// "Move farther away" hint. Defaults to `0.70` (70 %).
  final double maxSizeRatio;

  /// Position tolerance as a fraction of the frame bounds.
  ///
  /// `0.0` means the detected object must lie strictly within the frame.
  /// Increase slightly (e.g. `0.05`) to allow a minor border overrun.
  /// Defaults to `0.0`.
  final double frameTolerance;

  const DocumentDetectionConfig({this.minSizeRatio = 0.50, this.maxSizeRatio = 0.70, this.frameTolerance = 0.0})
    : assert(minSizeRatio >= 0.0 && minSizeRatio <= 1.0),
      assert(maxSizeRatio > 0.0 && maxSizeRatio <= 1.0),
      assert(minSizeRatio < maxSizeRatio),
      assert(frameTolerance >= 0.0 && frameTolerance <= 1.0);
}
