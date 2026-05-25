//-----------------------
// *****KÜTÜPHANELER****
//-----------------------

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/collection_item.dart';
import '../../core/utils/gem_value_calculator.dart';
import 'gems_album_screen.dart';
import '../../core/services/user_role.dart';
import '../../services/gem_service.dart';
import '../detail/item_detail_screen.dart';

class GemsScreen extends StatefulWidget {
  const GemsScreen({super.key});

  @override
  State<GemsScreen> createState() => _GemsScreenState();
}

//-----------------------
// *****STATELER****
//-----------------------

class _GemsScreenState extends State<GemsScreen> {
  int estimatedValue = 0;
  int selectedIndex = -1;
  int totalValue = 0;
  int averageValue = 0;
  bool ascending = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController caratController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  String gemType = "Ametist";
  String rarity = "Orta";
  String clarity = "İyi";
  String colorQuality = "Normal";
  String processType = "Ham Taş";
  String damage = "Yok";
  String filterRarity = "Tümü";

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    caratController.dispose();
    searchController.dispose();
    super.dispose();
  }

  //-----------------------
  // *****DEĞERLİ TAŞLAR SAYFASI****
  //-----------------------
  List<CollectionItem> getFilteredList() {
    List<CollectionItem> filtered = List.from(GemService.gemsList);

    if (searchController.text.isNotEmpty) {
      filtered = filtered.where((item) {
        return item.name.toLowerCase().contains(
          searchController.text.toLowerCase(),
        );
      }).toList();
    }

    if (filterRarity != "Tümü") {
      filtered = filtered.where((item) {
        return item.rarity == filterRarity;
      }).toList();
    }

    filtered.sort((a, b) {
      if (ascending) {
        return a.value.compareTo(b.value);
      }
      return b.value.compareTo(a.value);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = getFilteredList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Değerli Taşlar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_album),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      GemsAlbumScreen(gemsList: GemService.gemsList),
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
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 1),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.diamond, size: 80, color: AppColors.gold),
              ),
            ),
            const SizedBox(height: 25),

            //-----------------------
            // *****BİLGİ GİRİŞİ ****
            //-----------------------
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Taş Adı",
                filled: true,
                fillColor: AppColors.cardBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: gemType,
              dropdownColor: AppColors.cardBlack,
              items:
                  [
                    "Ametist",
                    "Akik",
                    "Kehribar",
                    "Opal",
                    "Jasper",
                    "Safir",
                    "Yakut",
                    "Zümrüt",
                    "Turkuaz",
                    "Kuvars",
                    "Obsidyen",
                    "Lapis Lazuli",
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
                  gemType = value!;
                });
              },
              decoration: InputDecoration(
                labelText: "Taş Türü",
                filled: true,
                fillColor: AppColors.cardBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: caratController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Karat",
                filled: true,
                fillColor: AppColors.cardBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Değerli taşlar hakkında bilgi",
                labelText: "Açıklama",
                filled: true,
                fillColor: AppColors.cardBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: rarity,
              dropdownColor: AppColors.cardBlack,
              style: const TextStyle(color: Colors.white),
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

            DropdownButtonFormField<String>(
              initialValue: clarity,
              dropdownColor: AppColors.cardBlack,
              items: ["Mükemmel", "Çok iyi", "İyi", "Orta", "Düşük"].map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  clarity = value!;
                });
              },
              decoration: InputDecoration(
                labelText: "Berraklık",
                filled: true,
                fillColor: AppColors.cardBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: colorQuality,
              dropdownColor: AppColors.cardBlack,
              items: ["Canlı", "Parlak", "Normal", "Soluk"].map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  colorQuality = value!;
                });
              },
              decoration: InputDecoration(
                labelText: "Renk Kalitesi",
                filled: true,
                fillColor: AppColors.cardBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: processType,
              dropdownColor: AppColors.cardBlack,
              items:
                  [
                    "Ham Taş",
                    "Kesilmiş",
                    "Parlatılmış",
                    "Takı Haline Getirilmiş",
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
                  processType = value!;
                });
              },
              decoration: InputDecoration(
                labelText: "İşlenme",
                filled: true,
                fillColor: AppColors.cardBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              initialValue: damage,
              dropdownColor: AppColors.cardBlack,
              items: ["Yok", "Küçük Çatlak", "Belirgin Çatlak", "Kırık"].map((
                e,
              ) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  damage = value!;
                });
              },
              decoration: InputDecoration(
                labelText: "Hasar",
                filled: true,
                fillColor: AppColors.cardBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 30),

            //-----------------------
            // *****TAHMİNİ DEĞER HESAPLAMA****
            //-----------------------
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  double carat = double.tryParse(caratController.text) ?? 1;
                  setState(() {
                    estimatedValue = GemValueCalculator.calculate(
                      gemType: gemType,
                      carat: carat,
                      clarity: clarity,
                      colorQuality: colorQuality,
                      rarity: rarity,
                      processType: processType,
                      damage: damage,
                    );
                  });
                },
                child: const Text("Tahmini Değer Hesapla"),
              ),
            ),
            const SizedBox(height: 25),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardBlack,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withGreen(
                      10,
                    ), // .withOpacity(.4) alternatif düzeltme
                    blurRadius: 15,
                  ),
                ],
              ),
              child: Text(
                "Tahmini Değer\n$estimatedValue TL",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
            ),
            const SizedBox(height: 30),

            //-----------------------
            // ***** ADMINA OZEL BUTONLAR ****
            //-----------------------
            if (UserRole.isAdmin) ...[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  // ************* EKLE BUTONU ***********
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        GemService.add(
                          CollectionItem(
                            name: nameController.text,
                            year: DateTime.now().year,
                            rarity: rarity,
                            condition: clarity,
                            material: colorQuality,
                            value: estimatedValue,
                            description: descriptionController.text,
                            imagePath: "",
                          ),
                        );
                      });
                    },
                    child: const Text("Ekle"),
                  ),

                  // ************* SİL BUTONU ***********
                  ElevatedButton(
                    onPressed: () {
                      if (selectedIndex != -1) {
                        setState(() {
                          // Seçilen elemanı filtrelenmiş listeden bulup siliyoruz
                          final itemToDelete = filteredList[selectedIndex];
                          GemService.gemsList.remove(itemToDelete);
                          selectedIndex = -1;
                        });
                      }
                    },
                    child: const Text("Sil"),
                  ),

                  // ************* GÜNCELLE BUTONU ***********
                  ElevatedButton(
                    onPressed: () {
                      if (selectedIndex != -1) {
                        setState(() {
                          final itemToUpdate = filteredList[selectedIndex];
                          final globalIndex = GemService.gemsList.indexOf(
                            itemToUpdate,
                          );
                          if (globalIndex != -1) {
                            GemService.update(
                              globalIndex,
                              CollectionItem(
                                name: nameController.text,
                                year: DateTime.now().year,
                                rarity: rarity,
                                condition: clarity,
                                material: colorQuality,
                                value: estimatedValue,
                                description: descriptionController.text,
                                imagePath: "",
                              ),
                            );
                          }
                        });
                      }
                    },
                    child: const Text("Güncelle"),
                  ),

                  // ************* TEMİZLE BUTONU ***********
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        nameController.clear();
                        descriptionController.clear();
                        caratController.clear();
                        gemType = "Ametist";
                        rarity = "Orta";
                        clarity = "İyi";
                        colorQuality = "Normal";
                        processType = "Ham Taş";
                        damage = "Yok";
                        estimatedValue = 0;
                        selectedIndex = -1;
                      });
                    },
                    child: const Text("Temizle"),
                  ),

                  // ************* LİSTELE BUTONU ***********
                  ElevatedButton(
                    onPressed: () {
                      if (GemService.gemsList.isNotEmpty) {
                        int total = 0;
                        for (var item in GemService.gemsList) {
                          total += item.value;
                        }
                        setState(() {
                          totalValue = total;
                          averageValue = (total / GemService.gemsList.length)
                              .round();
                        });
                      }
                    },
                    child: const Text("Listele"),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // ************* ISTATISTIK EKRANI ***********
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardBlack,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withAlpha(3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Toplam Ürün: ${GemService.gemsList.length}",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Toplam Değer: $totalValue TL",
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Ortalama: $averageValue TL",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // ************* LİSTELEME VE FİLTRELEME EKRANI ***********
              TextField(
                controller: searchController,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  labelText: "Taş Ara",
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
              const SizedBox(height: 20),

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
                      selected: selectedIndex == index,
                      onTap: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) => ItemDetailScreen(item: item),
                          ),
                        );
                      },
                      leading: const Icon(Icons.diamond, color: AppColors.gold),
                      title: Text(item.name),
                      subtitle: Text("${item.description}\n${item.value} TL"),
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
                                GemService.delete(index);
                                if (selectedIndex == index) {
                                  selectedIndex = -1;
                                }
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
          ],
        ),
      ),
    );
  }
}
