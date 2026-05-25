class ValueCalculator {
  static int calculate({
    required int year,
    required String rarity,
    required String condition,
    required String material,
  }) {
    int value = 100;

    // YIL

    int currentYear = 2026;
    int age = currentYear - year;
    value += age * 25;

    // NADİRLİK
    Map<String, int> rarityPoints = {"Düşük": 50, "Orta": 200, "Yüksek": 600};
    value += rarityPoints[rarity] ?? 0;

    // KONDİSYON

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

    // MALZEME

    Map<String, int> materialPoints = {
      "Altın": 5000,
      "Gümüş": 2500,
      "Bakır": 400,
      "Bronz": 250,
      "Pirinç": 150,
      "Alüminyum": 80,
      "Kâğıt": 50,
    };

    value += materialPoints[material] ?? 0;

    return value;
  }
}
