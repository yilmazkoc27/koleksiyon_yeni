class CollectionItem {
  final String? docId;
  final String name;
  final int year;
  final String rarity;
  final String condition;
  final String material;
  final String description;
  final int value;
  final String imagePath;
  final double carat;
  final String processType;
  final String damage;
  bool isFavorite;

  CollectionItem({
    this.carat = 0,
    this.processType = '',
    this.damage = '',
    this.docId,
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

  //Dart Nesnesini Firestore'a göndermek için Map (JSON) yapısına çevirme
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'year': year,
      'rarity': rarity,
      'condition': condition,
      'material': material,
      'description': description,
      'value': value,
      'imagePath': imagePath,
      'isFavorite': isFavorite,
      'carat': carat,
      'processType': processType,
      'damage': damage,
    };
  }

  factory CollectionItem.fromMap(
    Map<String, dynamic> map, [
    String? documentId,
  ]) {
    return CollectionItem(
      docId: documentId,
      name: map['name'] ?? '',
      year: int.tryParse(map['year']?.toString() ?? '2020') ?? 2020,
      rarity: map['rarity'] ?? 'Orta',
      condition: map['condition'] ?? 'İyi',
      material: map['material'] ?? '',
      description: map['description'] ?? '',
      value: int.tryParse(map['value']?.toString() ?? '0') ?? 0,
      imagePath: map['imagePath'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
      carat: double.tryParse(map['carat']?.toString() ?? '0') ?? 0,
      processType: map['processType'] ?? '',
      damage: map['damage'] ?? '',
    );
  }
  CollectionItem copyWith({
    String? docId,
    String? name,
    int? year,
    String? rarity,
    String? condition,
    String? material,
    String? description,
    int? value,
    String? imagePath,
    bool? isFavorite,
    double? carat,
    String? processType,
    String? damage,
  }) {
    return CollectionItem(
      docId: docId ?? this.docId,
      name: name ?? this.name,
      year: year ?? this.year,
      rarity: rarity ?? this.rarity,
      condition: condition ?? this.condition,
      material: material ?? this.material,
      description: description ?? this.description,
      value: value ?? this.value,
      imagePath: imagePath ?? this.imagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      carat: carat ?? this.carat,
      processType: processType ?? this.processType,
      damage: damage ?? this.damage,
    );
  }
}
