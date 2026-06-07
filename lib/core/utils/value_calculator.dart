class ValueCalculator {
  static int calculate({
    required int year,
    required String rarity,
    required String condition,
    required String material,
  }) {
    int value = 100;
    int currentYear = 2026;
    int age = currentYear - year;
    value += age * 25;

    Map<String, int> rarityPoints = {"Düşük": 50, "Orta": 200, "Yüksek": 600};
    value += rarityPoints[rarity] ?? 0;

    Map<String, int> conditionPoints = {
      "Çil": 1000,
      "Çil altı": 850,
      "Çok çok temiz": 700,
      "Çok temiz": 600,
      "Temiz": 500,
      "Çok iyi": 350,
      "İyi": 250,
      "Orta": 150,
      "Zayıf": 30,
    };
    value += conditionPoints[condition] ?? 0;
    Map<String, int> materialPoints = {
      "Altın": 12000,
      "Gümüş": 5900,
      "Bakır": 400,
      "Bronz": 1250,
      "Pirinç": 300,
      "Alüminyum": 250,
      "Kâğıt": 1000,
    };
    value += materialPoints[material] ?? 0;
    return value;
  }
}
