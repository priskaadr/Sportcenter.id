import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/field_model.dart';
import '../../services/auth_service.dart';
import '../../services/field_service.dart';

import '../../widgets/customer/field_card.dart';
import '../../widgets/customer/category_chip.dart';
import '../../widgets/customer/promo_card.dart';
import '../../widgets/customer/section_title.dart';

import 'field_detail_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() =>
      _CustomerHomeScreenState();
}

class _CustomerHomeScreenState
    extends State<CustomerHomeScreen> {

  //--------------------------------------------------
  // SERVICE
  //--------------------------------------------------

  final FieldService fieldService =
      FieldService();

  //--------------------------------------------------
  // CONTROLLER
  //--------------------------------------------------

  final TextEditingController searchController =
      TextEditingController();

  final PageController promoController =
      PageController();

  //--------------------------------------------------
  // DATA
  //--------------------------------------------------

  String userName = "Customer";

  bool isLoading = true;

  List<FieldModel> allFields = [];

  List<FieldModel> filteredFields = [];

  //--------------------------------------------------
  // FILTER
  //--------------------------------------------------

  String selectedCategory = "Semua";

  final List<String> categories = [

    "Semua",

    "Futsal",

    "Badminton",

    "Basket",

    "Tennis",

    "Mini Soccer",

  ];

  //--------------------------------------------------
  // PROMO
  //--------------------------------------------------

  final List<Map<String, dynamic>> promos = [

    {

      "title": "Diskon 30%",

      "subtitle": "Booking Weekend",

      "color": const Color(0xff001DFF),

    },

    {

      "title": "Cashback 20%",

      "subtitle": "Bayar Dengan QRIS",

      "color": Colors.green,

    },

    {

      "title": "Gratis Air Mineral",

      "subtitle": "Minimal Booking 3 Jam",

      "color": Colors.orange,

    },

  ];

  //--------------------------------------------------
  // INIT
  //--------------------------------------------------

  @override
  void initState() {

    super.initState();

    loadInitialData();

  }

  //--------------------------------------------------
  // LOAD
  //--------------------------------------------------

  Future<void> loadInitialData() async {

    setState(() {

      isLoading = true;

    });

    try {

      userName =
          await AuthService()
              .getCurrentUserName();

      allFields =
          await fieldService.getFields();

      filteredFields =
          List.from(allFields);

      applyCategory("Semua");

    } catch (e) {

      debugPrint(e.toString());

    }

    if (!mounted) return;

    setState(() {

      isLoading = false;

    });

  }

  //--------------------------------------------------
  // SEARCH
  //--------------------------------------------------

  void searchField(String keyword) {

    if (keyword.trim().isEmpty) {

      applyCategory(selectedCategory);

      return;

    }

    filteredFields =
        allFields.where((field) {

      return field.fieldName
                  .toLowerCase()
                  .contains(
                    keyword.toLowerCase(),
                  ) ||

          field.location
              .toLowerCase()
              .contains(
                keyword.toLowerCase(),
              );

    }).toList();

    setState(() {});
  }

  //--------------------------------------------------
  // FILTER
  //--------------------------------------------------

  void applyCategory(
      String category) {

    selectedCategory = category;

    filteredFields =
        List.from(allFields);

    if (category == "Semua") {

      filteredFields.sort(
        (a, b) =>
            b.rating.compareTo(
              a.rating,
            ),
      );

    }

    if (category == "Futsal") {

      filteredFields =
          filteredFields.where((e) {

        return e.fieldName
            .toLowerCase()
            .contains("futsal");

      }).toList();

    }

    if (category == "Badminton") {

      filteredFields =
          filteredFields.where((e) {

        return e.fieldName
            .toLowerCase()
            .contains("badminton");

      }).toList();

    }

    if (category == "Basket") {

      filteredFields =
          filteredFields.where((e) {

        return e.fieldName
            .toLowerCase()
            .contains("basket");

      }).toList();

    }

    if (category == "Tennis") {

      filteredFields =
          filteredFields.where((e) {

        return e.fieldName
            .toLowerCase()
            .contains("tennis");

      }).toList();

    }

    if (category == "Mini Soccer") {

      filteredFields =
          filteredFields.where((e) {

        return e.fieldName
            .toLowerCase()
            .contains("soccer");

      }).toList();

    }

    setState(() {});
  }

  //--------------------------------------------------
  // OPEN DETAIL
  //--------------------------------------------------

  void openDetail(
      FieldModel field) {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FieldDetailScreen(
          fieldId: field.id,
        ),
      ),
    );
  }

    //--------------------------------------------------
  // HEADER
  //--------------------------------------------------

  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        20,
        60,
        20,
        30,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff001DFF),
            Color(0xff3559FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(35),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          //----------------------------------
          // USER
          //----------------------------------

          Row(
            children: [

              const CircleAvatar(
                radius: 27,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Color(0xff001DFF),
                  size: 28,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Selamat Datang 👋",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                ),
              )
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            "Cari Lapangan\nFavoritmu",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          //----------------------------------
          // SEARCH
          //----------------------------------

          TextField(
            controller: searchController,
            onChanged: searchField,
            decoration: InputDecoration(

              filled: true,

              fillColor: Colors.white,

              hintText: "Cari nama lapangan...",

              prefixIcon:
                  const Icon(Icons.search),

              suffixIcon:
                  const Icon(Icons.tune),

              border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(18),
                borderSide:
                    BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

    //--------------------------------------------------
  // PROMO
  //--------------------------------------------------

  Widget buildPromoSlider() {
    return SizedBox(
      height: 170,
      child: PageView.builder(
        controller: promoController,
        itemCount: promos.length,
        itemBuilder: (context, index) {
          final promo = promos[index];

          return PromoCard(
            title: promo["title"],
            subtitle: promo["subtitle"],
            color: promo["color"],
          );
        },
      ),
    );
  }

    //--------------------------------------------------
  // CATEGORY
  //--------------------------------------------------

  Widget buildCategory() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        itemBuilder: (context, index) {
          return CategoryChip(
            title: categories[index],
            selected:
                selectedCategory ==
                    categories[index],
            onTap: () {
              applyCategory(
                  categories[index]);
            },
          );
        },
      ),
    );
  }


    //--------------------------------------------------
  // SECTION
  //--------------------------------------------------

  Widget buildRecommendationTitle() {
    return const Padding(
      padding:
          EdgeInsets.symmetric(
        horizontal: 18,
      ),
      child: SectionTitle(
        title: "Rekomendasi Lapangan",
        subtitle:
            "Lapangan dengan rating terbaik",
      ),
    );
  }

    //--------------------------------------------------
  // FIELD LIST
  //--------------------------------------------------

  Widget buildFieldList() {
    if (filteredFields.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: Text(
            "Belum ada lapangan",
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics:
          const NeverScrollableScrollPhysics(),
      itemCount: filteredFields.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final field =
            filteredFields[index];

        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 18,
          ),
          child: FieldCard(
            field: field,
            onTap: () =>
                openDetail(field),
          ),
        );
      },
    );
  }

  
    //--------------------------------------------------
  // BUILD
  //--------------------------------------------------

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(

      const SystemUiOverlayStyle(

        statusBarColor: Colors.transparent,

        statusBarIconBrightness:
            Brightness.light,

      ),
    );

    return Scaffold(

      backgroundColor: Colors.grey.shade100,

      body: SafeArea(

        top: false,

        child: RefreshIndicator(

          onRefresh: loadInitialData,

          child: isLoading

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : SingleChildScrollView(

                  physics:
                      const AlwaysScrollableScrollPhysics(),

                  child: Column(

                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      //---------------------------------
                      // HEADER
                      //---------------------------------

                      buildHeader(),

                      const SizedBox(height: 20),

                      //---------------------------------
                      // PROMO
                      //---------------------------------

                      buildPromoSlider(),

                      const SizedBox(height: 24),

                      //---------------------------------
                      // CATEGORY
                      //---------------------------------

                      buildCategory(),

                      const SizedBox(height: 28),

                      //---------------------------------
                      // TITLE
                      //---------------------------------

                      buildRecommendationTitle(),

                      const SizedBox(height: 14),

                      //---------------------------------
                      // FIELD
                      //---------------------------------

                      buildFieldList(),

                      const SizedBox(height: 40),

                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

