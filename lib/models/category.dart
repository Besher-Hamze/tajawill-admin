class CategoryModel {
  String id;
  final String name;
  final String description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String id) {
    return CategoryModel(
      id: map['id'] ?? id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      'name': name,
      'description': description,
    };
  }

  // Equality and hashCode based on `id`
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CategoryModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}
