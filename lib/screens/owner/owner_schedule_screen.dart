import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat/owner_chat_room_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerScheduleScreen extends StatefulWidget {
  const OwnerScheduleScreen({super.key});

  @override
  State<OwnerScheduleScreen> createState() => _OwnerScheduleScreenState();
}

class _OwnerScheduleScreenState extends State<OwnerScheduleScreen> {
  //-------------------------------------------------------
  // Supabase
  //-------------------------------------------------------

  final supabase = Supabase.instance.client;

  //-------------------------------------------------------
  // Controller
  //-------------------------------------------------------

  final TextEditingController searchController = TextEditingController();

  //-------------------------------------------------------
  // Formatter
  //-------------------------------------------------------

  final currency = NumberFormat.currency(
    locale: "id_ID",
    symbol: "Rp ",
    decimalDigits: 0,
  );

  final formatter = DateFormat("dd MMM yyyy", "id_ID");

  //-------------------------------------------------------
  // Data
  //-------------------------------------------------------

  bool isLoading = true;

  int selectedIndex = 0;

  List<Map<String, dynamic>> allBookings = [];

  List<Map<String, dynamic>> pendingBookings = [];

  List<Map<String, dynamic>> approvedBookings = [];

  List<Map<String, dynamic>> rejectedBookings = [];

  List<Map<String, dynamic>> finishedBookings = [];

  List<Map<String, dynamic>> filteredBookings = [];

  //-------------------------------------------------------
  // Realtime
  //-------------------------------------------------------

  RealtimeChannel? bookingChannel;

  //-------------------------------------------------------
  // Init
  //-------------------------------------------------------

  @override
  void initState() {
    super.initState();

    loadBookings();

    realtimeBooking();

    searchController.addListener(() {
      filterBookings();
    });
  }

  //-------------------------------------------------------
  // Dispose
  //-------------------------------------------------------

  @override
  void dispose() {
    searchController.dispose();

    if (bookingChannel != null) {
      supabase.removeChannel(bookingChannel!);
    }

    super.dispose();
  }

  //-------------------------------------------------------
  // Realtime
  //-------------------------------------------------------

