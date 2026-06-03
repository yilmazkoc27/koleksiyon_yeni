import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as p;
import '../../core/theme/app_colors.dart';
import '../../core/utils/value_calculator.dart';
import '../../models/collection_item.dart';
import 'coin_album_screen.dart';
import '../../core/services/user_role.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../detail/item_detail_screen.dart';

class FirestoreCoinModel {
  final String docId;
  final CollectionItem coin;
  FirestoreCoinModel({required this.docId, required this.coin});
}

class CoinScreen extends StatefulWidget {
  const CoinScreen({super.key});

  @override
  State<CoinScreen> createState() => _CoinScreenState();
}

class _CoinScreenState extends State<CoinScreen> {
  int estimatedValue = 0;
  String? selectedDocId;
  int totalValue = 0;
  int averageValue = 0;
  bool ascending = true;
  bool _isUploading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController yearController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  String rarity = "Orta";
  String condition = "Temiz";
  String material = "Gümüş";
  String filterRarity = "Tümü";
  String currentImageUrl = "";

  File? selectedImage;

  @override
  void dispose() {
    nameController.dispose();
    yearController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    try {
      String fileName = p.basename(imageFile.path);
      String uniqueFileName =
          "${DateTime.now().millisecondsSinceEpoch}_$fileName";

      Reference storageRef = FirebaseStorage.instance.ref().child(
        'madeni_paralar/$uniqueFileName',
      );
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Storage Yükleme Hatası: $e");
      return "";
    }
  }

