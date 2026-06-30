
import 'package:flutter/material.dart';
import 'package:job_portal/providers/auth_provider/my_auth_provider.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final TextEditingController emailController =
  TextEditingController();

  final GlobalKey<FormState> formKey =
  GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: Column(
              children: [
                const SizedBox(height: 50),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4F7FA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_reset,
                    size: 70,
                    color: Color(0xFF4A90E2),
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  "Forgot Password?",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF081A2F),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "Enter your registered email address and we'll send you a password reset link.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 50),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email Address",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0E2A47),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: emailController,
                  keyboardType:
                  TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText:
                    "Enter your university email",

                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Color(0xFF4A90E2),
                    ),

                    filled: true,
                    fillColor:
                    const Color(0xFFF8F9FB),

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),

                    focusedBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: Color(0xFF4A90E2),
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return "Please enter email";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 35),

                Consumer<MyAuthProvider>(
                  builder:
                      (context, provider, child) {
                    return provider.loading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey
                              .currentState!
                              .validate()) {
                            await provider
                                .forgotPassword(
                              emailController.text,
                            );
                          }
                        },
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          const Color(
                              0xFF081A2F),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                                16),
                          ),
                        ),
                        child: const Text(
                          "Send Reset Link",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Back to Login",
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