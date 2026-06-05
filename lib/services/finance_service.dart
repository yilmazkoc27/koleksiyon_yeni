import 'dart:convert';
import 'package:http/http.dart' as http;

class FinanceService {
  // Ücretsiz ve API Key gerektirmeyen güncel döviz servis sağlayıcısı
  static const String _apiUrl = "https://open.er-api.com/v6/latest/USD";

  static Future<Map<String, double>> fetchLiveRates() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rates = data['rates'] as Map<String, dynamic>;

        // Servis taban olarak USD (Dolar) döndürür.
        // Buradan TL (TRY) ve Euro (EUR) kurlarını hesaplıyoruz.
        double usdToTry = rates['TRY']?.toDouble() ?? 1.0;
        double usdToEur = rates['EUR']?.toDouble() ?? 1.0;

        // 1 Euro kaç TL? (Çapraz kur hesaplama)
        double eurToTry = usdToTry / usdToEur;

        // Altın (XAU) onsu dolar cinsindendir. Gram altına çevirmek için:
        // (Ons Fiyatı / 31.1035) * Dolar Kuru
        double usdToXau = rates['XAU']?.toDouble() ?? 0.0;
        double gramGoldToTry = 0.0;
        if (usdToXau > 0) {
          double onsPriceUsd = 1 / usdToXau; // Ons fiyatını bul
          gramGoldToTry = (onsPriceUsd / 31.1035) * usdToTry;
        }

        return {'USD': usdToTry, 'EUR': eurToTry, 'GOLD': gramGoldToTry};
      } else {
        throw Exception("Kurlar yüklenemedi");
      }
    } catch (e) {
      // İnternet olmaması durumuna karşı varsayılan (yaklaşık) kurlar (Uygulama çökmesin diye)
      return {'USD': 46.50, 'EUR': 54.20, 'GOLD': 6650.0};
    }
  }
}
