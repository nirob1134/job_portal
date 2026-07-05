import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../models/transport_application_model.dart';
import '../../../providers/auth_provider/transport_application_provider.dart';

class ApplyTransportScreen extends StatefulWidget {
  final String jobId;
  final String jobTitle;
  final String route;

  const ApplyTransportScreen({
    super.key,
    required this.jobId,
    required this.jobTitle,
    required this.route,
  });

  @override
  State<ApplyTransportScreen> createState() => _ApplyTransportScreenState();
}

class _ApplyTransportScreenState extends State<ApplyTransportScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController studentIdCtrl = TextEditingController();
  final TextEditingController semesterCtrl = TextEditingController();
  final TextEditingController cgpaCtrl = TextEditingController();
  final TextEditingController resumeLinkCtrl = TextEditingController();

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      nameCtrl.text = user.displayName ?? '';
      emailCtrl.text = user.email ?? '';
    }
  }

  @override
  void dispose() {
    for (var controller in [nameCtrl, emailCtrl, phoneCtrl, studentIdCtrl, semesterCtrl, cgpaCtrl, resumeLinkCtrl]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransportApplicationProvider>(context, listen: false);
    final User user = FirebaseAuth.instance.currentUser!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF081A2F),
        title: const Text('Transport Application', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Summary
              Text(widget.jobTitle,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E2A47))),
              Text("Route: ${widget.route}",
                  style: const TextStyle(fontSize: 14, color: Color(0xFF4A90E2), fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),

              _input(nameCtrl, 'Full Name', Icons.person_outline),
              _input(emailCtrl, 'Email', Icons.email_outlined, enabled: false),
              _input(phoneCtrl, 'Phone Number', Icons.phone_android_outlined, type: TextInputType.phone),
              _input(studentIdCtrl, 'Student ID', Icons.badge_outlined),
              _input(semesterCtrl, 'Running Semester', Icons.layers_outlined),
              _input(cgpaCtrl, 'Current CGPA', Icons.auto_awesome_outlined, type: TextInputType.number),
              _input(resumeLinkCtrl, 'Resume Link (Drive/LinkedIn)', Icons.link_rounded),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0E2A47),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  onPressed: isLoading ? null : () async => _handleSubmission(provider, user),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Application',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmission(TransportApplicationProvider provider, User user) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);

    final application = TransportApplicationModel(
      id: '',
      transportJobId: widget.jobId,
      transportJobTitle: widget.jobTitle,
      userId: user.uid,
      userName: nameCtrl.text.trim(),
      userEmail: emailCtrl.text.trim(),
      userPhone: phoneCtrl.text.trim(),
      studentId: studentIdCtrl.text.trim(),
      runningSemester: semesterCtrl.text.trim(),
      cgpa: cgpaCtrl.text.trim(),
      route: widget.route,
      coverLetter: resumeLinkCtrl.text.trim(),
      status: 'pending',
    );

    try {
      await provider.applyTransportJob(application);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Applied successfully'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget _input(TextEditingController controller, String label, IconData icon,
      {bool enabled = true, TextInputType type = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0E2A47))),
          ),
          TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: type,
            validator: (value) => value == null || value.isEmpty ? 'This field is required' : null,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: const Color(0xFF4A90E2), size: 20),
              filled: true,
              fillColor: enabled ? const Color(0xFFF8F9FB) : Colors.grey.shade100,
              hintText: label,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
          ),
        ],
      ),
    );
  }
}