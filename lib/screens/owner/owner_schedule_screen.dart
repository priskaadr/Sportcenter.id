import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class OwnerScheduleScreen extends StatefulWidget {
  const OwnerScheduleScreen({super.key});

  @override
  State<OwnerScheduleScreen> createState() =>
      _OwnerScheduleScreenState();
}

class _OwnerScheduleScreenState
    extends State<OwnerScheduleScreen> {

  final supabase = Supabase.instance.client;

  bool isLoading = true;

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  List ownerFields = [];
  List schedules = [];
  List bookings = [];
  List payments = [];

  Map<DateTime, String> calendarStatus = {};

  int totalBooking = 0;
  int pendingBooking = 0;
  int approvedBooking = 0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {

    try {

      setState(() {
        isLoading = true;
      });

      final user = supabase.auth.currentUser;

      if (user == null) return;

      //--------------------------------------------------
      // FIELD OWNER
      //--------------------------------------------------

      ownerFields = await supabase
          .from('fields')
          .select()
          .eq('owner_id', user.id);

      if (ownerFields.isEmpty) {

        setState(() {
          isLoading = false;
        });

        return;
      }

      final fieldIds =
          ownerFields.map((e) => e['id']).toList();

      //--------------------------------------------------
      // SCHEDULE
      //--------------------------------------------------

      schedules = await supabase
          .from('schedules')
          .select()
          .inFilter(
            'field_id',
            fieldIds,
          );

      //--------------------------------------------------
      // BOOKING
      //--------------------------------------------------

      bookings = await supabase
          .from('bookings')
          .select()
          .inFilter(
            'field_id',
            fieldIds,
          )
          .order(
            'created_at',
            ascending: false,
          );

      //--------------------------------------------------
      // PAYMENT
      //--------------------------------------------------

      payments = await supabase
          .from('payments')
          .select();

      //--------------------------------------------------
      // HITUNG STATUS
      //--------------------------------------------------

      totalBooking = bookings.length;

      pendingBooking = bookings.where(
        (e) =>
            e['status'] == 'pending' ||
            e['status'] == 'booked',
      ).length;

      approvedBooking = bookings.where(
        (e) =>
            e['status'] == 'approved',
      ).length;

      //--------------------------------------------------
      // KALENDER
      //--------------------------------------------------

      calendarStatus.clear();

      for (var item in schedules) {

        final date =
            DateTime.parse(item['date']);

        calendarStatus[
            DateTime(
              date.year,
              date.month,
              date.day,
            )] = item['status'];
      }

      setState(() {
        isLoading = false;
      });

    } catch (e) {

      debugPrint(
        "Owner Schedule Error : $e",
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  //--------------------------------------------------
  // MENCARI DATA FIELD
  //--------------------------------------------------

  Map? getField(String id) {

    try {

      return ownerFields.firstWhere(
        (e) => e['id'] == id,
      );

    } catch (_) {

      return null;
    }
  }

  //--------------------------------------------------
  // MENCARI DATA SCHEDULE
  //--------------------------------------------------

  Map? getSchedule(String id) {

    try {

      return schedules.firstWhere(
        (e) => e['id'] == id,
      );

    } catch (_) {

      return null;
    }
  }

  //--------------------------------------------------
  // MENCARI DATA PAYMENT
  //--------------------------------------------------

  Map? getPayment(String bookingId) {

    try {

      return payments.firstWhere(
        (e) =>
            e['booking_id'] ==
            bookingId,
      );

    } catch (_) {

      return null;
    }
  }

  //--------------------------------------------------
  // WARNA STATUS KALENDER
  //--------------------------------------------------

  Color getCalendarColor(
      DateTime day) {

    final key = DateTime(
      day.year,
      day.month,
      day.day,
    );

    final status =
        calendarStatus[key];

    if (day.isBefore(
      DateTime.now().subtract(
        const Duration(days: 1),
      ),
    )) {

      return Colors.grey;
    }

    if (status == null) {

      return Colors.blue;
    }

    switch (status) {

      case "available":
        return Colors.blue;

      case "booked":
        return Colors.amber;

      case "occupied":
        return Colors.grey;

      default:
        return Colors.blue;
    }
  }

  //--------------------------------------------------
  // ACC BOOKING
  //--------------------------------------------------

  Future<void> approveBooking(Map booking) async {

    try {

      await supabase
          .from('bookings')
          .update({
            'status': 'approved',
          })
          .eq(
            'id',
            booking['id'],
          );

      await supabase
          .from('schedules')
          .update({
            'status': 'occupied',
          })
          .eq(
            'id',
            booking['schedule_id'],
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Booking berhasil di ACC",
          ),
          backgroundColor: Colors.green,
        ),
      );

      loadData();

    } catch (e) {

      debugPrint(e.toString());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  //--------------------------------------------------
  // CARD STATISTIK
  //--------------------------------------------------

  Widget statCard({

    required String title,
    required String value,
    required IconData icon,

  }) {

    return Expanded(

      child: Container(

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(

          color: Colors.white,

          borderRadius:
              BorderRadius.circular(20),

          boxShadow: const [

            BoxShadow(

              color: Colors.black12,

              blurRadius: 8,

              offset: Offset(0,3),

            )

          ],

        ),

        child: Column(

          children: [

            CircleAvatar(

              radius: 22,

              backgroundColor:
                  const Color(0xff001DFF)
                      .withOpacity(.1),

              child: Icon(

                icon,

                color: const Color(0xff001DFF),

              ),

            ),

            const SizedBox(height: 12),

            Text(

              value,

              style: const TextStyle(

                fontWeight: FontWeight.bold,

                fontSize: 22,

              ),

            ),

            const SizedBox(height: 4),

            Text(

              title,

              style: const TextStyle(

                color: Colors.grey,

              ),

            ),

          ],

        ),

      ),

    );

  }

  //--------------------------------------------------
  // STATUS BOOKING
  //--------------------------------------------------

  Color bookingStatusColor(String status){

    switch(status){

      case "approved":
        return Colors.green;

      case "pending":
        return Colors.orange;

      case "booked":
        return Colors.orange;

      default:
        return Colors.grey;
    }

  }

  //--------------------------------------------------
  // STATUS PEMBAYARAN
  //--------------------------------------------------

  Color paymentColor(String status){

    if(status=="paid"){

      return Colors.green;

    }

    return Colors.red;

  }

  //--------------------------------------------------
  // BOOKING CARD
  //--------------------------------------------------

  Widget bookingCard(Map booking){

    final field =
        getField(
          booking['field_id'],
        );

    final schedule =
        getSchedule(
          booking['schedule_id'],
        );

    final payment =
        getPayment(
          booking['id'],
        );

    if(field==null || schedule==null){

      return const SizedBox();

    }

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(20),

        boxShadow: const [

          BoxShadow(

            color: Colors.black12,

            blurRadius: 10,

            offset: Offset(0,4),

          )

        ],

      ),

      child: Padding(

        padding:
            const EdgeInsets.all(18),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(

              children: [

                Container(

                  padding:
                      const EdgeInsets.all(10),

                  decoration: BoxDecoration(

                    color: const Color(
                            0xff001DFF)
                        .withOpacity(.1),

                    borderRadius:
                        BorderRadius.circular(
                            12),

                  ),

                  child: const Icon(

                    Icons.sports_soccer,

                    color:
                        Color(0xff001DFF),

                  ),

                ),

                const SizedBox(width:12),

                Expanded(

                  child: Text(

                    field['field_name'] ?? "-",

                    style: const TextStyle(

                      fontWeight:
                          FontWeight.bold,

                      fontSize:18,

                    ),

                  ),

                )

              ],

            ),

            const SizedBox(height:15),

            Row(

              children: [

                const Icon(

                  Icons.calendar_month,

                  size:18,

                  color: Colors.grey,

                ),

                const SizedBox(width:8),

                Text(

                  DateFormat(
                    "dd MMM yyyy",
                  ).format(

                    DateTime.parse(
                      schedule['date'],
                    ),

                  ),

                ),

              ],

            ),

            const SizedBox(height:8),

            Row(

              children: [

                const Icon(

                  Icons.access_time,

                  size:18,

                  color: Colors.grey,

                ),

                const SizedBox(width:8),

                Text(

                  "${schedule['start_time']} - ${schedule['end_time']}",

                ),

              ],

            ),

            const SizedBox(height:16),

            Row(

              children: [

                Container(

                  padding:
                      const EdgeInsets.symmetric(

                    horizontal:12,

                    vertical:6,

                  ),

                  decoration: BoxDecoration(

                    color: paymentColor(

                      payment?['payment_status']
                          ?? "unpaid",

                    ),

                    borderRadius:
                        BorderRadius.circular(20),

                  ),

                  child: Text(

                    payment?['payment_status']
                            ?.toUpperCase() ??
                        "UNPAID",

                    style: const TextStyle(

                      color: Colors.white,

                      fontWeight:
                          FontWeight.bold,

                    ),

                  ),

                ),

                const Spacer(),

                Container(

                  padding:
                      const EdgeInsets.symmetric(

                    horizontal:12,

                    vertical:6,

                  ),

                  decoration: BoxDecoration(

                    color: bookingStatusColor(

                      booking['status'],

                    ),

                    borderRadius:
                        BorderRadius.circular(20),

                  ),

                  child: Text(

                    booking['status']
                        .toUpperCase(),

                    style: const TextStyle(

                      color: Colors.white,

                      fontWeight:
                          FontWeight.bold,

                    ),

                  ),

                ),

              ],

            ),

            if(

            booking['status']=="pending" ||

            booking['status']=="booked"

            )

            Padding(

              padding:
                  const EdgeInsets.only(
                top:18,
              ),

              child: SizedBox(

                width:
                    double.infinity,

                height:50,

                child: ElevatedButton(

                  style:
                      ElevatedButton.styleFrom(

                    backgroundColor:
                        Colors.amber,

                    shape:
                        RoundedRectangleBorder(

                      borderRadius:
                          BorderRadius.circular(
                              15),

                    ),

                  ),

                  onPressed: (){

                    approveBooking(
                        booking);

                  },

                  child: const Text(

                    "ACC BOOKING",

                    style: TextStyle(

                      color: Colors.black,

                      fontWeight:
                          FontWeight.bold,

                    ),

                  ),

                ),

              ),

            )

          ],

        ),

      ),

    );

  }
      Widget legendItem(
      Color color,
      String text,
    ) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xffF5F7FB),

      body: isLoading

          ? const Center(
              child: CircularProgressIndicator(),
            )

          : RefreshIndicator(

              onRefresh: loadData,

              child: ListView(

                padding: EdgeInsets.zero,

                children: [

                  //------------------------------------------------
                  // HEADER
                  //------------------------------------------------

                  Container(

                    padding: const EdgeInsets.fromLTRB(
                      20,
                      55,
                      20,
                      30,
                    ),

                    decoration: const BoxDecoration(

                      gradient: LinearGradient(

                        begin: Alignment.topLeft,

                        end: Alignment.bottomRight,

                        colors: [

                          Color(0xff001DFF),

                          Color(0xff4D73FF),

                        ],

                      ),

                      borderRadius: BorderRadius.only(

                        bottomLeft: Radius.circular(35),

                        bottomRight: Radius.circular(35),

                      ),

                    ),

                    child: Column(

                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        const Text(

                          "Owner Schedule",

                          style: TextStyle(

                            color: Colors.white70,

                            fontSize: 16,

                          ),

                        ),

                        const SizedBox(height: 6),

                        const Text(

                          "Kelola Jadwal Booking",

                          style: TextStyle(

                            color: Colors.white,

                            fontSize: 28,

                            fontWeight: FontWeight.bold,

                          ),

                        ),

                        const SizedBox(height: 25),

                        Row(

                          children: [

                            statCard(

                              title: "Booking",

                              value:
                                  totalBooking.toString(),

                              icon:
                                  Icons.calendar_month,

                            ),

                            const SizedBox(width: 12),

                            statCard(

                              title: "Pending",

                              value:
                                  pendingBooking.toString(),

                              icon:
                                  Icons.pending_actions,

                            ),

                            const SizedBox(width: 12),

                            statCard(

                              title: "Approved",

                              value:
                                  approvedBooking.toString(),

                              icon:
                                  Icons.verified,

                            ),

                          ],

                        ),

                      ],

                    ),

                  ),

                  const SizedBox(height: 20),

                                    //------------------------------------------------
                  // CALENDAR
                  //------------------------------------------------

                  Padding(

                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),

                    child: Container(

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                            BorderRadius.circular(25),

                        boxShadow: const [

                          BoxShadow(

                            color: Colors.black12,

                            blurRadius: 10,

                            offset: Offset(0,4),

                          )

                        ],

                      ),

                      child: Padding(

                        padding:
                            const EdgeInsets.all(16),

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment.start,

                          children: [

                            const Text(

                              "Kalender Booking",

                              style: TextStyle(

                                fontSize: 20,

                                fontWeight:
                                    FontWeight.bold,

                              ),

                            ),

                            const SizedBox(height: 15),

                            TableCalendar(

                              firstDay:
                                  DateTime(2024),

                              lastDay:
                                  DateTime(2035),

                              focusedDay:
                                  focusedDay,

                              selectedDayPredicate:
                                  (day) {

                                return isSameDay(
                                  selectedDay,
                                  day,
                                );

                              },

                              onDaySelected:
                                  (selected,
                                      focused) {

                                setState(() {

                                  selectedDay =
                                      selected;

                                  focusedDay =
                                      focused;

                                });

                              },

                              headerStyle:
                                  const HeaderStyle(

                                titleCentered:
                                    true,

                                formatButtonVisible:
                                    false,

                              ),

                              calendarStyle:
                                  CalendarStyle(

                                todayDecoration:

                                    const BoxDecoration(

                                  color:
                                      Color(
                                          0xff001DFF),

                                  shape:
                                      BoxShape.circle,

                                ),

                                selectedDecoration:

                                    const BoxDecoration(

                                  color:
                                      Colors.red,

                                  shape:
                                      BoxShape.circle,

                                ),

                              ),

                              calendarBuilders:

                                  CalendarBuilders(

                                defaultBuilder:

                                    (
                                  context,
                                  day,
                                  focusedDay,
                                ) {

                                  final color =
                                      getCalendarColor(
                                    day,
                                  );

                                  return Container(

                                    margin:
                                        const EdgeInsets
                                            .all(4),

                                    decoration:

                                        BoxDecoration(

                                      color: color,

                                      shape: BoxShape.circle,

                                    ),

                                    child: Center(

                                      child: Text(

                                        "${day.day}",

                                        style:
                                            const TextStyle(

                                          color:
                                              Colors.white,

                                          fontWeight:
                                              FontWeight.bold,

                                        ),

                                      ),

                                    ),

                                  );

                                },

                              ),

                            ),

                            const SizedBox(height:20),

                            const Divider(),

                            const SizedBox(height:15),

                            Wrap(

                              spacing: 18,

                              runSpacing: 12,

                              alignment:
                                  WrapAlignment.center,

                              children: [

                                legendItem(

                                  Colors.blue,

                                  "Tersedia",

                                ),

                                legendItem(

                                  Colors.amber,

                                  "Menunggu ACC",

                                ),

                                legendItem(

                                  Colors.grey,

                                  "Sudah ACC / Lewat",

                                ),

                              ],

                            ),

                          ],

                        ),

                      ),

                    ),

                  ),

                  const SizedBox(height:25),

                                    //------------------------------------------------
                  // LIST BOOKING
                  //------------------------------------------------

                  Padding(

                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),

                    child: bookings.isEmpty

                        ? Container(

                            padding:
                                const EdgeInsets.all(30),

                            decoration: BoxDecoration(

                              color: Colors.white,

                              borderRadius:
                                  BorderRadius.circular(20),

                              boxShadow: const [

                                BoxShadow(

                                  color: Colors.black12,

                                  blurRadius: 8,

                                )

                              ],

                            ),

                            child: const Center(

                              child: Column(

                                children: [

                                  Icon(

                                    Icons.event_busy,

                                    size: 70,

                                    color: Colors.grey,

                                  ),

                                  SizedBox(height: 15),

                                  Text(

                                    "Belum ada booking",

                                    style: TextStyle(

                                      fontSize: 18,

                                      fontWeight: FontWeight.bold,

                                    ),

                                  ),

                                  SizedBox(height: 6),

                                  Text(

                                    "Booking pelanggan akan muncul di sini.",

                                    textAlign: TextAlign.center,

                                    style: TextStyle(

                                      color: Colors.grey,

                                    ),

                                  ),

                                ],

                              ),

                            ),

                          )

                        : Column(

                            children:

                                bookings

                                    .map<Widget>(

                                      (booking) => bookingCard(

                                        booking,

                                      ),

                                    )

                                    .toList(),

                          ),

                  ),

                  const SizedBox(height:30),

                ],

              ),

            ),

    );

  }

}