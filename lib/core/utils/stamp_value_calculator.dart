class StampValueCalculator {
  static int calculate({
    required int year,
    required int printCount,
    required String rarity,
    required String condition,
    required String printError,
  }) {
    int value = 1000;
    int age = DateTime.now().year - year;
    value += age * 20;
    if (printCount < 1000) {
      value += 6000;
    } else if (printCount < 10000) {
      value += 3000;
    } else {
      value += 1000;
    }
    Map<String, int> rarityScore = {"Düşük": 500, "Orta": 2000, "Yüksek": 5000};

    value += rarityScore[rarity] ?? 0;
    Map<String, int> conditionScore = {
      "Mükemmel": 5000,
      "Çok İyi": 3500,
      "İyi": 2500,
      "Orta": 1000,
      "Kötü": 200,
    };

    value += conditionScore[condition] ?? 0;
    Map<String, int> errorScore = {
      "Yok": 0,
      "Ters Baskı": 8000,
      "Eksik Renk": 5000,
      "Kaymış Baskı": 4000,
    };
    value += errorScore[printError] ?? 0;
    return value;
  }
}
