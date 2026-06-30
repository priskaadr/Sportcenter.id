import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerDashboardService {

  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getDashboardData() async {

    final ownerId =
        supabase.auth.currentUser!.id;

    // Total Lapangan
    final fields = await supabase
        .from('fields')
        .select()
        .eq('owner_id', ownerId);

    int totalFields =
        fields.length;

    // Rating rata-rata
    double avgRating = 0;

    if (fields.isNotEmpty) {

      double totalRating = 0;

      for (var field in fields) {

        totalRating +=
            (field['rating'] ?? 0)
                .toDouble();
      }

      avgRating =
          totalRating /
              fields.length;
    }

    // Ambil semua field id milik owner
    List<String> fieldIds =
        fields
            .map<String>(
              (e) =>
                  e['id'].toString(),
            )
            .toList();

    // Total booking
    final bookings =
        await supabase
            .from('bookings')
            .select()
            .inFilter(
              'field_id',
              fieldIds,
            );

    int totalBookings =
        bookings.length;

    // Total pemasukan
    final payments =
        await supabase
            .from('payments')
            .select();

    int totalIncome = 0;

    for (var payment
        in payments) {

      totalIncome +=
          (payment['amount']
                  ?? 0)
              as int;
    }

    return {
      'totalFields':
          totalFields,

      'totalBookings':
          totalBookings,

      'totalIncome':
          totalIncome,

      'avgRating':
          avgRating,
    };
  }
}