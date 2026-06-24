import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:koleksiyon_yeni/screens/gems/gems_detail_screen.dart';
import 'package:path/path.dart' as p;
import '../../core/theme/app_colors.dart';
import '../../core/services/user_role.dart';
import '../../models/collection_item.dart';
import '../../core/utils/gem_value_calculator.dart';
import 'gems_album_screen.dart';

class FirestoreGemModel {
  final String docId;
  final CollectionItem gem;

  FirestoreGemModel({required this.docId, required this.gem});
}

class GemsScreen extends StatefulWidget {
  const GemsScreen({super.key});

  @override
  State<GemsScreen> createState() => _GemsScreenState();
}

class _GemsScreenState extends State<GemsScreen> {
  int estimatedValue = 0;
  String? selectedDocId;

  int totalValue = 0;
  int averageValue = 0;

  bool ascending = true;
  bool _isUploading = false;

  final ImagePicker picker = ImagePicker();
  File? selectedImage;
  String currentImageUrl = "";

  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController caratController = TextEditingController(
    text: "1.0",
  );

  // GemValueCalculator Parametreleri ve İlk Değerleri
  String gemType = "Akik";
  String rarity = "Orta";
  String clarity = "İyi";
  String colorQuality = "Normal";
  String processType = "Ham Taş";
  String damage = "Yok";
  String filterRarity = "Tümü";

  @override
  void dispose() {
    descriptionController.dispose();
    searchController.dispose();
    caratController.dispose();
    super.dispose();
  }

  Future pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<String> _uploadImageToStorage(File imageFile) async {
    try {
      String fileName = p.basename(imageFile.path);
      String uniqueFileName =
          "${DateTime.now().millisecondsSinceEpoch}_$fileName";

      Reference storageRef = FirebaseStorage.instance.ref().child(
        "gem_images/$uniqueFileName",
      );

      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      debugPrint("Storage Hatası: $e");
      return "";
    }
  }

