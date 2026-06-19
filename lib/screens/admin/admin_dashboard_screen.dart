import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState
    extends State<AdminDashboardScreen> {

  final supabase = Supabase.instance.client;

  int totalOwners = 0;
  int totalCustomers = 0;
  int totalFields = 0;
  int totalBookings = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    try {

      final owners = await supabase
          .from('profiles')
          .select()
          .eq('role', 'owner');

      final customers = await supabase
          .from('profiles')
          .select()
          .eq('role', 'customer');

      final fields = await supabase
          .from('fields')
          .select();

      final bookings = await supabase
          .from('bookings')
          .select();

      setState(() {
        totalOwners = owners.length;
        totalCustomers = customers.length;
        totalFields = fields.length;
        totalBookings = bookings.length;
        isLoading = false;
      });

    } catch (e) {
      print(e);

      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          )
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [

          Icon(
            icon,
            size: 40,
            color: Colors.blue,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildMenuButton(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing:
            const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.grey.shade100,

      appBar: AppBar(
        backgroundColor:
            const Color(0xff001DFF),
        title: const Text(
          "Dashboard Admin",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(

              padding:
                  const EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  const Text(
                    "Statistik Sistem",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [

                      buildCard(
                        "Pemilik",
                        totalOwners.toString(),
                        Icons.business,
                      ),

                      buildCard(
                        "Penyewa",
                        totalCustomers.toString(),
                        Icons.people,
                      ),

                      buildCard(
                        "Lapangan",
                        totalFields.toString(),
                        Icons.sports_soccer,
                      ),

                      buildCard(
                        "Booking",
                        totalBookings.toString(),
                        Icons.book_online,
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Menu Admin",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  buildMenuButton(
                    "Kelola Pemilik Lapangan",
                    Icons.business_center,
                    () {},
                  ),

                  buildMenuButton(
                    "Kelola Penyewa",
                    Icons.people,
                    () {},
                  ),

                  buildMenuButton(
                    "Kelola Lapangan",
                    Icons.sports_soccer,
                    () {},
                  ),

                  buildMenuButton(
                    "Laporan Keuangan",
                    Icons.bar_chart,
                    () {},
                  ),

                  buildMenuButton(
                    "Logout",
                    Icons.logout,
                    () async {

                      await supabase.auth
                          .signOut();

                      if (!mounted) return;

                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/',
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}