import 'package:flutter/material.dart';

import '../../models/field_model.dart';
import '../../services/field_service.dart';
import 'field_detail_screen.dart';
import '../../services/auth_service.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final FieldService fieldService = FieldService();

  String userName = "Customer";
  final TextEditingController searchController = TextEditingController();

  List<FieldModel> allFields = [];
  List<FieldModel> filteredFields = [];

  bool isLoading = true;

  String selectedFilter = "Terdekat";

  @override
  void initState() {
    super.initState();

    loadUserName();
    loadFields();
  }

  Future<void> loadUserName() async {
    try {
      final name = await AuthService().getCurrentUserName();

      setState(() {
        userName = name;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> loadFields() async {
    try {
      allFields = await fieldService.getFields();

      filteredFields = List.from(allFields);

      applyFilter("Terdekat");

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("ERROR LOAD FIELD");
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  void searchField(String keyword) {
    if (keyword.isEmpty) {
      filteredFields = List.from(allFields);

      applyFilter(selectedFilter);

      return;
    }

    filteredFields = allFields.where((field) {
      return field.fieldName.toLowerCase().contains(keyword.toLowerCase()) ||
          field.location.toLowerCase().contains(keyword.toLowerCase());
    }).toList();

    setState(() {});
  }

  void applyFilter(String filter) {
    selectedFilter = filter;

    filteredFields = List.from(allFields);

    if (filter == "Termurah") {
      filteredFields.sort((a, b) => a.price.compareTo(b.price));
    }

    if (filter == "Terdekat") {
      filteredFields.sort((a, b) => b.rating.compareTo(a.rating));
    }

    if (filter == "Fasilitas Lengkap") {
      filteredFields.sort(
        (a, b) => b.facility.length.compareTo(a.facility.length),
      );
    }

    setState(() {});
  }

  Widget buildFilterButton(String title) {
    final isSelected = selectedFilter == title;

    return GestureDetector(
      onTap: () {
        applyFilter(title);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget buildFieldCard(FieldModel field) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FieldDetailScreen(field: field)),
        );
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: field.imageUrl.isNotEmpty
                  ? Image.network(
                      field.imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Image.network(
                      field.imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    field.fieldName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    field.location,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),

                      Text(field.rating.toString()),

                      const Spacer(),

                      Text(
                        "Rp ${field.price}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // HEADER
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Color(0xff001DFF),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: Color(0xff001DFF),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Text(
                                "Halo, $userName",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const Spacer(),

                              IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Mau sewa lapangan\ndimana?",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: searchController,

                                  onChanged: (value) {
                                    searchField(value);
                                  },

                                  decoration: InputDecoration(
                                    hintText: "Cari Lapangan",
                                    prefixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 15,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text("Jakarta"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          buildFilterButton("Terdekat"),
                          buildFilterButton("Termurah"),
                          buildFilterButton("Fasilitas Lengkap"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            "Rekomendasi Untukmu",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: const Text("Lihat Semua"),
                          ),
                        ],
                      ),
                    ),
                    filteredFields.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(30),
                            child: Center(
                              child: Text(
                                "Belum ada data lapangan",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 250,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredFields.length,
                              itemBuilder: (context, index) {
                                return buildFieldCard(filteredFields[index]);
                              },
                            ),
                          ),
                  ],
                ),
              ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xff001DFF),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
      ),
    );
  }
}
