/// Represents a numeric range with lower and upper bounds.
/// Used throughout the RandomColor library to define valid ranges for color properties
/// such as hue, saturation, and brightness.
class Range {
  /// The lower bound of the range.
  /// Can be null if the range has no lower bound.
  int? lower;

  /// The upper bound of the range.
  /// Can be null if the range has no upper bound.
  int? upper;

  /// Creates a new Range with optional lower and upper bounds.
  ///
  /// [lower] - The lower bound of the range
  /// [upper] - The upper bound of the range
  Range({this.lower, this.upper});

  /// Gets a value from the range based on an index.
  ///
  /// Returns:
  /// - lower bound when index is 0
  /// - upper bound when index is 1
  /// - 0 for any other index
  int? get index {
    switch (index) {
      case 0:
        return lower;
      case 1:
        return upper;
      default:
    }
    return 0;
  }

  /// Sets a value in the range based on an index.
  ///
  /// [value] - The value to set
  /// - Sets lower bound when index is 0
  /// - Sets upper bound when index is 1
  /// - Ignores other indices
  set index(int? value) {
    switch (value) {
      case 0:
        lower = value;
        break;
      case 1:
        upper = value;
        break;
      default:
    }
  }

  /// Creates a Range from a list of two integers.
  ///
  /// [range] - List containing exactly two integers where:
  ///   - First element becomes the lower bound
  ///   - Second element becomes the upper bound
  ///
  /// Returns a new Range object with the specified bounds.
  factory Range.toRange(List<int> range) {
    return Range(
      lower: range[0],
      upper: range[1],
    );
  }
}
