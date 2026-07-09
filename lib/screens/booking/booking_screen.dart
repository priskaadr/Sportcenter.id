import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final String fieldId;

  const BookingScreen({
    super.key,
    required this.fieldId,
  });

  @override
  State<BookingScreen> createState() =>
      _BookingScreenState();
}

class _BookingScreenState
    extends State<BookingScreen> {

  //--------------------------------------------------
  // Supabase
  //--------------------------------------------------

  final supabase =
      Supabase.instance.client;

  //--------------------------------------------------
  // Loading
  //--------------------------------------------------

  bool loading = true;

  //--------------------------------------------------
  // Data Lapangan
  //--------------------------------------------------

  Map<String, dynamic>? field;

  //--------------------------------------------------
  // Semua Booking
  //--------------------------------------------------

  List<Map<String, dynamic>> bookings = [];

  //--------------------------------------------------
  // Kalender
  //--------------------------------------------------

  DateTime focusedDay =
      DateTime.now();

  DateTime selectedDay =
      DateTime.now();

  //--------------------------------------------------
  // Jam yang dipilih
  //--------------------------------------------------

  TimeOfDay? selectedStartTime;

  TimeOfDay? selectedEndTime;

  //--------------------------------------------------
  // Durasi
  //--------------------------------------------------

  int duration = 1;

  //--------------------------------------------------
  // Catatan
  //--------------------------------------------------

  final noteController =
      TextEditingController();

  //--------------------------------------------------
  // Daftar Jam Operasional
  //--------------------------------------------------

  final List<String> timeSlots = [

    "08:00",
    "09:00",
    "10:00",
    "11:00",

    "12:00",
    "13:00",
    "14:00",
    "15:00",

    "16:00",
    "17:00",
    "18:00",
    "19:00",

    "20:00",
    "21:00",
    "22:00",

  ];

  //--------------------------------------------------
  // Init
  //--------------------------------------------------

  @override
  void initState() {
    super.initState();

    loadData();
  }

  //--------------------------------------------------
  // Dispose
  //--------------------------------------------------

  @override
  void dispose() {

    noteController.dispose();

    super.dispose();

  }

  //--------------------------------------------------
  // Load Semua Data
  //--------------------------------------------------

  Future<void> loadData() async {

    try {

      //------------------------------------
      // Field
      //------------------------------------

      field =
          await supabase
              .from("fields")
              .select()
              .eq(
                "id",
                widget.fieldId,
              )
              .single();

      //------------------------------------
      // Booking
      //------------------------------------

      final result =
          await supabase
              .from("bookings")
              .select()
              .eq(
                "field_id",
                widget.fieldId,
              );

      bookings =
          List<Map<String, dynamic>>
              .from(result);

    } catch (e) {

      debugPrint(
          "ERROR LOAD = $e");

    }

    if (mounted) {

      setState(() {

        loading = false;

      });

    }

  }

  //--------------------------------------------------
  // Getter
  //--------------------------------------------------

  String get fieldName {

    if (field == null) {

      return "";

    }

    return field!["field_name"];

  }

  String get imageUrl {

    if (field == null) {

      return "";

    }

    return field!["image_url"] ?? "";

  }

  String get location {

    if (field == null) {

      return "";

    }

    return field!["location"] ?? "";

  }

  int get price {

    if (field == null) {

      return 0;

    }

    return field!["price"] ?? 0;

  }

  //--------------------------------------------------
  // Rupiah
  //--------------------------------------------------

  String rupiah(int value){

    return NumberFormat.currency(

      locale: "id",

      symbol: "Rp ",

      decimalDigits: 0,

    ).format(value);

  }

  //--------------------------------------------------
  // Convert Time
  //--------------------------------------------------

  TimeOfDay parseTime(
      String value){

    final split =
        value.split(":");

    return TimeOfDay(

      hour:
          int.parse(split[0]),

      minute:
          int.parse(split[1]),

    );

  }

  //--------------------------------------------------
  // Convert String
  //--------------------------------------------------

  String formatTime(
      TimeOfDay time){

    final h =
        time.hour
            .toString()
            .padLeft(2, "0");

    final m =
        time.minute
            .toString()
            .padLeft(2, "0");

    return "$h:$m";

  }

  //--------------------------------------------------
  // Hitung End Time
  //--------------------------------------------------

  TimeOfDay calculateEndTime(
      TimeOfDay start){

    final total =
        start.hour + duration;

    return TimeOfDay(

      hour: total,

      minute: 0,

    );

  }

  //--------------------------------------------------
  // Build
  //--------------------------------------------------

  @override
  Widget build(
      BuildContext context){

    if(loading){

      return const Scaffold(

        body: Center(

          child:
              CircularProgressIndicator(),

        ),

      );

    }

        return Scaffold(
          
        backgroundColor:
            const Color(0xffF5F6FA),

        appBar: AppBar(
        
          title:
              const Text("Booking"),

        ),

        body: SingleChildScrollView(
        
          child: Column(
          
            children: [
            
              buildHeader(),

              buildCalendar(),

              buildTimeGrid(),

              buildDuration(),

              buildNote(),

              buildSummary(),

              const SizedBox(height:120),

            ],

          ),

        ),

        bottomNavigationBar:
            buildBottomBar(),

      );

  }

  //--------------------------------------------------
  // Header
  //--------------------------------------------------

  Widget buildHeader(){

    return Container(

      margin:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          ClipRRect(

            borderRadius:
                const BorderRadius.vertical(

              top:
                  Radius.circular(20),

            ),

            child: imageUrl.isEmpty

                ? Image.asset(

                    "assets/images/futsal.jpg",

                    height: 220,

                    width:
                        double.infinity,

                    fit: BoxFit.cover,

                  )

                : Image.network(

                    imageUrl,

                    height: 220,

                    width:
                        double.infinity,

                    fit: BoxFit.cover,

                  ),

          ),

          Padding(

            padding:
                const EdgeInsets.all(18),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(

                  fieldName,

                  style:
                      const TextStyle(

                    fontSize: 22,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),

                const SizedBox(
                    height: 8),

                Row(

                  children: [

                    const Icon(

                      Icons.location_on,

                      color: Colors.red,

                    ),

                    const SizedBox(
                        width: 6),

                    Expanded(

                      child:
                          Text(location),

                    )

                  ],

                ),

                const SizedBox(
                    height: 15),

                Text(

                  "${rupiah(price)} / Jam",

                  style:
                      const TextStyle(

                    fontSize: 20,

                    color: Colors.blue,

                    fontWeight:
                        FontWeight.bold,

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

  //--------------------------------------------------
  // Calendar
  //--------------------------------------------------

  Widget buildCalendar(){

    return Card(

      margin:
          const EdgeInsets.symmetric(
              horizontal: 16),

      child: Padding(

        padding:
            const EdgeInsets.all(10),

        child: TableCalendar(

          firstDay:
              DateTime.now(),

          lastDay:
              DateTime.now().add(

            const Duration(

              days: 365,

            ),

          ),

          focusedDay:
              focusedDay,

          selectedDayPredicate:

              (day){

            return isSameDay(

              selectedDay,

              day,

            );

          },

          onDaySelected:

              (selected, focused){

            setState(() {

              selectedDay =
                  selected;

              focusedDay =
                  focused;

              selectedStartTime =
                  null;

              selectedEndTime =
                  null;

            });

          },

        ),

      ),

    );

  }

  //--------------------------------------------------
// Cek Slot Sudah Dibooking
//--------------------------------------------------

bool isBooked(String startHour) {

  final bookingDate = DateFormat(
    "yyyy-MM-dd",
  ).format(selectedDay);

  for (final booking in bookings) {

    if (booking["booking_date"] != bookingDate) {
      continue;
    }

    final status =
        booking["status"] ?? "";

    if (status == "cancelled") {
      continue;
    }

    final bookedStart =
        booking["start_time"]
            .toString()
            .substring(0, 5);

    if (bookedStart == startHour) {
      return true;
    }
  }

  return false;
}

////////////////////////////////////////////////////
/// PILIH JAM
////////////////////////////////////////////////////

Widget buildTimeGrid() {

  return Container(

    margin: const EdgeInsets.all(16),

    child: Column(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        const Text(

          "Pilih Jam",

          style: TextStyle(

            fontWeight:
                FontWeight.bold,

            fontSize: 18,

          ),

        ),

        const SizedBox(height: 15),

        GridView.builder(

          shrinkWrap: true,

          physics:
              const NeverScrollableScrollPhysics(),

          itemCount:
              timeSlots.length,

          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(

            crossAxisCount: 2,

            crossAxisSpacing: 12,

            mainAxisSpacing: 12,

            childAspectRatio: 2.7,

          ),

          itemBuilder:
              (context, index) {

            final time =
                timeSlots[index];

            final booked =
                isBooked(time);

            final selected =
                selectedStartTime !=
                    null &&
                    formatTime(
                        selectedStartTime!) ==
                        time;

            return GestureDetector(

              onTap: booked
                  ? null
                  : () {

                      final start =
                          parseTime(time);

                      setState(() {

                        selectedStartTime =
                            start;

                        selectedEndTime =
                            calculateEndTime(
                                start);

                      });

                    },

              child: Container(

                decoration:
                    BoxDecoration(

                  color: selected
                      ? Colors.blue
                      : booked
                          ? Colors.red
                              .shade100
                          : Colors.green
                              .shade100,

                  borderRadius:
                      BorderRadius.circular(
                          16),

                ),

                child: Column(

                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,

                  children: [

                    Text(

                      time,

                      style:
                          TextStyle(

                        fontWeight:
                            FontWeight
                                .bold,

                        color: selected
                            ? Colors.white
                            : Colors.black,

                      ),

                    ),

                    const SizedBox(
                        height: 5),

                    Text(

                      booked
                          ? "Terisi"
                          : "Tersedia",

                      style:
                          TextStyle(

                        color: selected
                            ? Colors.white70
                            : Colors.black54,

                        fontSize: 12,

                      ),

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

}

////////////////////////////////////////////////////
/// DURASI
////////////////////////////////////////////////////

Widget buildDuration() {

  return Card(

    margin:
        const EdgeInsets.symmetric(
            horizontal: 16),

    child: Padding(

      padding:
          const EdgeInsets.all(16),

      child: Row(

        children: [

          const Text(

            "Durasi",

            style: TextStyle(

              fontSize: 18,

              fontWeight:
                  FontWeight.bold,

            ),

          ),

          const Spacer(),

          IconButton(

            onPressed: () {

              if (duration > 1) {

                setState(() {

                  duration--;

                  if (selectedStartTime !=
                      null) {

                    selectedEndTime =
                        calculateEndTime(
                            selectedStartTime!);

                  }

                });

              }

            },

            icon: const Icon(
              Icons.remove_circle,
            ),

          ),

          Text(

            "$duration Jam",

            style: const TextStyle(

              fontSize: 18,

              fontWeight:
                  FontWeight.bold,

            ),

          ),

          IconButton(

            onPressed: () {

              setState(() {

                duration++;

                if (selectedStartTime !=
                    null) {

                  selectedEndTime =
                      calculateEndTime(
                          selectedStartTime!);

                }

              });

            },

            icon: const Icon(
              Icons.add_circle,
            ),

          ),

        ],

      ),

    ),

  );

}

////////////////////////////////////////////////////
/// CATATAN
////////////////////////////////////////////////////

Widget buildNote() {

  return Card(

    margin: const EdgeInsets.all(16),

    child: Padding(

      padding:
          const EdgeInsets.all(16),

      child: TextField(

        controller:
            noteController,

        maxLines: 4,

        decoration:
            const InputDecoration(

          border:
              OutlineInputBorder(),

          hintText:
              "Catatan tambahan",

        ),

      ),

    ),

  );

}

////////////////////////////////////////////////////
/// TOTAL
////////////////////////////////////////////////////

int get totalPrice {

  return price * duration;

}

////////////////////////////////////////////////////
/// RINGKASAN
////////////////////////////////////////////////////

Widget buildSummary() {

  return Card(

    margin:
        const EdgeInsets.symmetric(
            horizontal: 16),

    child: Padding(

      padding:
          const EdgeInsets.all(18),

      child: Column(

        children: [

          Row(

            children: [

              const Text(
                  "Harga"),

              const Spacer(),

              Text(
                  rupiah(price)),

            ],

          ),

          const SizedBox(
              height: 10),

          Row(

            children: [

              const Text(
                  "Durasi"),

              const Spacer(),

              Text(
                  "$duration Jam"),

            ],

          ),

          const Divider(),

          Row(

            children: [

              const Text(

                "Total",

                style: TextStyle(

                  fontWeight:
                      FontWeight.bold,

                  fontSize: 18,

                ),

              ),

              const Spacer(),

              Text(

                rupiah(totalPrice),

                style:
                    const TextStyle(

                  fontWeight:
                      FontWeight.bold,

                  color: Colors.blue,

                  fontSize: 20,

                ),

              ),

            ],

          ),

        ],

      ),

    ),

  );

}

//--------------------------------------------------
// CEK SLOT BENTROK
//--------------------------------------------------

bool hasConflict() {

  if (selectedStartTime == null ||
      selectedEndTime == null) {
    return true;
  }

  final bookingDate =
      DateFormat(
        "yyyy-MM-dd",
      ).format(selectedDay);

  final start =
      formatTime(selectedStartTime!);

  final end =
      formatTime(selectedEndTime!);

  for (final booking in bookings) {

    if (booking["booking_date"] != bookingDate) {
      continue;
    }

    if (booking["status"] == "cancelled") {
      continue;
    }

    final bookedStart =
        booking["start_time"]
            .toString()
            .substring(0, 5);

    final bookedEnd =
        booking["end_time"]
            .toString()
            .substring(0, 5);

    //---------------------------------------
    // overlap
    //---------------------------------------

    if (!(end.compareTo(bookedStart) <= 0 ||
        start.compareTo(bookedEnd) >= 0)) {
      return true;
    }
  }

  return false;
}

////////////////////////////////////////////////////
/// VALIDASI
////////////////////////////////////////////////////

bool validateBooking() {

  if (selectedStartTime == null) {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text(
          "Silakan pilih jam terlebih dahulu",
        ),

      ),

    );

    return false;

  }

  if (hasConflict()) {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text(
          "Jam tersebut sudah dibooking",
        ),

      ),

    );

    return false;

  }

  return true;

}

////////////////////////////////////////////////////
/// BOTTOM BAR
////////////////////////////////////////////////////

Widget buildBottomBar() {

  return SafeArea(

    child: Container(

      padding: const EdgeInsets.all(20),

      decoration: const BoxDecoration(

        color: Colors.white,

        boxShadow: [

          BoxShadow(

            color: Colors.black12,

            blurRadius: 8,

          )

        ],

      ),

      child: ElevatedButton(

        style: ElevatedButton.styleFrom(

          backgroundColor:
              Colors.blue,

          minimumSize:
              const Size(
                  double.infinity,
                  60),

          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(
                    18),

          ),

        ),

        onPressed: () {

          if (!validateBooking()) {
            return;
          }

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) =>
                  PaymentScreen(

                field: field!,

                bookingDate:
                    selectedDay,

                startTime:
                    formatTime(
                        selectedStartTime!),

                endTime:
                    formatTime(
                        selectedEndTime!),

                duration:
                    duration,

                note:
                    noteController.text,

                totalPrice:
                    totalPrice,

              ),

            ),

          );

        },

        child: Text(

          "Pesan Sekarang • ${rupiah(totalPrice)}",

          style:
              const TextStyle(

            color: Colors.white,

            fontWeight:
                FontWeight.bold,

            fontSize: 18,

          ),

        ),

      ),

    ),

  );

}

  }