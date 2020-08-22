class LinearSpace {
  final List<double> data;
  int get length => data.length;
  double get start => data.first;
  double get end => data.last;

  LinearSpace({
    double start,
    double end,
    int length,
  }) : data = _discretize(start: start, end: end, length: length);

  static List<double> _discretize({double start, double end, int length}) {
    final double dx = (end - start) / (length - 1);
    return List<double>.generate(length, (index) => start + dx * index);
  }

  double operator [](int index) {
    return data[index];
  }
}
