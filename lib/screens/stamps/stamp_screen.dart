import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:koleksiyon_yeni/screens/stamps/stamp_album_screen.dart';
import 'package:path/path.dart' as p;
import '../../core/theme/app_colors.dart';
import '../../core/utils/value_calculator.dart';
import '../../models/collection_item.dart';
import '../../core/services/user_role.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../detail/item_detail_screen.dart';

class FirestoreStampModel {
  final String docId;
  final CollectionItem stamp;
  FirestoreStampModel({required this.docId, required this.stamp});
}

class StampScreen extends StatefulWidget {
  const StampScreen({super.key});

  @override
  State<StampScreen> createState() => _StampScreenState();
}

class _StampScreenState extends State<StampScreen> {
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
  String material = "Kâğıt"; // Pullar için varsayılan kâğıt yapıldı
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
        'posta_pullari/$uniqueFileName',
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

  Future<void> _addStampToFirestore() async {
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

      await FirebaseFirestore.instance.collection('Pullar').add({
        'name': nameController.text.trim(),
        'year': year,
        'rarity': rarity,
        'condition': condition,
        'material': material,
        'value': estimatedValue,
        'description': descriptionController.text.trim(),
        'imagePath': uploadedUrl,
        'isFavorite': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _clearForm();
      _showSnackBar("Pul başarıyla buluta eklendi!", Colors.green);
    } catch (e) {
      _showSnackBar("Ekleme hatası: $e", Colors.red);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _updateStampInFirestore() async {
    if (selectedDocId == null) {
      _showSnackBar(
        "Lütfen listeden güncellenecek bir pul seçin!",
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
          .collection('Pullar')
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
      _showSnackBar("Pul başarıyla güncellendi!", Colors.green);
    } catch (e) {
      _showSnackBar("Güncelleme hatası: $e", Colors.red);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

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

  void _clearForm() {
    setState(() {
      nameController.clear();
      yearController.clear();
      descriptionController.clear();
      selectedImage = null;
      currentImageUrl = "";
      rarity = "Orta";
      condition = "Temiz";
      material = "Kâğıt";
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
        title: const Text("Posta Pulları"),
        // Butonu buradan kaldırdık çünkü veriyi göremiyordu.
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Pullar').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Hata oluştu"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            );
          }

          // Veriler burada yükleniyor:
          List<FirestoreStampModel> allStamps = [];

          for (var doc in snapshot.data!.docs) {
            var data = doc.data() as Map<String, dynamic>;
            final item = CollectionItem.fromMap(data, doc.id);
            allStamps.add(FirestoreStampModel(docId: doc.id, stamp: item));
          }

          List<FirestoreStampModel> filteredList = List.from(allStamps);
          if (searchController.text.isNotEmpty) {
            filteredList = filteredList
                .where(
                  (item) => item.stamp.name.toLowerCase().contains(
                    searchController.text.toLowerCase(),
                  ),
                )
                .toList();
          }
          if (filterRarity != "Tümü") {
            filteredList = filteredList
                .where((item) => item.stamp.rarity == filterRarity)
                .toList();
          }

          filteredList.sort(
            (a, b) => ascending
                ? a.stamp.value.compareTo(b.stamp.value)
                : b.stamp.value.compareTo(a.stamp.value),
          );

          // Eğer yükleme yapılıyorsa sadece loading göster, yapılmıyorsa içeriği göster
          return _isUploading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Üst Kısım: Görsel Alanı ve Albüme Gitme Butonu
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
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.local_post_office,
                                size: 80,
                                color: AppColors.gold,
                              ),
                            ),
                            // Albüm Butonunu buraya sağ üste şık bir şekilde yerleştirdik:
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.photo_album,
                                  color: AppColors.gold,
                                  size: 30,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      // allStamps listesini artık sorunsuz görüyor!
                                      builder: (_) => StampAlbumScreen(
                                        stampList: allStamps
                                            .map((e) => e.stamp)
                                            .toList(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
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
                                        "Pul Fotoğrafı Seç",
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
                            hintText: "Pul Adı",
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
                          value: rarity,
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
                          value: condition,
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
                          value: material,
                          dropdownColor: AppColors.cardBlack,
                          style: const TextStyle(color: Colors.white),
                          items:
                              [
                                    "Kâğıt",
                                    "Dantelli Kâğıt",
                                    "Dantelsiz Kâğıt",
                                    "Şarniyerli",
                                    "Şarniyersiz",
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
                            labelText: "Materyal / Tip",
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
                                int total = 0;
                                for (var item in allStamps) {
                                  total += item.stamp.value;
                                }
                                setState(() {
                                  totalValue = total;
                                  averageValue = allStamps.isEmpty
                                      ? 0
                                      : (total / allStamps.length).round();
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
                                "Toplam Ürün: ${allStamps.length}",
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
                          final stampModel = filteredList[index];
                          final item = stampModel.stamp;
                          final docId = stampModel.docId;

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
                                      Icons.local_post_office,
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
                                    onPressed: () async {
                                      setState(() {
                                        item.isFavorite = !item.isFavorite;
                                      });

                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('Pullar')
                                            .doc(docId)
                                            .update({
                                              'isFavorite': item.isFavorite,
                                            });
                                        print("Favori güncellendi");
                                      } catch (e) {
                                        print("HATA: $e");
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
