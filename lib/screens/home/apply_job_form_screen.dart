import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/job_model.dart';

class ApplyJobFormScreen extends StatefulWidget {
  final JobModel job;

  const ApplyJobFormScreen({super.key, required this.job});

  @override
  State<ApplyJobFormScreen> createState() => _ApplyJobFormScreenState();
}

class _ApplyJobFormScreenState extends State<ApplyJobFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers match your transport screen structure
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController studentIdCtrl = TextEditingController();
  final TextEditingController semesterCtrl = TextEditingController();
  final TextEditingController cgpaCtrl = TextEditingController();
  final TextEditingController resumeLinkCtrl = TextEditingController();

  bool loading = false;

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

  Future<void> submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // 1. Check if user already applied for this specific jobId
      final check = await FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: widget.job.id)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (check.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have already applied for this position'), backgroundColor: Colors.orange),
          );
        }
        setState(() => loading = false);
        return;
      }

      // 2. Submit to 'applications' collection using form controller text
      await FirebaseFirestore.instance.collection('applications').add({
        'jobId': widget.job.id,
        'jobTitle': widget.job.title,
        'adminId': widget.job.adminId,
        'userId': user.uid,
        'userName': nameCtrl.text.trim(),
        'userEmail': emailCtrl.text.trim(),
        'userPhone': phoneCtrl.text.trim(),
        'studentId': studentIdCtrl.text.trim(),
        'semester': semesterCtrl.text.trim(),
        'cgpa': cgpaCtrl.text.trim(),
        'resumeLink': resumeLinkCtrl.text.trim(),
        'status': 'pending',
        'appliedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
        content: const Text(
          "Application Submitted!\nThe professor will review your details soon.",
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to previous screen
            },
            child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF081A2F),
        title: const Text('Job Application', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Summary matching transport style
              Text(widget.job.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E2A47))),
              Text("Department: ${widget.job.department}",
                  style: const TextStyle(fontSize: 14, color: Color(0xFF4A90E2), fontWeight: FontWeight.w600)),
              const SizedBox(height: 30),

              // Inputs rendered via the identical _input builder
              _input(nameCtrl, 'Full Name', Icons.person_outline),
              _input(emailCtrl, 'Email', Icons.email_outlined, enabled: false),
              _input(phoneCtrl, 'Phone Number', Icons.phone_android_outlined, type: TextInputType.phone),
              _input(studentIdCtrl, 'Official Student ID', Icons.badge_outlined),
              _input(semesterCtrl, 'Current Running Semester', Icons.layers_outlined),
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
                  onPressed: loading ? null : submitApplication,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Confirm & Submit',
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