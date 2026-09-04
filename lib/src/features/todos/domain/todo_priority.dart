enum TodoPriority {
  high,
  medium,
  low,
  none;

  int get sortRank => switch (this) {
    high => 0,
    medium => 1,
    low => 2,
    none => 3,
  };
}
