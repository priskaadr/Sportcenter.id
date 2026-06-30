import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FieldDetailScreen extends StatefulWidget {
  final String fieldId;

  const FieldDetailScreen({
    super.key,
    required this.fieldId,
  });

  @override
  State<FieldDetailScreen> createState() =>
      _FieldDetailScreenState();
}

class _FieldDetailScreenState
    extends State<FieldDetailScreen> {

  final supabase = Supabase.instance.client;

  bool isLoading = true;

  bool isFavorite = false;

  Map<String, dynamic>? field;

  Map<String, dynamic>? owner;

  List<Map<String, dynamic>> schedules = [];

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {

  try {

    await loadField();

    if (field != null) {

      await loadOwner();

      await loadSchedules();
    }

  } catch (e) {

    debugPrint(e.toString());

  }

  if (mounted) {

    setState(() {

      isLoading = false;

    });

  }

}

Future<void> loadField() async {

  final result =
      await supabase
          .from("fields")
          .select()
          .eq(
            "id",
            widget.fieldId,
          )
          .single();

  field = result;

}

Future<void> loadOwner() async {

  if (field == null) return;

  if (field!["owner_id"] == null) return;

  owner =
      await supabase
          .from("profiles")
          .select()
          .eq(
            "id",
            field!["owner_id"],
          )
          .single();

}

Future<void> loadSchedules() async {

  if (field == null) return;

  final result =
      await supabase
          .from("schedules")
          .select()
          .eq(
            "field_id",
            field!["id"],
          )
          .order(
            "date",
            ascending: true,
          )
          .order(
            "start_time",
            ascending: true,
          );

  schedules =
      List<Map<String, dynamic>>.from(result);

}

String formatPrice(int value) {

  return NumberFormat.currency(

    locale: "id",

    symbol: "Rp ",

    decimalDigits: 0,

  ).format(value);

}

List<String> get facilities {

  if (field == null) return [];

  final data =
      field!["facility"] ?? "";

  return data
      .toString()
      .split(",");

}

double get rating {

  if (field == null) return 0;

  return double.tryParse(
        field!["rating"].toString(),
      ) ??
      0;

}

int get price {

  if (field == null) return 0;

  return field!["price"] ?? 0;

}

String get fieldName {

  if (field == null) return "";

  return field!["field_name"] ?? "";

}

String get location {

  if (field == null) return "";

  return field!["location"] ?? "";

}

String get description {

  if (field == null) return "";

  return field!["description"] ?? "";

}

String get imageUrl {

  if (field == null) return "";

  return field!["image_url"] ?? "";

}

  @override
  Widget build(BuildContext context) {

    if (isLoading) {

      return const Scaffold(

        body: Center(

          child: CircularProgressIndicator(),

        ),

      );

    }

    if (field == null) {

      return Scaffold(

        appBar: AppBar(),

        body: const Center(

          child: Text(

            "Lapangan tidak ditemukan",

            style: TextStyle(

              fontSize: 18,

              fontWeight: FontWeight.w600,

            ),

          ),

        ),

      );

    }

    return Scaffold(

      backgroundColor: const Color(0xffF7F8FC),

      body: CustomScrollView(

        slivers: [

          SliverAppBar(

            expandedHeight: 320,

            pinned: true,

            elevation: 0,

            backgroundColor: Colors.white,

            automaticallyImplyLeading: false,

            leading: Padding(

              padding: const EdgeInsets.all(8),

              child: CircleAvatar(

                backgroundColor: Colors.white,

                child: IconButton(

                  icon: const Icon(

                    Icons.arrow_back_ios_new,

                    color: Colors.black,

                    size: 18,

                  ),

                  onPressed: () {

                    Navigator.pop(context);

                  },

                ),

              ),

            ),

            actions: [

              Padding(

                padding: const EdgeInsets.only(

                  right: 12,

                ),

                child: CircleAvatar(

                  backgroundColor: Colors.white,

                  child: IconButton(

                    onPressed: () {

                      setState(() {

                        isFavorite = !isFavorite;

                      });

                    },

                    icon: Icon(

                      isFavorite

                          ? Icons.favorite

                          : Icons.favorite_border,

                      color: Colors.red,

                    ),

                  ),

                ),

              ),

            ],

            flexibleSpace: FlexibleSpaceBar(

              background: Stack(

                fit: StackFit.expand,

                children: [

                  imageUrl.isNotEmpty

                      ? Image.network(

                          imageUrl,

                          fit: BoxFit.cover,

                        )

                      : Image.asset(

                          "assets/images/futsal.jpg",

                          fit: BoxFit.cover,

                        ),

                  Container(

                    decoration: BoxDecoration(

                      gradient: LinearGradient(

                        begin: Alignment.topCenter,

                        end: Alignment.bottomCenter,

                        colors: [

                          Colors.transparent,

                          Colors.black.withOpacity(.55),

                        ],

                      ),

                    ),

                  ),

                  Positioned(

                    left: 24,

                    bottom: 30,

                    right: 24,

                    child: Column(

                      crossAxisAlignment:

                          CrossAxisAlignment.start,

                      children: [

                        Text(

                          fieldName,

                          style: const TextStyle(

                            color: Colors.white,

                            fontSize: 28,

                            fontWeight: FontWeight.bold,

                          ),

                        ),

                        const SizedBox(

                          height: 8,

                        ),

                        Row(

                          children: [

                            const Icon(

                              Icons.location_on,

                              color: Colors.white,

                              size: 18,

                            ),

                            const SizedBox(

                              width: 4,

                            ),

                            Expanded(

                              child: Text(

                                location,

                                style: const TextStyle(

                                  color: Colors.white,

                                  fontSize: 15,

                                ),

                              ),

                            ),

                          ],

                        ),

                      ],

                    ),

                  ),

                ],

              ),

            ),

          ),

          SliverToBoxAdapter(

            child: Padding(

              padding: const EdgeInsets.all(20),

              child: Column(

                crossAxisAlignment:

                    CrossAxisAlignment.start,

                children: [

                  Row(

                    children: [

                      Container(

                        padding:

                            const EdgeInsets.symmetric(

                          horizontal: 14,

                          vertical: 8,

                        ),

                        decoration: BoxDecoration(

                          color: Colors.amber.shade100,

                          borderRadius:

                              BorderRadius.circular(30),

                        ),

                        child: Row(

                          children: [

                            const Icon(

                              Icons.star,

                              color: Colors.orange,

                              size: 18,

                            ),

                            const SizedBox(

                              width: 5,

                            ),

                            Text(

                              rating.toString(),

                              style: const TextStyle(

                                fontWeight:

                                    FontWeight.bold,

                              ),

                            ),

                          ],

                        ),

                      ),

                      const Spacer(),

                      Text(

                        formatPrice(price),

                        style: const TextStyle(

                          fontSize: 24,

                          fontWeight: FontWeight.bold,

                          color: Color(0xff001DFF),

                        ),

                      ),

                    ],

                  ),

                  const SizedBox(height: 10),

                  const Text(

                    "per jam",

                    style: TextStyle(

                      color: Colors.grey,

                    ),

                  ),

                  const SizedBox(height: 28),

                                    Card(

                    elevation: 0,

                    color: Colors.white,

                    shape: RoundedRectangleBorder(

                      borderRadius: BorderRadius.circular(20),

                    ),

                    child: Padding(

                      padding: const EdgeInsets.all(18),

                      child: Row(

                        children: [

                          CircleAvatar(

                            radius: 28,

                            backgroundColor:

                                const Color(0xff001DFF),

                            child: Text(

                              owner == null

                                  ? "O"

                                  : owner!["full_name"][0]

                                      .toUpperCase(),

                              style: const TextStyle(

                                color: Colors.white,

                                fontSize: 22,

                                fontWeight: FontWeight.bold,

                              ),

                            ),

                          ),

                          const SizedBox(width: 15),

                          Expanded(

                            child: Column(

                              crossAxisAlignment:

                                  CrossAxisAlignment.start,

                              children: [

                                Text(

                                  owner == null

                                      ? "Owner"

                                      : owner!["full_name"],

                                  style: const TextStyle(

                                    fontSize: 18,

                                    fontWeight:

                                        FontWeight.bold,

                                  ),

                                ),

                                const SizedBox(height: 5),

                                const Text(

                                  "Pemilik Lapangan",

                                  style: TextStyle(

                                    color: Colors.grey,

                                  ),

                                ),

                              ],

                            ),

                          ),

                          Container(

                            padding:

                                const EdgeInsets.symmetric(

                              horizontal: 12,

                              vertical: 8,

                            ),

                            decoration: BoxDecoration(

                              color: Colors.green.shade50,

                              borderRadius:

                                  BorderRadius.circular(30),

                            ),

                            child: Row(

                              children: const [

                                Icon(

                                  Icons.verified,

                                  size: 18,

                                  color: Colors.green,

                                ),

                                SizedBox(width: 5),

                                Text(

                                  "Verified",

                                  style: TextStyle(

                                    fontWeight:

                                        FontWeight.bold,

                                  ),

                                ),

                              ],

                            ),

                          )

                        ],

                      ),

                    ),

                  ),

                  const SizedBox(height: 30),

                  const Text(

                    "Fasilitas",

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                  const SizedBox(height: 15),

                  Wrap(

                    spacing: 12,

                    runSpacing: 12,

                    children:

                        field!["facility"]

                            .split(",")

                            .map(

                              (e) => buildFacility(

                                e.trim(),

                              ),

                            )

                            .toList(),

                  ),

                  const SizedBox(height: 35),

                  const Text(

                    "Deskripsi",

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                  const SizedBox(height: 15),

                  buildDescription(),

                  const SizedBox(height: 35),

                  const Text(

                    "Jadwal Hari Ini",

                    style: TextStyle(

                      fontSize: 20,

                      fontWeight: FontWeight.bold,

                    ),

                  ),

                  const SizedBox(height: 18),

                  buildSchedulePreview(),

                  const SizedBox(

                    height: 120,

                  ),

                ],

              ),

            ),

          ),

        ],

      ),

      bottomNavigationBar:

          buildBottomBar(),

    );

  }

    Widget buildFacility(String text) {
    IconData icon = Icons.check_circle;

    final lower = text.toLowerCase();

    if (lower.contains("wifi")) {
      icon = Icons.wifi;
    } else if (lower.contains("park")) {
      icon = Icons.local_parking;
    } else if (lower.contains("toilet")) {
      icon = Icons.wc;
    } else if (lower.contains("kantin")) {
      icon = Icons.restaurant;
    } else if (lower.contains("mushola")) {
      icon = Icons.mosque;
    } else if (lower.contains("locker")) {
      icon = Icons.lock;
    } else if (lower.contains("ac")) {
      icon = Icons.ac_unit;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: const Color(0xff001DFF),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        description.isEmpty
            ? "Belum ada deskripsi lapangan."
            : description,
        style: const TextStyle(
          fontSize: 15,
          height: 1.7,
        ),
      ),
    );
  }

  Widget buildSchedulePreview() {
    if (schedules.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            "Belum ada jadwal tersedia",
          ),
        ),
      );
    }

    return Column(
      children: schedules.take(5).map((schedule) {
        final booked =
            schedule["status"] == "booked" ||
            schedule["status"] == "approved";

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: booked
                ? Colors.red.shade50
                : Colors.green.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(
                booked
                    ? Icons.close
                    : Icons.check_circle,
                color:
                    booked
                        ? Colors.red
                        : Colors.green,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "${schedule["date"]}\n${schedule["start_time"]} - ${schedule["end_time"]}",
                ),
              ),
              Text(
                booked ? "Terisi" : "Kosong",
                style: TextStyle(
                  color:
                      booked
                          ? Colors.red
                          : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black12,
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [

            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.chat_bubble),
                label: const Text("Chat Owner"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  foregroundColor: const Color(0xff001DFF),
                  side: const BorderSide(
                    color: Color(0xff001DFF),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Halaman Chat akan dibuka",
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xff001DFF),
                  foregroundColor: Colors.white,
                  minimumSize:
                      const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {

                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Menu Booking akan dibuat selanjutnya",
                      ),
                    ),
                  );

                },
                child: Text(
                  "Booking • ${formatPrice(price)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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