  Future<void> _addCoinToFirestore() async {
    if (nameController.text.trim().isEmpty ||
        yearController.text.trim().isEmpty) {
      _showSnackBar("Lütfen isim ve yıl alanlarını doldurun!", Colors.orange);
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String uploadedUrl = "";
      if (selectedImage != null) {
        uploadedUrl = await _uploadImageToStorage(selectedImage!);
      }

      int year = int.tryParse(yearController.text) ?? 2023;

      await FirebaseFirestore.instance.collection('Paralar').add({
        'name': nameController.text.trim(),
        'year': year,
        'rarity': rarity,
        'condition': condition,
        'material': material,
        'value': estimatedValue,
        'description': descriptionController.text.trim(),
        'imagePath': uploadedUrl,
        'isFavorite': false, // Yeni eklenen ürün varsayılan olarak favori değil
        'createdAt': FieldValue.serverTimestamp(),
      });

      _clearForm();
      _showSnackBar("Para başarıyla buluta eklendi!", Colors.green);
    } catch (e) {
      _showSnackBar("Ekleme hatası: $e", Colors.red);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _updateCoinInFirestore() async {
    if (selectedDocId == null) {
      _showSnackBar(
        "Lütfen listeden güncellenecek bir para seçin!",
        Colors.orange,
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String uploadedUrl = currentImageUrl;

      if (selectedImage != null) {
        uploadedUrl = await _uploadImageToStorage(selectedImage!);
      }

      int year = int.tryParse(yearController.text) ?? 2023;

      await FirebaseFirestore.instance
          .collection('Paralar')
          .doc(selectedDocId)
          .update({
            'name': nameController.text.trim(),
            'year': year,
            'rarity': rarity,
            'condition': condition,
            'material': material,
            'value': estimatedValue,
            'description': descriptionController.text.trim(),
            'imagePath': uploadedUrl,
          });

      _clearForm();
      _showSnackBar("Para başarıyla güncellendi!", Colors.green);
    } catch (e) {
      _showSnackBar("Güncelleme hatası: $e", Colors.red);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _deleteCoinFromFirestore(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('Paralar')
          .doc(docId)
          .delete();
      if (selectedDocId == docId) {
        _clearForm();
      }
      _showSnackBar("Para başarıyla silindi!", Colors.green);
    } catch (e) {
      _showSnackBar("Silme hatası: $e", Colors.red);
    }
  }

  void _clearForm() {
    setState(() {
      nameController.clear();
      yearController.clear();
      descriptionController.clear();
      selectedImage = null;
      currentImageUrl = "";
      rarity = "Orta";
      condition = "Temiz";
      material = "Gümüş";
      estimatedValue = 0;
      selectedDocId = null;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hatıra Paralar"),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_album),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CoinAlbumScreen()),
              );
            },
          ),
        ],
      ),
      body: _isUploading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Paralar')
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

                List<FirestoreCoinModel> allCoins = [];

                for (var doc in snapshot.data!.docs) {
                  var data = doc.data() as Map<String, dynamic>;
                  final item = CollectionItem.fromMap(data, doc.id);
                  allCoins.add(FirestoreCoinModel(docId: doc.id, coin: item));
                }

                List<FirestoreCoinModel> filteredList = List.from(allCoins);
                if (searchController.text.isNotEmpty) {
                  filteredList = filteredList
                      .where(
                        (item) => item.coin.name.toLowerCase().contains(
                          searchController.text.toLowerCase(),
                        ),
                      )
                      .toList();
                }
                if (filterRarity != "Tümü") {
                  filteredList = filteredList
                      .where((item) => item.coin.rarity == filterRarity)
                      .toList();
                }

                filteredList.sort(
                  (a, b) => ascending
                      ? a.coin.value.compareTo(b.coin.value)
                      : b.coin.value.compareTo(a.coin.value),
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        height: 170,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.cardBlack,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withAlpha(40),
                              blurRadius: 15,
                            ),
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
                      if (UserRole.isAdmin) ...[
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
                            child: selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.file(
                                      selectedImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : currentImageUrl.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      currentImageUrl,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo,
                                        size: 50,
                                        color: AppColors.gold,
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "Fotoğraf Seç",
                                        style: TextStyle(color: Colors.white70),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.white),
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
                          style: const TextStyle(color: Colors.white),
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
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: "Açıklama",
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
                          items: ["Düşük", "Orta", "Yüksek"]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
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
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
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
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) =>
                              setState(() => material = value!),
                          decoration: InputDecoration(
                            labelText: "Materyal",
                            filled: true,
                            fillColor: AppColors.cardBlack,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton(
                          onPressed: () {
                            int year =
                                int.tryParse(yearController.text) ?? 2023;
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
                        const SizedBox(height: 15),
                        Text(
                          "Tahmini Değer: $estimatedValue TL",
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton(
                              onPressed: _addCoinToFirestore,
                              child: const Text("Ekle"),
                            ),
                            ElevatedButton(
                              onPressed: _updateCoinInFirestore,
                              child: const Text("Güncelle"),
                            ),
                            ElevatedButton(
                              onPressed: _clearForm,
                              child: const Text("Temizle"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                int total = 0;
                                for (var item in allCoins) {
                                  total += item.coin.value;
                                }
                                setState(() {
                                  totalValue = total;
                                  averageValue = allCoins.isEmpty
                                      ? 0
                                      : (total / allCoins.length).round();
                                });
                              },
                              child: const Text("İstatistik Hesapla"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: AppColors.cardBlack,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Toplam Ürün: ${allCoins.length}",
                                style: const TextStyle(color: Colors.white),
                              ),
                              Text(
                                "Toplam Değer: $totalValue TL",
                                style: const TextStyle(color: AppColors.gold),
                              ),
                              Text(
                                "Ortalama Değer: $averageValue TL",
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),
                      ],
                      TextField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(color: Colors.white),
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
                      const SizedBox(height: 25),
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
                          final coinModel = filteredList[index];
                          final item = coinModel.coin;
                          final docId = coinModel.docId;

                          return Card(
                            color: AppColors.cardBlack,
                            child: ListTile(
                              selected: selectedDocId == docId,
                              selectedColor: AppColors.gold,
                              onTap: () {
                                if (UserRole.isAdmin) {
                                  setState(() {
                                    selectedDocId = docId;
                                    nameController.text = item.name;
                                    yearController.text = item.year.toString();
                                    descriptionController.text =
                                        item.description;
                                    rarity = item.rarity;
                                    condition = item.condition;
                                    material = item.material;
                                    estimatedValue = item.value;
                                    currentImageUrl = item.imagePath;
                                    selectedImage = null;
                                  });
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ItemDetailScreen(item: item),
                                    ),
                                  );
                                }
                              },
                              leading: item.imagePath.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage: NetworkImage(
                                        item.imagePath,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.monetization_on,
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
                                  // GÜNCELLENEN FAVORİ BUTONU
                                  IconButton(
                                    icon: Icon(
                                      item.isFavorite
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: AppColors.gold,
                                    ),
                                    onPressed: () async {
                                      // 1. Ekranın anlık tepki vermesi için local state'i hemen değiştiriyoruz
                                      setState(() {
                                        item.isFavorite = !item.isFavorite;
                                      });

                                      try {
                                        // 2. Firestore veritabanını güncelliyoruz
                                        await FirebaseFirestore.instance
                                            .collection('Paralar')
                                            .doc(docId)
                                            .update({
                                              'isFavorite': item.isFavorite,
                                            });
                                        print("Favori güncellendi");
                                      } catch (e) {
                                        print("HATA: $e");
                                        // Hata olursa eski haline geri al ve uyar
                                        setState(() {
                                          item.isFavorite = !item.isFavorite;
                                        });
                                        _showSnackBar(
                                          "Favori güncellenemedi: $e",
                                          Colors.red,
                                        );
                                      }
                                    },
                                  ),
                                  if (UserRole.isAdmin)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () =>
                                          _deleteCoinFromFirestore(docId),
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
