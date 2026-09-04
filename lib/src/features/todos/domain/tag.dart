final class Tag {
  const Tag({
    required this.id,
    required this.name,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
    this.sortOrder = 0,
    this.deletedAt,
    this.revision = 1,
  });

  final String id;
  final String name;
  final int colorValue;
  final double sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int revision;
}
