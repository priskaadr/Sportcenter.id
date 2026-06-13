import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_screen.dart';
import '../customer/customer_home_screen.dart';

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

      backgroundColor: const Color(0xff001DFF),

      body: SafeArea(
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
                      
                      if(!mounted) return;
                      
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CustomerHomeScreen(),
                        ),
                      );
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
                      builder: (_)
                      => const RegisterScreen(),
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
    );
  }
}