  void _clearForm() {
    setState(() {
      selectedDocId = null;
      selectedImage = null;
      currentImageUrl = "";
      descriptionController.clear();
      caratController.text = "1.0";
      gemType = "Akik";
      rarity = "Orta";
      clarity = "İyi";
      colorQuality = "Normal";
      processType = "Ham Taş";
      damage = "Yok";
      estimatedValue = 0;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Future<void> _addGemToFirestore() async {
    setState(() {
      _isUploading = true;
    });

    try {
      String uploadedUrl = "";
      if (selectedImage != null) {
        uploadedUrl = await _uploadImageToStorage(selectedImage!);
      }

      double carat = double.tryParse(caratController.text) ?? 1.0;

      await FirebaseFirestore.instance.collection("gems").add({
        "name": gemType,
        "year": DateTime.now().year,
        "rarity": rarity,
        "condition": clarity, // model şeması için clarity
        "material": colorQuality, // model şeması için colorQuality
        "description": descriptionController.text.trim(),
        "value": estimatedValue,
        "imagePath": uploadedUrl,
        "isFavorite": false,
        "carat": carat,
        "processType": processType,
        "damage": damage,
        "createdAt": FieldValue.serverTimestamp(),
      });

      _clearForm();
      _showSnackBar("Taş başarıyla eklendi", Colors.green);
    } catch (e) {
      _showSnackBar("Hata: $e", Colors.red);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _updateGemInFirestore() async {
    if (selectedDocId == null) {
      _showSnackBar("Lütfen bir taş seçin", Colors.orange);
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

      double carat = double.tryParse(caratController.text) ?? 1.0;

      await FirebaseFirestore.instance
          .collection("gems")
          .doc(selectedDocId)
          .update({
            "name": gemType,
            "rarity": rarity,
            "condition": clarity,
            "material": colorQuality,
            "description": descriptionController.text.trim(),
            "value": estimatedValue,
            "imagePath": uploadedUrl,
            "carat": carat,
            "processType": processType,
            "damage": damage,
          });

      _clearForm();
      _showSnackBar("Taş güncellendi", Colors.green);
    } catch (e) {
      _showSnackBar("Hata: $e", Colors.red);
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _deleteGemFromFirestore(String docId) async {
    try {
      await FirebaseFirestore.instance.collection("gems").doc(docId).delete();
      if (selectedDocId == docId) {
        _clearForm();
      }
      _showSnackBar("Taş silindi", Colors.green);
    } catch (e) {
      _showSnackBar("Silme hatası: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Değerli Taşlar"),
        actions: [
          // Sağ üstteki album withalpha ile şimdilik gizlendi.
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 6.0, bottom: 6.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GemsAlbumScreen()),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold.withAlpha(1),
                  borderRadius: BorderRadius.circular(12), // Oval köşeler
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(2),
                      blurRadius: 4,
                      offset: const Offset(
                        0,
                        2,
                      ), // Hafif derinlik hissi veren gölge
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.photo_album,
                      color:
                          AppColors.cardBlack, // Kontrast için koyu renk ikon
                      size: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isUploading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection("gems").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Hata oluştu"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.gold),
                  );
                }

                List<FirestoreGemModel> allGems = [];

                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final item = CollectionItem.fromMap(data, doc.id);
                  allGems.add(FirestoreGemModel(docId: doc.id, gem: item));
                }

                List<FirestoreGemModel> filteredList = List.from(allGems);

                // ARAMA
                if (searchController.text.isNotEmpty) {
                  filteredList = filteredList.where((item) {
                    return item.gem.name.toLowerCase().contains(
                      searchController.text.toLowerCase(),
                    );
                  }).toList();
                }

                // FİLTRELEME
                if (filterRarity != "Tümü") {
                  filteredList = filteredList.where((item) {
                    return item.gem.rarity == filterRarity;
                  }).toList();
                }

                // SIRALAMA
                filteredList.sort(
                  (a, b) => ascending
                      ? a.gem.value.compareTo(b.gem.value)
                      : b.gem.value.compareTo(a.gem.value),
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Geliştirilmiş Yeni Albüm Butonu Kartı
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.cardBlack, AppColors.surface],
                          ),
                          border: Border.all(
                            color: AppColors.gold.withRed(5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withRed(2),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(23),
                            splashColor: AppColors.gold.withOpacity(0.15),
                            highlightColor: AppColors.gold.withOpacity(0.08),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const GemsAlbumScreen(),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 25,
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Icon(
                                    Icons.diamond_rounded,
                                    color: AppColors.info,
                                    size: 85,
                                  ),
                                  const SizedBox(height: 12),
                                  Column(
                                    children: [
                                      Text(
                                        "SERGİ SALONU",
                                        style: TextStyle(
                                          color: AppColors.gold,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                          fontStyle: FontStyle.italic,
                                          fontFamily: 'Palatino',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      if (UserRole.isAdmin) ...[
                        // Fotoğraf Seçim Alanı
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

                        // Karat Giriş Alanı
                        TextField(
                          controller: caratController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(color: Colors.white),
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

                        // Taş Türü Dropdown
                        DropdownButtonFormField<String>(
                          value: gemType,
                          dropdownColor: AppColors.cardBlack,
                          style: const TextStyle(color: Colors.white),
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
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) =>
                              setState(() => gemType = value!),
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

                        // Clarity (Berraklık) Dropdown
                        DropdownButtonFormField<String>(
                          value: clarity,
                          dropdownColor: AppColors.cardBlack,
                          style: const TextStyle(color: Colors.white),
                          items: ["Mükemmel", "Çok İyi", "İyi", "Orta", "Düşük"]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => clarity = value!),
                          decoration: InputDecoration(
                            labelText: "Berraklık (Clarity)",
                            filled: true,
                            fillColor: AppColors.cardBlack,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // ColorQuality (Renk Kalitesi) Dropdown
                        DropdownButtonFormField<String>(
                          value: colorQuality,
                          dropdownColor: AppColors.cardBlack,
                          style: const TextStyle(color: Colors.white),
                          items: ["Canlı", "Parlak", "Normal", "Soluk"]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => colorQuality = value!),
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

                        // Nadirlik (Rarity) Dropdown
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

                        // ProcessType (İşlenme Türü) Dropdown
                        DropdownButtonFormField<String>(
                          value: processType,
                          dropdownColor: AppColors.cardBlack,
                          style: const TextStyle(color: Colors.white),
                          items:
                              [
                                    "Ham Taş",
                                    "Kesilmiş",
                                    "Parlatılmış",
                                    "Takı Haline Getirilmiş",
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) =>
                              setState(() => processType = value!),
                          decoration: InputDecoration(
                            labelText: "İşlenme Türü",
                            filled: true,
                            fillColor: AppColors.cardBlack,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Damage (Hasar Durumu) Dropdown
                        DropdownButtonFormField<String>(
                          value: damage,
                          dropdownColor: AppColors.cardBlack,
                          style: const TextStyle(color: Colors.white),
                          items:
                              [
                                    "Yok",
                                    "Küçük Çatlak",
                                    "Belirgin Çatlak",
                                    "Kırık",
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (value) => setState(() => damage = value!),
                          decoration: InputDecoration(
                            labelText: "Hasar Durumu",
                            filled: true,
                            fillColor: AppColors.cardBlack,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Açıklama Metin Alanı
                        TextField(
                          controller: descriptionController,
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            labelText: "Açıklama",
                            filled: true,
                            fillColor: AppColors.cardBlack,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Tahmini Değer Hesapla Butonu
                        ElevatedButton(
                          onPressed: () {
                            double carat =
                                double.tryParse(caratController.text) ?? 1.0;
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

                        // CRUD İşlem Butonları (Wrap)
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ElevatedButton(
                              onPressed: _addGemToFirestore,
                              child: const Text("Ekle"),
                            ),
                            ElevatedButton(
                              onPressed: _updateGemInFirestore,
                              child: const Text("Güncelle"),
                            ),
                            ElevatedButton(
                              onPressed: _clearForm,
                              child: const Text("Temizle"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                int total = 0;
                                for (var item in allGems) {
                                  total += item.gem.value;
                                }
                                setState(() {
                                  totalValue = total;
                                  averageValue = allGems.isEmpty
                                      ? 0
                                      : (total / allGems.length).round();
                                });
                              },
                              child: const Text("İstatistik Hesapla"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // İstatistik Paneli
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
                                "Toplam Ürün: ${allGems.length}",
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

                      // Arama Alanı (Her iki rol için de görünür)
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

                      // Nadirlik Filtresi
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

                      // Sıralama Butonu
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

                      // Koleksiyon Listeniz (ListView)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final gemModel = filteredList[index];
                          final item = gemModel.gem;
                          final docId = gemModel.docId;

                          return Card(
                            color: AppColors.cardBlack,
                            child: ListTile(
                              selected: selectedDocId == docId,
                              selectedColor: AppColors.gold,
                              onTap: () {
                                if (UserRole.isAdmin) {
                                  setState(() {
                                    selectedDocId = docId;
                                    gemType = item.name;
                                    rarity = item.rarity;
                                    clarity = item.condition;
                                    colorQuality = item.material;
                                    descriptionController.text =
                                        item.description;
                                    estimatedValue = item.value;
                                    currentImageUrl = item.imagePath;
                                    selectedImage = null;

                                    // Firestore'dan gelen ek alanlar (Null kontrolü ile güvenli eşleme)
                                    final rawData =
                                        snapshot.data!.docs
                                                .firstWhere(
                                                  (d) => d.id == docId,
                                                )
                                                .data()
                                            as Map<String, dynamic>;
                                    caratController.text =
                                        (rawData['carat'] ?? 1.0).toString();
                                    processType =
                                        rawData['processType'] ?? "Ham Taş";
                                    damage = rawData['damage'] ?? "Yok";
                                  });
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GemsDetailScreen(
                                        item: allGems[index].gem.copyWith(
                                          docId: allGems[index].docId,
                                        ),
                                      ),
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
                                      Icons.diamond,
                                      color: AppColors.gold,
                                    ),
                              title: Text(
                                item.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                "${item.value} TL - Nadirlik: ${item.rarity}",
                                style: const TextStyle(color: Colors.white70),
                              ),
                              trailing: UserRole.isAdmin
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () =>
                                          _deleteGemFromFirestore(docId),
                                    )
                                  : const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.white54,
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
