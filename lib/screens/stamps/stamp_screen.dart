//-----------------------
// *****KÜTÜPHANELER****
//-----------------------

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';
import '../../models/collection_item.dart';
import '../../core/utils/stamp_value_calculator.dart';
import 'stamp_album_screen.dart';
import '../../core/services/user_role.dart';
import '../detail/item_detail_screen.dart';

class StampScreen extends StatefulWidget {
  const StampScreen({super.key});

  @override
  State<StampScreen> createState() => _StampScreenState();
}

class _StampScreenState extends State<StampScreen> {
  int estimatedValue = 0;

  // Seçili elemanın Firestore doküman ID'sini hafızada tutuyoruz
  String? selectedDocId;

  int totalValue = 0;
  int averageValue = 0;
  bool ascending = true;
  bool _isUploading =
      false; // Bulut işlemleri sırasında yükleniyor animasyonu için

  final TextEditingController nameController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController printCountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String productType = "Anma Pulu";
  String rarity = "Orta";
  String condition = "İyi";
  String printError = "Yok";
  String filterRarity = "Tümü";

  // 🔥 Firestore'a Pul Ekleme Fonksiyonu
  Future<void> _addStampToFirestore() async {
    if (nameController.text.trim().isEmpty ||
        yearController.text.trim().isEmpty) {
      _showSnackBar(
        "Lütfen pul adı ve baskı yılı alanlarını doldurun!",
        Colors.orange,
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      int year = int.tryParse(yearController.text) ?? 2020;
      int printCount = int.tryParse(printCountController.text) ?? 10000;

      await FirebaseFirestore.instance.collection('Pullar').add({
        'name': nameController.text.trim(),
        'year': year,
        'printCount': printCount,
        'rarity': rarity,
        'condition': condition,
        'printError': printError,
        'material':
            productType, // Modelinizde material alanına karşılık geliyor
        'description': descriptionController.text.trim(),
        'value': estimatedValue,
        'isFavorite': false,
        'imagePath':
            '', // Detay ekranında çökmemesi için boş string veya varsayılan link ekliyoruz
        'createdAt': FieldValue.serverTimestamp(),
      });

      _clearForm();
      _showSnackBar("Pul başarıyla buluta eklendi!", Colors.green);
    } catch (e) {
      _showSnackBar("Ekleme hatası: $e", Colors.red);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // 🔥 Firestore'daki Pulu Güncelleme Fonksiyonu
  Future<void> _updateStampInFirestore() async {
    if (selectedDocId == null) {
      _showSnackBar(
        "Lütfen listeden güncellenecek bir pul seçin!",
        Colors.orange,
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      int year = int.tryParse(yearController.text) ?? 2020;
      int printCount = int.tryParse(printCountController.text) ?? 10000;

      await FirebaseFirestore.instance
          .collection('Pullar')
          .doc(selectedDocId)
          .update({
            'name': nameController.text.trim(),
            'year': year,
            'printCount': printCount,
            'rarity': rarity,
            'condition': condition,
            'printError': printError,
            'material': productType,
            'description': descriptionController.text.trim(),
            'value': estimatedValue,
          });

      _clearForm();
      _showSnackBar("Pul başarıyla güncellendi!", Colors.green);
    } catch (e) {
      _showSnackBar("Güncelleme hatası: $e", Colors.red);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // 🔥 Firestore'dan Pul Silme Fonksiyonu
  Future<void> _deleteStampFromFirestore(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('Pullar').doc(docId).delete();
      if (selectedDocId == docId) {
        _clearForm();
      }
      _showSnackBar("Pul başarıyla silindi!", Colors.green);
    } catch (e) {
      _showSnackBar("Silme hatası: $e", Colors.red);
    }
  }

  // Form alanlarını sıfırlar
  void _clearForm() {
    setState(() {
      nameController.clear();
      descriptionController.clear();
      yearController.clear();
      printCountController.clear();
      rarity = "Orta";
      condition = "İyi";
      printError = "Yok";
      productType = "Anma Pulu";
      estimatedValue = 0;
      selectedDocId = null;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  void dispose() {
    nameController.dispose();
    yearController.dispose();
    printCountController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pul Koleksiyonu"),
        actions: [
          // 🛠 HATA ÇÖZÜMÜ 1: Stream'den doldurduğumuz listenin en güncel halini albüm sayfasına paslıyoruz.
          // Listenin snapshot scope'u dışında doğrudan erişilebilmesi için geçici bir builder mantığı kurduk veya mevcut akıştan yararlanacağız.
          // Aşağıdaki StreamBuilder içindeki listeyi buraya aktarabilmek için allStamps listesini yukarıda boş tutup doldurabiliriz,
          // ya da albüm butonunu direkt liste görünümünün yanına/başına koyabiliriz.
          // Ancak en temiz yöntem, burada bir "Builder" verisi varmış gibi hareket etmektir.
          // Aşağıda snapshot içinden gelen güncel listeyi (allStamps) bu butona bağlamak için bir callback yöntemi kullanacağız.
        ],
      ),
      body: _isUploading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Pullar')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Hata oluştu"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  );
                }

                List<CollectionItem> allStamps = [];

                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  final item = CollectionItem.fromMap(data, doc.id);
                  allStamps.add(item);
                }

                // ARAMA VE FİLTRELEME İŞLEMLERİ
                List<CollectionItem> filteredList = List.from(allStamps);
                if (searchController.text.isNotEmpty) {
                  filteredList = filteredList
                      .where(
                        (item) => item.name.toLowerCase().contains(
                          searchController.text.toLowerCase(),
                        ),
                      )
                      .toList();
                }
                if (filterRarity != "Tümü") {
                  filteredList = filteredList
                      .where((item) => item.rarity == filterRarity)
                      .toList();
                }

                filteredList.sort(
                  (a, b) => ascending
                      ? a.value.compareTo(b.value)
                      : b.value.compareTo(a.value),
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Albüm Açma Butonunu Firestore verisinin geldiği bu alana Row ile ekliyoruz ki pulları alabilsin.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Koleksiyon İşlemleri",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.photo_album,
                              color: AppColors.gold,
                              size: 28,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // 🛠 HATA ÇÖZÜMÜ 1: const kaldırıldı ve Firestore'dan gelen güncel liste parametre verildi.
                                  builder: (_) =>
                                      StampAlbumScreen(stampList: allStamps),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      Container(
                        height: 170,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.cardBlack,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: const [
                            BoxShadow(color: AppColors.gold, blurRadius: 15),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.mail,
                            size: 80,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // ÜRÜN ADI
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Pul Adı",
                          filled: true,
                          fillColor: AppColors.cardBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // AÇIKLAMA
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Ürün Hakkında Bilgi",
                          filled: true,
                          fillColor: AppColors.cardBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // ÜRÜN TÜRÜ
                      DropdownButtonFormField<String>(
                        value: productType,
                        dropdownColor: AppColors.cardBlack,
                        style: const TextStyle(color: Colors.white),
                        items:
                            [
                                  "Portföy",
                                  "Anma Pulu İlk Gün Zarfı",
                                  "Anma Pulu",
                                  "Özel Gün Zarfı",
                                  "İlk Gün Zarfı",
                                  "Özel Gün Pulu",
                                  "İlk Gün Pulu Zarfı",
                                  "Sürekli Posta Pulu",
                                  "Sürekli Posta Pulu Zarfı",
                                  "Anma Bloku",
                                  "Anma Bloku İlk Gün Zarfı",
                                  "Maksimum Kart",
                                  "Özel Tarih Damgalı Zarf",
                                  "Tebrik Kartı",
                                ]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) =>
                            setState(() => productType = value!),
                        decoration: InputDecoration(
                          labelText: "Ürün Türü",
                          filled: true,
                          fillColor: AppColors.cardBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // BASKI ADETI
                      TextField(
                        controller: printCountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Baskı Adeti",
                          filled: true,
                          fillColor: AppColors.cardBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // BASKI YILI
                      TextField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Baskı Yılı",
                          filled: true,
                          fillColor: AppColors.cardBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // NADİRLİK
                      DropdownButtonFormField<String>(
                        value: rarity,
                        dropdownColor: AppColors.cardBlack,
                        style: const TextStyle(color: Colors.white),
                        items: ["Düşük", "Orta", "Yüksek"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => rarity = value!),
                        decoration: InputDecoration(
                          labelText: "Nadirlik",
                          filled: true,
                          fillColor: AppColors.cardBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // KONDİSYON
                      DropdownButtonFormField<String>(
                        value: condition,
                        dropdownColor: AppColors.cardBlack,
                        style: const TextStyle(color: Colors.white),
                        items: ["Mükemmel", "Çok İyi", "İyi", "Orta", "Kötü"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => condition = value!),
                        decoration: InputDecoration(
                          labelText: "Kondisyon",
                          filled: true,
                          fillColor: AppColors.cardBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // HATALARI BASKI
                      DropdownButtonFormField<String>(
                        value: printError,
                        dropdownColor: AppColors.cardBlack,
                        style: const TextStyle(color: Colors.white),
                        items:
                            ["Yok", "Ters Baskı", "Eksik Renk", "Kaymış Baskı"]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) =>
                            setState(() => printError = value!),
                        decoration: InputDecoration(
                          labelText: "Hatalı Baskı",
                          filled: true,
                          fillColor: AppColors.cardBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            int year =
                                int.tryParse(yearController.text) ?? 2020;
                            int printCount =
                                int.tryParse(printCountController.text) ??
                                10000;

                            setState(() {
                              estimatedValue = StampValueCalculator.calculate(
                                year: year,
                                printCount: printCount,
                                rarity: rarity,
                                condition: condition,
                                printError: printError,
                              );
                            });
                          },
                          child: const Text("Tahmini Değer Hesapla"),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.cardBlack,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "Tahmini Değer\n$estimatedValue TL",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 25,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      if (UserRole.isAdmin)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton(
                              onPressed: _addStampToFirestore,
                              child: const Text("Ekle"),
                            ),
                            ElevatedButton(
                              onPressed: _updateStampInFirestore,
                              child: const Text("Güncelle"),
                            ),
                            ElevatedButton(
                              onPressed: _clearForm,
                              child: const Text("Temizle"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (allStamps.isNotEmpty) {
                                  int total = 0;
                                  for (var item in allStamps) {
                                    total += item.value;
                                  }
                                  setState(() {
                                    totalValue = total;
                                    averageValue = (total / allStamps.length)
                                        .round();
                                  });
                                }
                              },
                              child: const Text("Listele"),
                            ),
                          ],
                        ),
                      const SizedBox(height: 30),

                      TextField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: "Pul Ara",
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppColors.cardBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      DropdownButtonFormField<String>(
                        value: filterRarity,
                        dropdownColor: AppColors.cardBlack,
                        style: const TextStyle(color: Colors.white),
                        items: ["Tümü", "Düşük", "Orta", "Yüksek"]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => filterRarity = value!),
                        decoration: InputDecoration(
                          labelText: "Nadirlik Filtresi",
                          filled: true,
                          fillColor: AppColors.cardBlack,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      ElevatedButton(
                        onPressed: () => setState(() => ascending = !ascending),
                        child: Text(
                          ascending ? "Değer: Artan" : "Değer: Azalan",
                        ),
                      ),
                      const SizedBox(height: 15),

                      const Text(
                        "Koleksiyon Listesi",
                        style: TextStyle(
                          fontSize: 22,
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final item = filteredList[index];
                          final docId = item.docId ?? '';

                          return Card(
                            color: selectedDocId == docId
                                ? AppColors.gold.withOpacity(0.2)
                                : null,
                            // 🛠 HATA ÇÖZÜMÜ 2: "ListTile = ListTile" olan hatalı atama kaldırıldı, doğrudan ListTile çağrıldı.
                            child: ListTile(
                              selected: selectedDocId == docId,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ItemDetailScreen(item: item),
                                  ),
                                );
                              },
                              onLongPress: () {
                                if (UserRole.isAdmin) {
                                  setState(() {
                                    selectedDocId = docId;
                                    nameController.text = item.name;
                                    descriptionController.text =
                                        item.description;
                                    yearController.text = item.year.toString();
                                    printCountController.text = "10000";
                                    rarity = item.rarity;
                                    condition = item.condition;
                                    productType = item.material;
                                    estimatedValue = item.value;
                                  });
                                }
                              },
                              leading: const Icon(
                                Icons.mail,
                                color: AppColors.gold,
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "${item.year} - ${item.material}\n${item.value} TL",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      item.isFavorite
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: AppColors.gold,
                                    ),
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('Pullar')
                                          .doc(docId)
                                          .update({
                                            'isFavorite': !item.isFavorite,
                                          });
                                    },
                                  ),
                                  if (UserRole.isAdmin)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _deleteStampFromFirestore(docId),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
