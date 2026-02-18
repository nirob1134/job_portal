import 'package:flutter/material.dart';
import 'package:job_portal/providers/auth_provider/my_auth_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/route_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                // 🎓 DIU Branding Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F7FA),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/diu_logo.jpg', // Using consistent logo
                          height: 80,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Welcome Back!",
                        style: TextStyle(
                          color: Color(0xFF081A2F),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Sign in to access your DIU Job Portal",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // 📧 Email Field
                _buildLabel("Email Address"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    hint: "Enter your university email",
                    icon: Icons.email_outlined,
                  ),
                  validator: (val) => val!.isEmpty ? "Please enter email" : null,
                ),

                const SizedBox(height: 24),

                // 🔒 Password Field
                _buildLabel("Password"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: _inputDecoration(
                    hint: "Enter your password",
                    icon: Icons.lock_outline_rounded,
                  ),
                  validator: (val) => val!.isEmpty ? "Please enter password" : null,
                ),

                // 🔑 Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Color(0xFF4A90E2), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 🚀 Login Button
                Consumer<MyAuthProvider>(
                  builder: (context, provider, child) {
                    return provider.loading
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFF081A2F)))
                        : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            provider.login(email.text, password.text);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF081A2F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // 📝 Sign Up Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, RouteHelper.registration),
                      child: const Text(
                        "Create Account",
                        style: TextStyle(
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper for Input Labels
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF0E2A47),
      ),
    );
  }

  // Helper for consistent Input Decoration
  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF4A90E2), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8F9FB),
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1),
      ),
    );
  }
}