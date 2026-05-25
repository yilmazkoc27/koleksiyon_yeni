class GemValueCalculator {
  static int calculate({
    required String gemType,

    required double carat,

    required String clarity,

    required String colorQuality,

    required String rarity,

    required String processType,

    required String damage,
  }) {
    int value = 1000;

    //TAŞ TÜRÜ

    Map<String, int> gemScore = {
      "Ametist": 1500,

      "Akik": 1200,

      "Kehribar": 2500,

      "Opal": 4000,

      "Jasper": 1800,

      "Safir": 7000,

      "Yakut": 8000,

      "Zümrüt": 7500,

      "Turkuaz": 3000,

      "Kuvars": 1000,

      "Obsidyen": 1300,

      "Lapis Lazuli": 2800,
    };

    value += gemScore[gemType] ?? 0;

    //KARAT

    value += (carat * 500).round();

    //BERRAKLIK

    Map<String, int> clarityScore = {
      "Mükemmel": 5000,

      "Çok İyi": 3500,

      "İyi": 2000,

      "Orta": 1000,

      "Düşük": 300,
    };

    value += clarityScore[clarity] ?? 0;

    //RENK

    Map<String, int> colorScore = {
      "Canlı": 3000,

      "Parlak": 2000,

      "Normal": 1000,

      "Soluk": 200,
    };

    value += colorScore[colorQuality] ?? 0;

    //NADİRLİK

    Map<String, int> rarityScore = {"Düşük": 500, "Orta": 2000, "Yüksek": 5000};

    value += rarityScore[rarity] ?? 0;

    //İŞLENME

    Map<String, int> processScore = {
      "Ham Taş": 500,

      "Kesilmiş": 2000,

      "Parlatılmış": 3000,

      "Takı Haline Getirilmiş": 4500,
    };

    value += processScore[processType] ?? 0;

    //HASAR

    Map<String, int> damageScore = {
      "Yok": 0,

      "Küçük Çatlak": -1000,

      "Belirgin Çatlak": -3000,

      "Kırık": -6000,
    };

    value += damageScore[damage] ?? 0;

    return value;
  }
}
