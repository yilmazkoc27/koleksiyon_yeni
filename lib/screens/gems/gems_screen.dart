//-----------------------
// *****KÜTÜPHANELER****
//-----------------------

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../models/collection_item.dart';
import '../../core/services/user_role.dart';
import '../detail/item_detail_screen.dart';

class GemsScreen extends StatefulWidget {
  const GemsScreen({super.key});

  @override
  State<GemsScreen> createState() => _GemsScreenState();
}

class _GemsScreenState extends State<GemsScreen> {
  int estimatedValue = 0;
  String? selectedItemId;
  bool ascending = true;
  bool isUploading = false;
  bool currentItemFavoriteStatus = false;

  File? _selectedImage;
  String _uploadedImageUrl = "";
  final ImagePicker _picker = ImagePicker();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController caratController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  // Dropdown Seçimleri (Açılış Değerleri)
  String rarity = "Orta";
  String clarity = "İyi"; // Modeldeki 'condition' alanına karşılık geliyor
  String colorQuality =
      "Normal"; // Modeldeki 'material' alanına karşılık geliyor

  final CollectionReference gemsCollection = FirebaseFirestore.instance
      .collection('gems');

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    caratController.dispose();
    valueController.dispose();
    searchController.dispose();
    super.dispose();
  }

  //-----------------------
  // *****FONKSİYONLAR****
  //-----------------------

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _uploadImageToStorage() async {
    if (_selectedImage == null) return _uploadedImageUrl;

    setState(() {
      isUploading = true;
    });

    try {
      String fileName = 'gem_${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference storageRef = FirebaseStorage.instance.ref().child(
        'gem_images/$fileName',
      );

      UploadTask uploadTask = storageRef.putFile(_selectedImage!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        isUploading = false;
      });
      return downloadUrl;
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Fotoğraf yüklenirken hata oluştu: $e")),
      );
      return "";
    }
  }

  void _populateFields(CollectionItem item, String docId) {
    setState(() {
      selectedItemId = docId;
      nameController.text = item.name;
      descriptionController.text = item.description;
      caratController.text = item.year.toString();
      valueController.text = item.value.toString();
      rarity = item.rarity;
      clarity = item.condition;
      colorQuality = item.material;
      estimatedValue = item.value;
      _uploadedImageUrl = item.imagePath;
      currentItemFavoriteStatus = item.isFavorite;
      _selectedImage = null;
    });
  }

  void _clearForm() {
    setState(() {
      nameController.clear();
      descriptionController.clear();
      caratController.clear();
      valueController.clear();
      rarity = "Orta";
      clarity = "İyi";
      colorQuality = "Normal";
      estimatedValue = 0;
      selectedItemId = null;
      _selectedImage = null;
      _uploadedImageUrl = "";
      currentItemFavoriteStatus = false;
    });
  }

  Future<void> _toggleFavorite(String docId, bool currentStatus) async {
    try {
      await gemsCollection.doc(docId).update({'isFavorite': !currentStatus});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Favori durumu güncellenemedi: $e")),
      );
    }
  }

  //-----------------------
  // *****TEMA / WIDGET KÜTÜPHANESİ****
  //-----------------------

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: AppColors.cardBlack,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.gold),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      dropdownColor: AppColors.cardBlack,
      style: const TextStyle(color: Colors.white),
      decoration: _buildInputDecoration(label),
      items: items.map((String item) {
        return DropdownMenuItem<String>(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  //-----------------------
  // *****Arayüz (BUILD)****
  //-----------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Değerli Taşlar",
          style: TextStyle(color: AppColors.gold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              ascending ? Icons.arrow_upward : Icons.arrow_downward,
              color: AppColors.gold,
            ),
            onPressed: () {
              setState(() {
                ascending = !ascending;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Resim Seçim Alanı
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: AppColors.cardBlack,
                  builder: (context) => SafeArea(
                    child: Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.photo_library,
                            color: AppColors.gold,
                          ),
                          title: const Text(
                            'Galeriden Seç',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            _pickImage(ImageSource.gallery);
                            Navigator.of(context).pop();
                          },
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.photo_camera,
                            color: AppColors.gold,
                          ),
                          title: const Text(
                            'Kameradan Çek',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            _pickImage(ImageSource.camera);
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
              child: Container(
                height: 170,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.cardBlack,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.5),
                    width: 1,
                  ),
                  image: _selectedImage != null
                      ? DecorationImage(
                          image: FileImage(_selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : (_uploadedImageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(_uploadedImageUrl),
                                fit: BoxFit.cover,
                              )
                            : null),
                ),
                child: _selectedImage == null && _uploadedImageUrl.isEmpty
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 50,
                            color: AppColors.gold,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Fotoğraf Eklemek İçin Dokunun",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 25),

            if (isUploading)
              const Padding(
                padding: EdgeInsets.only(bottom: 15),
                child: LinearProgressIndicator(color: AppColors.gold),
              ),

            // Form Giriş Alanları
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration("Taş Adı"),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white),
              decoration: _buildInputDecoration("Açıklama"),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: caratController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration("Karat Bilgisi"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: valueController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration("Tahmini Değer (TL)"),
                    onChanged: (value) {
                      setState(() {
                        estimatedValue = int.tryParse(value) ?? 0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Dropdown Seçimleri Bölümü
            _buildDropdownField(
              label: "Nadirlik Bilgisi",
              value: rarity,
              items: ["Çok Yaygın", "Yaygın", "Orta", "Nadir", "Çok Nadir"],
              onChanged: (val) => setState(() => rarity = val ?? "Orta"),
            ),
            const SizedBox(height: 15),

            _buildDropdownField(
              label: "Berraklık Bilgisi (Clarity)",
              value: clarity,
              items: ["Kötü", "Normal", "İyi", "Çok İyi", "Kusursuz (FL)"],
              onChanged: (val) => setState(() => clarity = val ?? "İyi"),
            ),
            const SizedBox(height: 15),

            _buildDropdownField(
              label: "Renk Kalitesi",
              value: colorQuality,
              items: ["Düşük", "Normal", "Canlı", "Eşsiz"],
              onChanged: (val) =>
                  setState(() => colorQuality = val ?? "Normal"),
            ),
            const SizedBox(height: 25),

            // Admin Paneli (CRUD Butonları)
            if (UserRole.isAdmin) ...[
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isUploading
                        ? null
                        : () async {
                            if (nameController.text.isEmpty) return;
                            String imageUrl = await _uploadImageToStorage();

                            // Model formatına uygun eşleme (.toMap() yerine doğrudan map verdik)
                            final itemMap = {
                              'name': nameController.text,
                              'year': int.tryParse(caratController.text) ?? 0,
                              'rarity': rarity,
                              'condition': clarity,
                              'material': colorQuality,
                              'value':
                                  int.tryParse(valueController.text) ??
                                  estimatedValue,
                              'description': descriptionController.text,
                              'imagePath': imageUrl,
                              'isFavorite': false,
                            };

                            await gemsCollection.add(itemMap);
                            _clearForm();
                          },
                    icon: const Icon(Icons.add),
                    label: const Text("Ekle"),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: isUploading
                        ? null
                        : () async {
                            if (selectedItemId != null) {
                              String imageUrl = await _uploadImageToStorage();

                              final itemMap = {
                                'name': nameController.text,
                                'year': int.tryParse(caratController.text) ?? 0,
                                'rarity': rarity,
                                'condition': clarity,
                                'material': colorQuality,
                                'value':
                                    int.tryParse(valueController.text) ??
                                    estimatedValue,
                                'description': descriptionController.text,
                                'imagePath': imageUrl,
                                'isFavorite': currentItemFavoriteStatus,
                              };

                              await gemsCollection
                                  .doc(selectedItemId)
                                  .update(itemMap);
                              _clearForm();
                            }
                          },
                    icon: const Icon(Icons.update),
                    label: const Text("Güncelle"),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: selectedItemId == null
                        ? null
                        : () async {
                            await gemsCollection.doc(selectedItemId).delete();
                            _clearForm();
                          },
                    icon: const Icon(Icons.delete),
                    label: const Text("Sil"),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _clearForm,
                    icon: const Icon(Icons.clear_all),
                    label: const Text("Temizle"),
                  ),
                ],
              ),
              const SizedBox(height: 25),
            ],

            // Arama Çubuğu
            TextField(
              controller: searchController,
              onChanged: (value) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Taşlarda Ara...",
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Liste Alanı (StreamBuilder)
            StreamBuilder<QuerySnapshot>(
              stream: gemsCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    "Veriler yüklenirken bir hata oluştu.",
                    style: TextStyle(color: Colors.white),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(color: AppColors.gold);
                }

                final docs = snapshot.data!.docs;

                // Client-side Arama Filtresi
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final query = searchController.text.toLowerCase();
                  return name.contains(query);
                }).toList();

                // Sıralama (Artan / Azalan)
                filteredDocs.sort((a, b) {
                  final dataA = a.data() as Map<String, dynamic>;
                  final dataB = b.data() as Map<String, dynamic>;
                  final int valueA = dataA['value'] ?? 0;
                  final int valueB = dataB['value'] ?? 0;
                  return ascending
                      ? valueA.compareTo(valueB)
                      : valueB.compareTo(valueA);
                });

                if (filteredDocs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      "Koleksiyonda taş bulunamadı.",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final dataMap = doc.data() as Map<String, dynamic>;

                    final bool isFavorite = dataMap['isFavorite'] ?? false;
                    // fromMap içine doc.id göndererek model nesnesini oluşturuyoruz
                    final item = CollectionItem.fromMap(dataMap, doc.id);

                    return Card(
                      color: AppColors.cardBlack,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: AppColors.gold.withOpacity(0.1),
                        ),
                      ),
                      child: ListTile(
                        leading: item.imagePath.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.imagePath,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.diamond,
                                color: AppColors.gold,
                                size: 40,
                              ),
                        title: Text(
                          item.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          "${item.value} TL - Nadirlik: ${item.rarity}\n${item.year} Karat",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isFavorite ? Icons.star : Icons.star_border,
                                color: AppColors.gold,
                              ),
                              onPressed: () {
                                _toggleFavorite(doc.id, isFavorite);
                              },
                            ),
                            if (UserRole.isAdmin)
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () => _populateFields(item, doc.id),
                              ),
                            IconButton(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.gold,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ItemDetailScreen(item: item),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
