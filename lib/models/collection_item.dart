class CollectionItem {
  final String name;

  final int year;

  final String rarity;

  final String condition;

  final String material;

  final String description;

  final int value;

  final String imagePath;

  bool isFavorite;

  CollectionItem({
    required this.name,

    required this.year,

    required this.rarity,

    required this.condition,

    required this.material,

    required this.description,

    required this.value,

    required this.imagePath,

    this.isFavorite = false,
  });
}
