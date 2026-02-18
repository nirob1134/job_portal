import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:job_portal/utils/route_helper.dart';

const Color primaryTeal = Color(0xFF3CC6C6);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    navigateNext();
  }

  void navigateNext() async {

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;


    FirebaseAuth.instance.authStateChanges().first.then((user) {
      if (!mounted) return;

      if (user != null) {

        Navigator.pushReplacementNamed(context, RouteHelper.home);
      } else {

        Navigator.pushReplacementNamed(context, RouteHelper.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 120),
          Center(
            child: Image.asset(
              'assets/images/job_logo.gif',
              height: 300,
            ),
          ),
          const SizedBox(height: 120),
          const Center(
            child: CircularProgressIndicator(color: primaryTeal),
          ),
          const SizedBox(height: 8),
          Text(
            'A On Campus Job Portal Application',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
