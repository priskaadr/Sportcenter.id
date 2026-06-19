import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddFieldScreen extends StatefulWidget {
  const AddFieldScreen({super.key});

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final locationController = TextEditingController();
  final priceController = TextEditingController();
  final facilityController = TextEditingController();
  final descriptionController = TextEditingController();

  Uint8List? imageBytes;

  bool isLoading = false;

  Future<void> pickImage() async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        imageBytes = await image.readAsBytes();

        setState(() {});
      }
    } catch (e) {
      debugPrint("PICK IMAGE ERROR : $e");
    }
  }

  Future<void> saveField() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User belum login");
      }

      if (nameController.text.trim().isEmpty) {
        throw Exception("Nama lapangan wajib diisi");
      }

      if (locationController.text.trim().isEmpty) {
        throw Exception("Lokasi wajib diisi");
      }

      if (priceController.text.trim().isEmpty) {
        throw Exception("Harga wajib diisi");
      }

      if (imageBytes == null) {
        throw Exception("Pilih gambar lapangan");
      }

      setState(() {
        isLoading = true;
      });

      // Upload gambar ke Storage
      final fileName =
          "field_${DateTime.now().millisecondsSinceEpoch}.jpg";

      await supabase.storage
          .from('field-images')
          .uploadBinary(
            fileName,
            imageBytes!,
          );

      final imageUrl = supabase.storage
          .from('field-images')
          .getPublicUrl(fileName);

      debugPrint("IMAGE URL : $imageUrl");

      // Simpan ke tabel fields
      await supabase.from('fields').insert({
        'field_name': nameController.text.trim(),
        'location': locationController.text.trim(),
        'price': int.tryParse(
              priceController.text.replaceAll('.', ''),
            ) ??
            0,
        'facility': facilityController.text.trim(),
        'description': descriptionController.text.trim(),
        'image_url': imageUrl,
        'owner_id': user.id,
        'rating': 0,
      });

      debugPrint("INSERT SUCCESS");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "Lapangan berhasil ditambahkan",
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("SAVE FIELD ERROR : $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            e.toString(),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        backgroundColor: const Color(0xff001DFF),
        elevation: 0,
        title: const Text(
          "Tambah Lapangan",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            GestureDetector(
              onTap: pickImage,

              child: Container(
                height: 220,
                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                    )
                  ],
                ),

                child: imageBytes == null
                    ? const Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 70,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Pilih Foto Lapangan",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius:
                            BorderRadius.circular(20),
                        child: Image.memory(
                          imageBytes!,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: nameController,
              decoration:
                  inputDecoration("Nama Lapangan"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: locationController,
              decoration:
                  inputDecoration("Lokasi"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: priceController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  inputDecoration("Harga Per Jam"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: facilityController,
              decoration:
                  inputDecoration("Fasilitas"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration:
                  inputDecoration("Deskripsi"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton(
                onPressed:
                    isLoading ? null : saveField,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.amber,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),

                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.black,
                      )
                    : const Text(
                        "Simpan Lapangan",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}