  void realtimeBooking() {
    bookingChannel = supabase.channel("owner-booking");

    bookingChannel!
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: "public",
          table: "bookings",
          callback: (payload) async {
            await loadBookings();
          },
        )
        .subscribe();
  }

  //-------------------------------------------------------
  // Load Booking
  //-------------------------------------------------------

  Future<void> loadBookings() async {
    try {
      setState(() {
        isLoading = true;
      });

      final ownerId = supabase.auth.currentUser!.id;

      final fieldResult = await supabase
          .from("fields")
          .select("id")
          .eq("owner_id", ownerId);

      final fieldIds = fieldResult
          .map<String>((e) => e["id"] as String)
          .toList();

      if (fieldIds.isEmpty) {
        setState(() {
          allBookings = [];
          pendingBookings = [];
          approvedBookings = [];
          rejectedBookings = [];
          finishedBookings = [];
          filteredBookings = [];
          isLoading = false;
        });

        return;
      }

      final bookingResult = await supabase
          .from("bookings")
          .select("""
              *,
              fields(
                field_name,
                location
              ),
              profiles!bookings_customer_id_fkey(
                full_name,
                phone,
                avatar_url
              ),
              payments(
                id,
                amount,
                payment_status,
                payment_method,
                payment_proof,
                payment_date
              )
          """)
          .inFilter("field_id", fieldIds)
          .order("booking_date", ascending: false);

      allBookings = List<Map<String, dynamic>>.from(bookingResult);

      pendingBookings = allBookings
          .where((e) => e["status"] == "pending")
          .toList();

      approvedBookings = allBookings
          .where((e) => e["status"] == "approved")
          .toList();

      rejectedBookings = allBookings
          .where((e) => e["status"] == "rejected")
          .toList();

      finishedBookings = allBookings
          .where((e) => e["status"] == "finished")
          .toList();

      filterBookings();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  //-------------------------------------------------------
  // Filter
  //-------------------------------------------------------

  void filterBookings() {
    String keyword = searchController.text.toLowerCase().trim();

    List<Map<String, dynamic>> source;

    switch (selectedIndex) {
      case 1:
        source = pendingBookings;
        break;

      case 2:
        source = approvedBookings;
        break;

      case 3:
        source = rejectedBookings;
        break;

      case 4:
        source = finishedBookings;
        break;

      default:
        source = allBookings;
    }

    if (keyword.isEmpty) {
      filteredBookings = List.from(source);
    } else {
      filteredBookings = source.where((booking) {
        final profile = booking["profiles"];

        final name = (profile?["full_name"] ?? "").toString().toLowerCase();

        final field = booking["fields"];

        final fieldName = (field?["field_name"] ?? "").toString().toLowerCase();

        return name.contains(keyword) || fieldName.contains(keyword);
      }).toList();
    }

    if (mounted) {
      setState(() {});
    }
  }

  //-------------------------------------------------------
  // Refresh
  //-------------------------------------------------------

  Future<void> refreshData() async {
    await loadBookings();
  }

  //-------------------------------------------------------
  // Approve Booking
  //-------------------------------------------------------

  Future<void> approveBooking(Map<String, dynamic> booking) async {
    try {
      await supabase
          .from("bookings")
          .update({"status": "approved"})
          .eq("id", booking["id"]);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking berhasil disetujui")),
      );

      await loadBookings();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  //-------------------------------------------------------
  // Reject Booking
  //-------------------------------------------------------

  Future<void> rejectBooking(Map<String, dynamic> booking) async {
    try {
      await supabase
          .from("bookings")
          .update({"status": "rejected"})
          .eq("id", booking["id"]);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking berhasil ditolak")));

      await loadBookings();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  //-------------------------------------------------------
  // Finish Booking
  //-------------------------------------------------------

  Future<void> finishBooking(Map<String, dynamic> booking) async {
    try {
      await supabase
          .from("bookings")
          .update({"status": "finished"})
          .eq("id", booking["id"]);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking selesai")));

      await loadBookings();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  //-------------------------------------------------------
  // Dialog Approve
  //-------------------------------------------------------

  Future<void> showApproveDialog(Map<String, dynamic> booking) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Setujui booking ini?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Setujui"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await approveBooking(booking);
    }
  }

  //-------------------------------------------------------
  // Dialog Reject
  //-------------------------------------------------------

  Future<void> showRejectDialog(Map<String, dynamic> booking) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Tolak booking ini?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Tolak"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await rejectBooking(booking);
    }
  }

  //-------------------------------------------------------
  // Dialog Finish
  //-------------------------------------------------------

  Future<void> showFinishDialog(Map<String, dynamic> booking) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi"),
          content: const Text("Booking sudah selesai?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Belum"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Selesai"),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await finishBooking(booking);
    }
  }

  //-------------------------------------------------------
  // Status Color
  //-------------------------------------------------------

  Color statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.orange;

      case "approved":
        return Colors.green;

      case "rejected":
        return Colors.red;

      case "finished":
        return Colors.blue;

      default:
        return Colors.grey;
    }
  }

  //-------------------------------------------------------
  // Status Text
  //-------------------------------------------------------

  String statusText(String status) {
    switch (status) {
      case "pending":
        return "Menunggu";

      case "approved":
        return "Disetujui";

      case "rejected":
        return "Ditolak";

      case "finished":
        return "Selesai";

      default:
        return status;
    }
  }

  //-------------------------------------------------------
  // Format Date
  //-------------------------------------------------------

  String formatDate(dynamic value) {
    if (value == null) return "-";

    return formatter.format(DateTime.parse(value.toString()));
  }

  //-------------------------------------------------------
  // Customer Name
  //-------------------------------------------------------

  String customerName(Map<String, dynamic> booking) {
    return booking["profiles"]?["full_name"] ?? "Customer";
  }

  //-------------------------------------------------------
  // Field Name
  //-------------------------------------------------------

  String fieldName(Map<String, dynamic> booking) {
    return booking["fields"]?["field_name"] ?? "-";
  }

  //-------------------------------------------------------
  // Payment
  //-------------------------------------------------------

  Map<String, dynamic>? paymentData(Map<String, dynamic> booking) {
    if (booking["payments"] == null) {
      return null;
    }

    if (booking["payments"] is List) {
      final list = booking["payments"] as List;

      if (list.isEmpty) return null;

      return list.first;
    }

    return booking["payments"];
  }

  //-------------------------------------------------------
  // Booking Card
  //-------------------------------------------------------

  Widget buildBookingCard(Map<String, dynamic> booking) {
    final payment = paymentData(booking);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //----------------------------------
            // Header
            //----------------------------------
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.green.shade100,
                  child: const Icon(Icons.person, color: Colors.green),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName(booking),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        fieldName(booking),
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor(booking["status"]),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    statusText(booking["status"]),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 28),

            //----------------------------------
            // Detail
            //----------------------------------
            detailRow(
              Icons.calendar_today,
              "Tanggal",
              formatDate(booking["booking_date"]),
            ),

            detailRow(
              Icons.schedule,
              "Jam",
              "${booking["start_time"]} - ${booking["end_time"]}",
            ),

            detailRow(Icons.timer, "Durasi", "${booking["duration"]} Jam"),

            detailRow(
              Icons.attach_money,
              "Total",
              "Rp ${booking["total_price"]}",
            ),

            if (booking["note"] != null &&
                booking["note"].toString().isNotEmpty)
              detailRow(Icons.notes, "Catatan", booking["note"]),

            if (payment != null)
              detailRow(
                Icons.payment,
                "Metode",
                payment["payment_method"] ?? "-",
              ),

            if (payment != null)
              detailRow(
                Icons.credit_card,
                "Status Bayar",
                payment["payment_status"] ?? "-",
              ),

            const SizedBox(height: 15),

            //----------------------------------
            // Bukti Transfer
            //----------------------------------
            if (payment != null && payment["payment_proof"] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  payment["payment_proof"],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 15),

            //----------------------------------
            // Tombol Pending
            //----------------------------------
            if (booking["status"] == "pending")
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      onPressed: () => showApproveDialog(booking),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text(
                        "Approve",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      onPressed: () => showRejectDialog(booking),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text(
                        "Reject",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),

            //----------------------------------
            // Tombol Approved
            //----------------------------------
            if (booking["status"] == "approved")
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      onPressed: () => showFinishDialog(booking),
                      icon: const Icon(Icons.flag, color: Colors.white),
                      label: const Text(
                        "Selesaikan Booking",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.chat),
                      label: const Text("Buka Chat"),
                      onPressed: () async {
                        final room = await supabase
                            .from("chat_rooms")
                            .select()
                            .eq("booking_id", booking["id"])
                            .maybeSingle();

                        if (!mounted) return;

                        if (room == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Chat room belum tersedia"),
                            ),
                          );

                          return;
                        }

                        // Navigasi ke chat
                        // Akan kita lengkapi di Part 3B
                      },
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  //-------------------------------------------------------
  // Detail Row
  //-------------------------------------------------------

  Widget detailRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.green),

          const SizedBox(width: 10),

          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  //-------------------------------------------------------
  // Empty Widget
  //-------------------------------------------------------

  Widget buildEmpty(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 70, color: Colors.grey.shade400),

          const SizedBox(height: 15),

          Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  //-------------------------------------------------------
  // Booking List
  //-------------------------------------------------------

  Widget buildBookingList(List<Map<String, dynamic>> bookings) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (bookings.isEmpty) {
      return buildEmpty("Belum ada booking");
    }

    return RefreshIndicator(
      onRefresh: refreshData,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 30),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          return buildBookingCard(bookings[index]);
        },
      ),
    );
  }

  //-------------------------------------------------------
  // Tab
  //-------------------------------------------------------

  Widget buildTab(String title, int total) {
    return Tab(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 4),

          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.white,
            child: Text(
              total.toString(),
              style: const TextStyle(
                fontSize: 11,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //-------------------------------------------------------
  // Open Chat
  //-------------------------------------------------------

  Future<void> openChat(Map<String, dynamic> booking) async {
    try {
      final room = await supabase
          .from("chat_rooms")
          .select()
          .eq("booking_id", booking["id"])
          .maybeSingle();

      if (room == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Chat room belum tersedia")),
        );

        return;
      }

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OwnerChatRoomScreen(
            roomId: room["id"],
            customerName: customerName(booking),
            customerPhoto: booking["profiles"]?["avatar_url"],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  //-------------------------------------------------------
  // BUILD
  //-------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,

        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          title: const Text("Jadwal Booking"),
          bottom: TabBar(
            isScrollable: true,
            indicatorColor: Colors.white,
            tabs: [
              buildTab("Semua", allBookings.length),

              buildTab("Pending", pendingBookings.length),

              buildTab("Approved", approvedBookings.length),

              buildTab("Rejected", rejectedBookings.length),

              buildTab("Finished", finishedBookings.length),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            buildBookingList(allBookings),

            buildBookingList(pendingBookings),

            buildBookingList(approvedBookings),

            buildBookingList(rejectedBookings),

            buildBookingList(finishedBookings),
          ],
        ),
      ),
    );
  }
}
