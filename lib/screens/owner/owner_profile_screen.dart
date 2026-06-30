import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() =>
      _OwnerProfileScreenState();
}

class _OwnerProfileScreenState
    extends State<OwnerProfileScreen> {

  final supabase =
      Supabase.instance.client;

  Map<String, dynamic>? profile;

  bool isLoading = true;

  final nameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future loadProfile() async {

    try {

      final user =
          supabase.auth.currentUser;

      final data =
          await supabase
              .from('profiles')
              .select()
              .eq('id', user!.id)
              .single();

      profile = data;

      nameController.text =
          data['full_name'] ?? '';

      phoneController.text =
          data['phone'] ?? '';

      setState(() {
        isLoading = false;
      });

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future pickImage() async {

    final image =
        await ImagePicker()
            .pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    imageBytes =
        await image.readAsBytes();

    final fileName =
        "${supabase.auth.currentUser!.id}.jpg";

    await supabase.storage
        .from('avatars')
        .uploadBinary(
          fileName,
          imageBytes!,
          fileOptions:
              const FileOptions(
            upsert: true,
          ),
        );

    final imageUrl =
        supabase.storage
            .from('avatars')
            .getPublicUrl(fileName);

    await supabase
        .from('profiles')
        .update({
      "avatar_url": imageUrl,
    })
        .eq(
      'id',
      supabase.auth.currentUser!.id,
    );

    loadProfile();
  }

  Future saveProfile() async {

    await supabase
        .from('profiles')
        .update({

      'full_name':
          nameController.text,

      'phone':
          phoneController.text,

      'updated_at':
          DateTime.now().toIso8601String(),

    })
        .eq(
      'id',
      supabase.auth.currentUser!.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      const SnackBar(
        content:
            Text("Profil diperbarui"),
      ),
    );
  }

  Future changePassword() async {

    final controller =
        TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {

        return AlertDialog(
          title:
              const Text("Password Baru"),

          content: TextField(
            controller: controller,
            obscureText: true,
          ),

          actions: [

            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text("Batal"),
            ),

            ElevatedButton(
              onPressed: () async {

                await supabase.auth
                    .updateUser(
                  UserAttributes(
                    password:
                        controller.text,
                  ),
                );

                if (!mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(
                        context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Password berhasil diubah",
                    ),
                  ),
                );
              },
              child: const Text(
                "Simpan",
              ),
            )
          ],
        );
      },
    );
  }

  Future logout() async {

    await supabase.auth.signOut();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      "/login",
      (route) => false,
    );
  }

  Widget infoCard(
    IconData icon,
    String title,
    String value,
  ) {

    return Container(

      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          )
        ],
      ),

      child: Row(
        children: [

          Icon(
            icon,
            color:
                const Color(0xff001DFF),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style:
                      const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                Text(
                  value,
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(

      backgroundColor:
          Colors.grey.shade100,

      body: SingleChildScrollView(

        child: Column(

          children: [

            Container(

              width: double.infinity,

              padding:
                  const EdgeInsets.only(
                top: 60,
                bottom: 30,
              ),

              decoration:
                  const BoxDecoration(
                color:
                    Color(0xff001DFF),

                borderRadius:
                    BorderRadius.vertical(
                  bottom:
                      Radius.circular(
                    35,
                  ),
                ),
              ),

              child: Column(

                children: [

                  GestureDetector(
                    onTap: pickImage,

                    child: CircleAvatar(

                      radius: 55,

                      backgroundImage:
                          profile![
                                      'avatar_url'] !=
                                  null
                              ? NetworkImage(
                                  profile![
                                      'avatar_url'],
                                )
                              : null,

                      child: profile![
                                  'avatar_url'] ==
                              null
                          ? const Icon(
                              Icons.person,
                              size: 55,
                            )
                          : null,
                    ),
                  ),

                  const SizedBox(
                      height: 12),

                  Text(
                    profile!['full_name'],
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 5),

                  Text(
                    profile!['email'],
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),

                  const SizedBox(
                      height: 10),

                  Chip(
                    backgroundColor:
                        profile![
                                'is_verified']
                            ? Colors.green
                            : Colors.orange,

                    label: Text(
                      profile![
                              'is_verified']
                          ? "Verified"
                          : "Menunggu Verifikasi",
                    ),
                  )
                ],
              ),
            ),

            Padding(
              padding:
                  const EdgeInsets.all(
                      20),
              child: Column(
                children: [

                  TextField(
                    controller:
                        nameController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          "Nama Lengkap",
                    ),
                  ),

                  const SizedBox(
                      height: 15),

                  TextField(
                    controller:
                        phoneController,
                    decoration:
                        const InputDecoration(
                      labelText:
                          "Nomor HP",
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        ElevatedButton(
                      onPressed:
                          saveProfile,
                      child: const Text(
                        "Simpan Perubahan",
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 20),

                  infoCard(
                    Icons.badge,
                    "Role",
                    profile!['role'],
                  ),

                  const SizedBox(
                      height: 12),

                  infoCard(
                    Icons.verified,
                    "Status Akun",
                    profile![
                            'is_verified']
                        ? "Verified"
                        : "Pending",
                  ),

                  const SizedBox(
                      height: 25),

                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          changePassword,
                      icon: const Icon(
                        Icons.lock,
                      ),
                      label: const Text(
                        "Ganti Password",
                      ),
                    ),
                  ),

                  const SizedBox(
                      height: 12),

                  SizedBox(
                    width:
                        double.infinity,
                    child:
                        ElevatedButton.icon(
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            Colors.red,
                      ),
                      onPressed:
                          logout,
                      icon: const Icon(
                        Icons.logout,
                        color:
                            Colors.white,
                      ),
                      label: const Text(
                        "Logout",
                        style:
                            TextStyle(
                          color: Colors
                              .white,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}