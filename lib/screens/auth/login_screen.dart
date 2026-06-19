import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import '../customer/customer_home_screen.dart';
import '../owner/owner_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final emailController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  bool obscure = true;

  @override
  Widget build(BuildContext context) {

        return Scaffold(
      // Menghapus backgroundColor lama dan menggantinya dengan Stack di body
          body: Stack(
            children: [
              // 1. Lapisan Latar Belakang Gambar
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/screen.png'), 
                    fit: BoxFit.cover, 
                  ),
                ),
              ),
        
              // 2. Lapisan Konten Form Login
              SafeArea(
                child: SingleChildScrollView( // Ditambahkan agar layar bisa di-scroll saat keyboard muncul
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      children: [
                        const SizedBox(height: 50),
        
                        const Text(
                          "Hello!!!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
        
                        const Text(
                          "Welcome To Sport Center",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
        
                        const SizedBox(height: 50),
        
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            hintText: "Email Address",
                            filled: true,
                          ),
                        ),
        
                        const SizedBox(height: 15),
        
                        TextField(
                          controller: passwordController,
                          obscureText: obscure,
                          decoration: InputDecoration(
                            hintText: "Password",
                            filled: true,
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: (){
                                setState(() {
                                  obscure = !obscure;
                                });
                              },
                            ),
                          ),
                        ),
        
                        const SizedBox(height: 30),
        
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.limeAccent,
                            ),
                            onPressed: () async {
                              await AuthService().signIn(
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                            );

                      final role =
                          await AuthService()
                              .getCurrentUserRole();

                      if (!mounted) return;

                      if (role == "customer") {
                      
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const CustomerHomeScreen(),
                          ),
                        );

                      } else if (role == "owner") {
                      
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const OwnerDashboardScreen(),
                          ),
                        );

                      } else if (role == "admin") {
                      
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const AdminDashboardScreen(),
                          ),
                        );

}
                            },
                            child: const Text(
                              "Sign In",
                            ),
                          ),
                        ),
        
                        const SizedBox(height: 20),
        
                        TextButton(
                          onPressed: (){
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
    );    
  }
}