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
  bool isFavorite;

  CollectionItem({
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

  // 1. Dart Nesnesini Firestore'a göndermek için Map (JSON) yapısına çevirir
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
    };
  }

  // 2. Firestore'dan gelen Map (JSON) verisini Dart Nesnesine çevirir
  // HATA KESİN ÇÖZÜMÜ: [String? documentId] diyerek parametreyi köseli parantez içine aldık ve isteğe bağlı (optional) yaptık.
  // Böylece sadece tek parametre gönderilen eski kodların (Albüm vs.) hata vermesini engelledik.
  factory CollectionItem.fromMap(
    Map<String, dynamic> map, [
    String? documentId,
  ]) {
    return CollectionItem(
      docId:
          documentId, // Gönderildiyse döküman ID'si atanır, gönderilmediyse null kalır
      name: map['name'] ?? '',
      year: int.tryParse(map['year']?.toString() ?? '2020') ?? 2020,
      rarity: map['rarity'] ?? 'Orta',
      condition: map['condition'] ?? 'İyi',
      material: map['material'] ?? '',
      description: map['description'] ?? '',
      value: int.tryParse(map['value']?.toString() ?? '0') ?? 0,
      imagePath: map['imagePath'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
    );
  }

  // 3. Mevcut nesnenin değerlerini koruyarak yeni bir kopyasını üretir
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
    );
  }
}
