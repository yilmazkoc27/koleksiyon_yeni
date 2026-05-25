import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/value_calculator.dart';
import '../../models/collection_item.dart';
import 'coin_album_screen.dart';
import '../../core/services/user_role.dart';
import '../../services/coin_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../detail/item_detail_screen.dart';

class CoinScreen extends StatefulWidget {
  const CoinScreen({super.key});

  @override
  State<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends State<CoinScreen> {
  int estimatedValue = 0;
  int selectedIndex = -1; // Orijinal listedeki seçili indeks
  int totalValue = 0;
  int averageValue = 0;
  bool ascending = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  String rarity = "Orta";
  String condition = "Temiz";
  String material = "Bronz";
  String filterRarity = "Tümü";
  String imagePath = "";

  File? selectedImage;

  @override
  void dispose() {
    nameController.dispose();
    yearController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  List<CollectionItem> getFilteredList() {
    List<CollectionItem> filtered = List.from(CoinService.coinList);

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

  Future pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        imagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = getFilteredList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hatıra Paralar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_album),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CoinAlbumScreen(coins: CoinService.coinList),
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
                  BoxShadow(color: AppColors.gold.withBlue(3), blurRadius: 15),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.monetization_on,
                  size: 80,
                  color: AppColors.gold,
                ),
              ),
            ),
            const SizedBox(height: 25),

            GestureDetector(
              onTap: pickImage,

              child: Container(
                height: 140,

                width: double.infinity,

                decoration: BoxDecoration(
                  color: AppColors.cardBlack,

                  borderRadius: BorderRadius.circular(20),

                  border: Border.all(color: AppColors.gold),
                ),

                child: selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: AppColors.gold,
                          ),

                          SizedBox(height: 10),

                          Text("Fotoğraf Ekle"),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),

                        child: Image.file(selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            // BİLGİ GİRİŞİ
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Para Adı",
                filled: true,
                fillColor: AppColors.cardBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: yearController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Yıl",
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
                hintText: "Hatıra para hakkında bilgi",
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
              initialValue: condition,
              dropdownColor: AppColors.cardBlack,
              style: const TextStyle(color: Colors.white),
              items:
                  [
                    "Çil",
                    "Çil altı",
                    "Çok çok temiz",
                    "Çok temiz",
                    "Temiz",
                    "Çok iyi",
                    "İyi",
                    "Orta",
                    "Zayıf",
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
            DropdownButtonFormField<String>(
              initialValue: material,
              dropdownColor: AppColors.cardBlack,
              style: const TextStyle(color: Colors.white),
              items:
                  [
                    "Altın",
                    "Gümüş",
                    "Bronz",
                    "Pirinç",
                    "Alüminyum",
                    "Kâğıt",
                    "Bakır",
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
                  material = value!;
                });
              },
              decoration: InputDecoration(
                labelText: "Materyal",
                filled: true,
                fillColor: AppColors.cardBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // TAHMİNİ DEĞER HESAPLAMA
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  int year = int.tryParse(yearController.text) ?? 2000;
                  setState(() {
                    estimatedValue = ValueCalculator.calculate(
                      year: year,
                      rarity: rarity,
                      condition: condition,
                      material: material,
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
                    color: AppColors.gold.withGreen(25),
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

            // ADMIN PANELİ (Sözdizimi ve Düzen Hataları Düzeltildi)
            if (UserRole.isAdmin) ...[
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      int year = int.tryParse(yearController.text) ?? 2000;
                      setState(() {
                        CoinService.add(
                          CollectionItem(
                            name: nameController.text,
                            year: year,
                            rarity: rarity,
                            condition: condition,
                            material: material,
                            value: estimatedValue,
                            description: descriptionController.text,
                            imagePath: selectedImage?.path ?? "",
                          ),
                        );
                      });
                    },
                    child: const Text("Ekle"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedIndex != -1) {
                        setState(() {
                          CoinService.delete(selectedIndex);
                          selectedIndex = -1;
                        });
                      }
                    },
                    child: const Text("Sil"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedIndex != -1) {
                        int year = int.tryParse(yearController.text) ?? 2000;
                        setState(() {
                          CoinService.update(
                            selectedIndex,
                            CollectionItem(
                              name: nameController.text,
                              year: year,
                              rarity: rarity,
                              condition: condition,
                              material: material,
                              value: estimatedValue,
                              description: descriptionController.text,
                              imagePath: selectedImage?.path ?? "",
                            ),
                          );
                        });
                      }
                    },
                    child: const Text("Güncelle"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        nameController.clear();
                        yearController.clear();
                        descriptionController.clear();
                        selectedImage = null;
                        imagePath = "";
                        rarity = "Orta";
                        condition = "Temiz";
                        material = "Bronz";
                        estimatedValue = 0;
                        selectedIndex = -1;
                      });
                    },
                    child: const Text("Temizle"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (CoinService.coinList.isNotEmpty) {
                        int total = 0;
                        for (var item in CoinService.coinList) {
                          total += item.value;
                        }
                        setState(() {
                          totalValue = total;
                          averageValue = (total / CoinService.coinList.length)
                              .round();
                        });
                      }
                    },
                    child: const Text("Listele"),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.cardBlack,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withBlue(3),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Toplam Ürün: ${CoinService.coinList.length}",
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
              TextField(
                controller: searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: "Ürün Ara",
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
                style: const TextStyle(color: Colors.white),
                items: ["Tümü", "Düşük", "Orta", "Yüksek"].map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(color: Colors.white)),
                  );
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
                  // Filtrelenmiş elemanın orijinal listedeki gerçek indeksini buluyoruz
                  final actualIndex = CoinService.coinList.indexOf(item);

                  return Card(
                    child: ListTile(
                      selected: selectedIndex == actualIndex,
                      onTap: () {
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (_) => ItemDetailScreen(item: item),
                          ),
                        );
                      },
                      leading: item.imagePath.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: FileImage(File(item.imagePath)),
                            )
                          : const Icon(
                              Icons.monetization_on,
                              color: AppColors.gold,
                            ),
                      title: Text(item.name),
                      subtitle: Text(
                        "${item.year}\n"
                        "${item.material}\n"
                        "${item.value} TL",
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
                                CoinService.delete(index);
                                if (selectedIndex == actualIndex) {
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
