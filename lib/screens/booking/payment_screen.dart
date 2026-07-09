import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../customer/customer_dashboard_screen.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> field;

  final DateTime bookingDate;

  final String startTime;

  final String endTime;

  final int duration;

  final String note;

  final int totalPrice;

  const PaymentScreen({
    super.key,

    required this.field,

    required this.bookingDate,

    required this.startTime,

    required this.endTime,

    required this.duration,

    required this.note,

    required this.totalPrice,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  //------------------------------------------------
  // Supabase
  //------------------------------------------------

  final supabase = Supabase.instance.client;

  //------------------------------------------------
  // Loading
  //------------------------------------------------

  bool isLoading = false;

  //------------------------------------------------
  // Payment
  //------------------------------------------------

  String paymentMethod = "Transfer Bank";

  //------------------------------------------------
  // Bukti
  //------------------------------------------------

  Uint8List? proofBytes;

  String? proofName;

  //------------------------------------------------
  // Formatter
  //------------------------------------------------

  final rupiahFormatter = NumberFormat.currency(
    locale: "id",

    symbol: "Rp ",

    decimalDigits: 0,
  );

  //------------------------------------------------
  // Init
  //------------------------------------------------

  @override
  void initState() {
    super.initState();
  }

  //------------------------------------------------
  // Getter
  //------------------------------------------------

  String get fieldName {
    return widget.field["field_name"] ?? "";
  }

  String get location {
    return widget.field["location"] ?? "";
  }

  String get image {
    return widget.field["image_url"] ?? "";
  }

  int get total {
    return widget.totalPrice;
  }

  String rupiah(int value) {
    return rupiahFormatter.format(value);
  }

  String get bookingDateText {
    return DateFormat("EEEE, dd MMMM yyyy", "id").format(widget.bookingDate);
  }

  //------------------------------------------------
  // Build
  //------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(title: const Text("Pembayaran")),

      body: SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(),

            buildBookingSummary(),

            buildPaymentMethod(),

            buildPaymentInformation(),

            buildUploadCard(),

            const SizedBox(height: 120),
          ],
        ),
      ),

      bottomNavigationBar: buildBottomBar(),
    );
  }

  //------------------------------------------------
  // Header
  //------------------------------------------------

  Widget buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),

            child: image.isEmpty
                ? Image.asset(
                    "assets/images/futsal.jpg",

                    height: 220,

                    width: double.infinity,

                    fit: BoxFit.cover,
                  )
                : Image.network(
                    image,

                    height: 220,

                    width: double.infinity,

                    fit: BoxFit.cover,
                  ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  fieldName,

                  style: const TextStyle(
                    fontSize: 22,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),

                    const SizedBox(width: 8),

                    Expanded(child: Text(location)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //------------------------------------------------
  // Booking Summary
  //------------------------------------------------

  Widget buildBookingSummary() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          children: [
            buildRow("Tanggal", bookingDateText),

            buildRow("Jam", "${widget.startTime} - ${widget.endTime}"),

            buildRow("Durasi", "${widget.duration} Jam"),

            buildRow("Catatan", widget.note.isEmpty ? "-" : widget.note),

            const Divider(),

            buildRow("Total", rupiah(total), bold: true),
          ],
        ),
      ),
    );
  }

  //------------------------------------------------
  // Row Helper
  //------------------------------------------------

  Widget buildRow(String title, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(
        children: [
          Expanded(child: Text(title)),

          Expanded(
            child: Text(
              value,

              textAlign: TextAlign.right,

              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,

                color: bold ? Colors.blue : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //--------------------------------------------------
  // PILIH METODE PEMBAYARAN
  //--------------------------------------------------

  Widget buildPaymentMethod() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Metode Pembayaran",

              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            buildRadioTile("Transfer Bank", Icons.account_balance),

            buildRadioTile("QRIS", Icons.qr_code),

            buildRadioTile("E-Wallet", Icons.account_balance_wallet),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////
  /// RADIO TILE
  ////////////////////////////////////////////////////

  Widget buildRadioTile(String value, IconData icon) {
    return RadioListTile<String>(
      value: value,

      groupValue: paymentMethod,

      onChanged: (v) {
        setState(() {
          paymentMethod = v!;
        });
      },

      secondary: Icon(icon),

      title: Text(value),
    );
  }

  ////////////////////////////////////////////////////
  /// INFORMASI PEMBAYARAN
  ////////////////////////////////////////////////////

  Widget buildPaymentInformation() {
    String title = "";
    String number = "";

    switch (paymentMethod) {
      case "Transfer Bank":
        title = "Bank BCA";
        number = "1234567890";
        break;

      case "QRIS":
        title = "QRIS";
        number = "Scan QR di bawah";
        break;

      case "E-Wallet":
        title = "Dana";
        number = "081234567890";
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Tujuan Pembayaran",

              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 15),

            Text(
              title,

              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),

            const SizedBox(height: 8),

            SelectableText(number, style: const TextStyle(fontSize: 16)),

            if (paymentMethod == "QRIS")
              Padding(
                padding: const EdgeInsets.only(top: 20),

                child: Center(
                  child: Image.asset("assets/images/qris.png", height: 220),
                ),
              ),
          ],
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////
  /// PILIH BUKTI
  ////////////////////////////////////////////////////

  Future<void> pickproofBytes() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,

      withData: true,
    );

    if (result == null) return;

    setState(() {
      proofBytes = result.files.first.bytes;

      proofName = result.files.first.name;
    });
  }

  ////////////////////////////////////////////////////
  /// CARD UPLOAD
  ////////////////////////////////////////////////////

  Widget buildUploadCard() {
    return Card(
      margin: const EdgeInsets.all(16),

      child: Padding(
        padding: const EdgeInsets.all(18),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Upload Bukti Pembayaran",

              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(
              onPressed: pickproofBytes,

              icon: const Icon(Icons.upload),

              label: const Text("Pilih Gambar"),
            ),

            const SizedBox(height: 20),

            if (proofBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(15),

                child: Image.memory(
                  proofBytes!,

                  height: 220,

                  width: double.infinity,

                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 220,

                width: double.infinity,

                decoration: BoxDecoration(
                  color: Colors.grey.shade200,

                  borderRadius: BorderRadius.circular(15),
                ),

                child: const Center(child: Text("Belum ada bukti pembayaran")),
              ),
          ],
        ),
      ),
    );
  }

  //--------------------------------------------------
  // Upload Bukti Pembayaran
  //--------------------------------------------------

  Future<String?> uploadProof() async {
    if (proofBytes == null) return null;

    try {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_$proofName";

      await supabase.storage
          .from("payment-proofs")
          .uploadBinary(fileName, proofBytes!);

      final publicUrl = supabase.storage
          .from("payment-proofs")
          .getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      debugPrint("UPLOAD ERROR : $e");

      return null;
    }
  }

  //--------------------------------------------------
  // Submit Payment
  //--------------------------------------------------

  Future<void> submitPayment() async {
    if (!validatePayment()) return;

    setState(() {
      isLoading = true;
    });

    try {
      //---------------------------------------
      // Upload Bukti
      //---------------------------------------

      final proofUrl = await uploadProof();

      //---------------------------------------
      // Customer
      //---------------------------------------

      final customerId = supabase.auth.currentUser!.id;

      //---------------------------------------
      // Owner Lapangan
      //---------------------------------------

      final ownerId = widget.field["owner_id"];

      //---------------------------------------
      // Insert Booking
      //---------------------------------------

      final booking = await supabase
          .from("bookings")
          .insert({
            "customer_id": customerId,

            "field_id": widget.field["id"],

            "booking_date": widget.bookingDate
                .toIso8601String()
                .split("T")
                .first,

            "start_time": widget.startTime,

            "end_time": widget.endTime,

            "duration": widget.duration,

            "note": widget.note,

            "total_price": widget.totalPrice,

            "status": "pending",
          })
          .select()
          .single();

      //---------------------------------------
      // Insert Payment
      //---------------------------------------

      await supabase.from("payments").insert({
        "booking_id": booking["id"],

        "amount": widget.totalPrice,

        "payment_method": paymentMethod,

        "payment_status": "waiting",

        "payment_date": DateTime.now().toIso8601String(),

        "payment_proof": proofUrl,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Booking berhasil dikirim")));

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CustomerDashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        this.context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  ////////////////////////////////////////////////////
  /// VALIDASI
  ////////////////////////////////////////////////////

  bool validatePayment() {
    if (proofBytes == null) {
      ScaffoldMessenger.of(this.context).showSnackBar(
        const SnackBar(content: Text("Silakan upload bukti pembayaran")),
      );

      return false;
    }

    return true;
  }

  //--------------------------------------------------
  // Bottom Button
  //--------------------------------------------------

  Widget buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: const BoxDecoration(
          color: Colors.white,

          boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black12)],
        ),

        child: ElevatedButton(
          onPressed: isLoading ? null : submitPayment,

          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 60),

            backgroundColor: Colors.blue,
          ),

          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  "Bayar ${rupiah(widget.totalPrice)}",

                  style: const TextStyle(
                    fontSize: 18,

                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}
