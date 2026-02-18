import 'package:flutter/material.dart';
import 'package:job_portal/providers/auth_provider/my_auth_provider.dart';
import 'package:provider/provider.dart';
import '../../utils/route_helper.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF081A2F), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📝 Header Section
                const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Color(0xFF081A2F),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Join the DIU portal to find your next opportunity.",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 35),

                // 👤 Full Name
                _buildLabel("Full Name"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: name,
                  decoration: _inputDecoration(hint: "John Doe", icon: Icons.person_outline),
                  validator: (val) => val!.isEmpty ? "Please enter name" : null,
                ),

                const SizedBox(height: 20),

                // 📧 Email
                _buildLabel("Email Address"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(hint: "example@diu.edu.bd", icon: Icons.email_outlined),
                  validator: (val) => val!.isEmpty ? "Please enter email" : null,
                ),

                const SizedBox(height: 20),

                // 📞 Phone
                _buildLabel("Phone Number"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: phone,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration(hint: "+880 1XXX-XXXXXX", icon: Icons.phone_android_outlined),
                  validator: (val) => val!.isEmpty ? "Please enter phone" : null,
                ),

                const SizedBox(height: 20),

                // 🔒 Password
                _buildLabel("Password"),
                const SizedBox(height: 8),
                TextFormField(
                  controller: password,
                  obscureText: true,
                  decoration: _inputDecoration(hint: "••••••••", icon: Icons.lock_outline_rounded),
                  validator: (val) => val!.isEmpty ? "Please enter password" : null,
                ),

                const SizedBox(height: 35),

                // 🚀 Register Button
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
                            provider.registration(
                                name.text,
                                email.text,
                                password.text,
                                phone.text
                            );
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
                          "Register",
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

                const SizedBox(height: 25),

                // 🔗 Back to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, RouteHelper.login),
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Helpers for Consistency ---

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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
      ),
    );
  }
}