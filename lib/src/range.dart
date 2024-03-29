class Range {
  int? lower;
  int? upper;

  Range({this.lower, this.upper});
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

  factory Range.toRange(List<int> range) {
    return Range(
      lower: range[0],
      upper: range[1],
    );
  }
}
