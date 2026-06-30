import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() =>
      _OwnerHomeScreenState();
}

class _OwnerHomeScreenState
    extends State<OwnerHomeScreen> {

  final supabase =
      Supabase.instance.client;

  bool isLoading = true;

  String ownerName = "Owner";

  int totalFields = 0;
  int totalBookings = 0;
  int totalIncome = 0;

  List<dynamic> recentBookings = [];
  List<dynamic> ownerFields = [];

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {

    try {

      final user =
          supabase.auth.currentUser;

      if (user == null) return;

      //--------------------------------
      // PROFILE
      //--------------------------------

      final profile =
          await supabase
              .from('profiles')
              .select()
              .eq('id', user.id)
              .single();

      ownerName =
          profile['full_name'] ??
              "Owner";

      //--------------------------------
      // FIELDS OWNER
      //--------------------------------

      final fields =
          await supabase
              .from('fields')
              .select()
              .eq('owner_id', user.id);

      ownerFields = fields;

      totalFields =
          ownerFields.length;

      //--------------------------------
      // BOOKING OWNER
      //--------------------------------

      if (ownerFields.isNotEmpty) {

        final fieldIds =
            ownerFields
                .map((e) => e['id'])
                .toList();

        final bookings =
            await supabase
                .from('bookings')
                .select()
                .inFilter(
                  'field_id',
                  fieldIds,
                );

        totalBookings =
            bookings.length;

        recentBookings =
            bookings.take(5).toList();

        //--------------------------------
        // TOTAL PEMASUKAN
        //--------------------------------

        int income = 0;

        for (var booking
            in bookings) {

          income +=
              (booking[
                      'total_price'] ??
                  0) as int;
        }

        totalIncome = income;
      }

      setState(() {
        isLoading = false;
      });

    } catch (e) {

      debugPrint(
        "Dashboard Error: $e",
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {

    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
              BorderRadius.circular(
                  18),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            )
          ],
        ),

        child: Column(
          children: [

            Icon(
              icon,
              color:
                  const Color(
                      0xff001DFF),
              size: 30,
            ),

            const SizedBox(
                height: 10),

            Text(
              value,
              style:
                  const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 5),

            Text(
              title,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey.shade100,

      body: SafeArea(

        child: isLoading

            ? const Center(
                child:
                    CircularProgressIndicator(),
              )

            : RefreshIndicator(

                onRefresh:
                    loadDashboard,

                child:
                    SingleChildScrollView(

                  physics:
                      const AlwaysScrollableScrollPhysics(),

                  child: Column(

                    children: [

                      //----------------------------------
                      // HEADER
                      //----------------------------------

                      Container(

                        width:
                            double.infinity,

                        padding:
                            const EdgeInsets
                                .all(20),

                        decoration:
                            const BoxDecoration(

                          color:
                              Color(
                                  0xff001DFF),

                          borderRadius:
                              BorderRadius.only(
                            bottomLeft:
                                Radius.circular(
                                    30),
                            bottomRight:
                                Radius.circular(
                                    30),
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Row(
                              children: [

                                const CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                      Colors
                                          .white,

                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Color(
                                        0xff001DFF),
                                  ),
                                ),

                                const SizedBox(
                                    width:
                                        12),

                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      const Text(
                                        "Selamat Datang",
                                        style:
                                            TextStyle(
                                          color:
                                              Colors.white70,
                                        ),
                                      ),

                                      Text(
                                        ownerName,
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontSize:
                                              20,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),

                            const SizedBox(
                                height:
                                    25),

                            const Text(
                              "Kelola Lapangan\nLebih Mudah",
                              style:
                                  TextStyle(
                                color:
                                    Colors.white,
                                fontSize:
                                    28,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                          height: 20),

                      //----------------------------------
                      // STATS
                      //----------------------------------

                      Padding(
                        padding:
                            const EdgeInsets
                                .all(16),

                        child: Row(
                          children: [

                            buildStatCard(
                              title:
                                  "Lapangan",
                              value:
                                  totalFields
                                      .toString(),
                              icon: Icons
                                  .sports_soccer,
                            ),

                            const SizedBox(
                                width:
                                    10),

                            buildStatCard(
                              title:
                                  "Booking",
                              value:
                                  totalBookings
                                      .toString(),
                              icon: Icons
                                  .calendar_month,
                            ),

                            const SizedBox(
                                width:
                                    10),

                            buildStatCard(
                              title:
                                  "Pemasukan",
                              value:
                                  NumberFormat.compactCurrency(
                                locale:
                                    "id",
                                symbol:
                                    "Rp",
                              ).format(
                                  totalIncome),
                              icon:
                                  Icons.payments,
                            ),
                          ],
                        ),
                      ),

                      //----------------------------------
                      // LAPANGAN
                      //----------------------------------

                      Padding(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              16,
                        ),

                        child: Row(
                          children: [

                            const Text(
                              "Lapangan Saya",
                              style:
                                  TextStyle(
                                fontSize:
                                    18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const Spacer(),

                            Text(
                              "${ownerFields.length} Lapangan",
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(
                          height: 10),

                      SizedBox(
                        height: 160,

                        child:
                            ListView.builder(

                          scrollDirection:
                              Axis.horizontal,

                          padding:
                              const EdgeInsets
                                  .all(16),

                          itemCount:
                              ownerFields
                                  .length,

                          itemBuilder:
                              (
                            context,
                            index,
                          ) {

                            final field =
                                ownerFields[
                                    index];

                            return Container(

                              width: 250,

                              margin:
                                  const EdgeInsets
                                      .only(
                                right:
                                    15,
                              ),

                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,

                                borderRadius:
                                    BorderRadius.circular(
                                        20),
                              ),

                              child:
                                  Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Expanded(
                                    child:
                                        ClipRRect(

                                      borderRadius:
                                          const BorderRadius.vertical(
                                        top:
                                            Radius.circular(
                                                20),
                                      ),

                                      child:
                                          Image.network(

                                        field['image_url'] ??
                                            "",

                                        width:
                                            double.infinity,

                                        fit:
                                            BoxFit.cover,

                                        errorBuilder:
                                            (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color: Colors
                                                .grey
                                                .shade300,
                                          );
                                        },
                                      ),
                                    ),
                                  ),

                                  Padding(
                                    padding:
                                        const EdgeInsets.all(
                                            12),

                                    child:
                                        Text(
                                      field['field_name'] ??
                                          "",
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      //----------------------------------
                      // BOOKING TERBARU
                      //----------------------------------

                      Padding(
                        padding:
                            const EdgeInsets
                                .all(16),

                        child:
                            Container(

                          padding:
                              const EdgeInsets
                                  .all(16),

                          decoration:
                              BoxDecoration(
                            color:
                                Colors.white,

                            borderRadius:
                                BorderRadius.circular(
                                    20),
                          ),

                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [

                              const Text(
                                "Booking Terbaru",
                                style:
                                    TextStyle(
                                  fontSize:
                                      18,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),

                              const SizedBox(
                                  height:
                                      15),

                              recentBookings
                                      .isEmpty
                                  ? const Text(
                                      "Belum ada booking",
                                    )
                                  : Column(
                                      children:
                                          recentBookings
                                              .map(
                                                (
                                                  booking,
                                                ) =>
                                                    ListTile(
                                                  leading:
                                                      const CircleAvatar(
                                                    child:
                                                        Icon(
                                                      Icons.calendar_month,
                                                    ),
                                                  ),
                                                  title:
                                                      Text(
                                                    "Rp ${booking['total_price']}",
                                                  ),
                                                  subtitle:
                                                      Text(
                                                    booking['status'] ??
                                                        "-",
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}