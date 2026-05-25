//-----------------------
// *****KÜTÜPHANELER****
//-----------------------

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/collection_item.dart';
import '../../core/utils/stamp_value_calculator.dart';
import 'stamp_album_screen.dart';
import '../../core/services/user_role.dart';
import '../../services/stamp_service.dart';
import '../detail/item_detail_screen.dart';

class StampScreen extends StatefulWidget {
  const StampScreen({super.key});

  @override
  State<StampScreen> createState() => _StampScreenState();
}

class _StampScreenState extends State<StampScreen> {
  int estimatedValue = 0;

  // Seçili olan elemanı index yerine doğrudan nesne (object) olarak tutuyoruz.
  // Böylece filtreleme yapsak bile doğru eleman hafızada kalmaya devam eder.
  CollectionItem? selectedItem;

  int totalValue = 0;
  int averageValue = 0;
  bool ascending = true;

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

  List<CollectionItem> getFilteredList() {
    List<CollectionItem> filtered = List.from(StampService.stampList);

    // İSİM ARAMA
    if (searchController.text.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(
          searchController.text.toLowerCase(),
        );
      }).toList();
    }

    // NADİRLİK
    if (filterRarity != "Tümü") {
      filtered = filtered.where((item) {
        return item.rarity == filterRarity;
      }).toList();
    }

    // SIRALAMA
    filtered.sort((a, b) {
      if (ascending) {
        return a.value.compareTo(b.value);
      }
      return b.value.compareTo(a.value);
    });

    return filtered;
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
    final filteredList = getFilteredList();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pul Koleksiyonu"),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_album),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      StampAlbumScreen(stampList: StampService.stampList),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 170,
              decoration: BoxDecoration(
                color: AppColors.cardBlack,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [
                  BoxShadow(color: AppColors.gold, blurRadius: 15),
                ],
              ),
              child: const Center(
                child: Icon(Icons.mail, size: 80, color: AppColors.gold),
              ),
            ),
            const SizedBox(height: 25),

            // ÜRÜN ADI
            TextField(
              controller: nameController,
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
              initialValue: productType,
              dropdownColor: AppColors.cardBlack,
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
                  ].map((e) {
                    return DropdownMenuItem(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  productType = value!;
                });
              },
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

            // BASKI ADETİ
            TextField(
              controller: printCountController,
              keyboardType: TextInputType.number,
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
              initialValue: rarity,
              dropdownColor: AppColors.cardBlack,
              items: ["Düşük", "Orta", "Yüksek"].map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  rarity = value!;
                });
              },
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
              initialValue: condition,
              dropdownColor: AppColors.cardBlack,
              items: ["Mükemmel", "Çok İyi", "İyi", "Orta", "Kötü"].map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  condition = value!;
                });
              },
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
              initialValue: printError,
              dropdownColor: AppColors.cardBlack,
              items: ["Yok", "Ters Baskı", "Eksik Renk", "Kaymış Baskı"].map((
                e,
              ) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  printError = value!;
                });
              },
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
                  int year = int.tryParse(yearController.text) ?? 2020;
                  int printCount =
                      int.tryParse(printCountController.text) ?? 10000;

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
                style: const TextStyle(fontSize: 25, color: AppColors.gold),
              ),
            ),
            const SizedBox(height: 30),

            if (UserRole.isAdmin)
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  // EKLE
                  ElevatedButton(
                    onPressed: () {
                      int year = int.tryParse(yearController.text) ?? 2020;
                      StampService.add(
                        CollectionItem(
                          name: nameController.text,
                          year: year,
                          rarity: rarity,
                          condition: condition,
                          material: productType,
                          description: descriptionController.text,
                          imagePath: "",
                          value: estimatedValue,
                        ),
                      );
                      setState(() {});
                    },
                    child: const Text("Ekle"),
                  ),

                  // SİL (Seçili eleman üzerinden kontrol)
                  ElevatedButton(
                    onPressed: () {
                      if (selectedItem != null) {
                        setState(() {
                          StampService.stampList.remove(selectedItem);
                          selectedItem = null;
                        });
                      }
                    },
                    child: const Text("Sil"),
                  ),

                  // GÜNCELLE
                  ElevatedButton(
                    onPressed: () {
                      if (selectedItem != null) {
                        int year = int.tryParse(yearController.text) ?? 2020;
                        // Ana listedeki eski nesnenin index'ini bulup güncelliyoruz
                        int mainIndex = StampService.stampList.indexOf(
                          selectedItem!,
                        );

                        if (mainIndex != -1) {
                          setState(() {
                            final updatedItem = CollectionItem(
                              name: nameController.text,
                              year: year,
                              rarity: rarity,
                              condition: condition,
                              material: productType,
                              description: descriptionController.text,
                              imagePath: "",
                              value: estimatedValue,
                            );
                            StampService.update(mainIndex, updatedItem);
                            selectedItem = updatedItem; // Seçimi yenile
                          });
                        }
                      }
                    },
                    child: const Text("Güncelle"),
                  ),

                  // TEMİZLE
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        nameController.clear();
                        descriptionController.clear();
                        yearController.clear();
                        printCountController.clear();
                        rarity = "Orta";
                        condition = "İyi";
                        printError = "Yok";
                        estimatedValue = 0;
                        selectedItem = null;
                      });
                    },
                    child: const Text("Temizle"),
                  ),

                  // LİSTELE / ANALİZ ET
                  ElevatedButton(
                    onPressed: () {
                      if (StampService.stampList.isNotEmpty) {
                        int total = 0;
                        for (var item in StampService.stampList) {
                          total += item.value;
                        }
                        setState(() {
                          totalValue = total;
                          averageValue = (total / StampService.stampList.length)
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
              onChanged: (_) {
                setState(() {});
              },
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
              initialValue: filterRarity,
              dropdownColor: AppColors.cardBlack,
              items: ["Tümü", "Düşük", "Orta", "Yüksek"].map((e) {
                return DropdownMenuItem(value: e, child: Text(e));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  filterRarity = value!;
                });
              },
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
              onPressed: () {
                setState(() {
                  ascending = !ascending;
                });
              },
              child: Text(ascending ? "Değer: Artan" : "Değer: Azalan"),
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

                return Card(
                  child: ListTile(
                    // Nesne eşleşmesiyle seçimi doğruluyoruz
                    selected: selectedItem == item,
                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) => ItemDetailScreen(item: item),
                        ),
                      );
                    },
                    leading: const Icon(Icons.mail, color: AppColors.gold),
                    title: Text(item.name),
                    subtitle: Text(
                      "${item.year}\n${item.material}\n${item.value} TL",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,

                      children: [
                        IconButton(
                          icon: Icon(
                            item.isFavorite ? Icons.star : Icons.star_border,

                            color: AppColors.gold,
                          ),

                          onPressed: () {
                            setState(() {
                              item.isFavorite = !item.isFavorite;
                            });
                          },
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),

                          onPressed: () {
                            setState(() {
                              StampService.delete(index);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
