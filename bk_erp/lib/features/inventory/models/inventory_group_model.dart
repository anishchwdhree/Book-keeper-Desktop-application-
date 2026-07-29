class InventoryGroupModel {
  final int? id;
  final String name;
  final String description;

  InventoryGroupModel({
    this.id,
    required this.name,
    this.description = '',
  });

  InventoryGroupModel copyWith({
    int? id,
    String? name,
    String? description,
  }) {
    return InventoryGroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }
}
