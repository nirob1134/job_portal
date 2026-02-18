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

  // Controllers
  final _idController = TextEditingController();
  final _semesterController = TextEditingController();
  final _cgpaController = TextEditingController();
  final _resumeController = TextEditingController();

  bool loading = false;

  Future<void> submitApplication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      // Fetch user's basic name/email from the 'users' collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) throw 'User profile not found in database';
      final userData = userDoc.data()!;

      // 1. Check if user already applied for this specific jobId
      final check = await FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: widget.job.id)
          .where('userId', isEqualTo: user.uid)
          .get();

      if (check.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have already applied for this position')),
          );
        }
        setState(() => loading = false);
        return;
      }

      // 2. Submit to 'applications' collection
      await FirebaseFirestore.instance.collection('applications').add({
        'jobId': widget.job.id,
        'jobTitle': widget.job.title,
        'adminId': widget.job.adminId, // From your Firebase job data
        'userId': user.uid,
        'userName': userData['name'],
        'userEmail': userData['email'],
        'studentId': _idController.text.trim(),
        'semester': _semesterController.text.trim(),
        'cgpa': _cgpaController.text.trim(),
        'resumeLink': _resumeController.text.trim(), // Modern Link field
        'status': 'pending',
        'appliedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
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
              Navigator.pop(context); // Back to details
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
        title: const Text("Job Application", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Job Info Summary
              Text(widget.job.title,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E2A47))),
              Text(widget.job.department,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF4A90E2))),
              const SizedBox(height: 30),

              _buildLabel("Official Student ID"),
              _customField(_idController, "e.g., 22-XXXXX-1", Icons.badge_outlined),

              const SizedBox(height: 18),
              _buildLabel("Current Running Semester"),
              _customField(_semesterController, "e.g., 8th Semester", Icons.layers_outlined),

              const SizedBox(height: 18),
              _buildLabel("Current CGPA"),
              _customField(_cgpaController, "e.g., 3.85", Icons.auto_awesome_outlined, type: TextInputType.number),

              const SizedBox(height: 18),
              _buildLabel("Resume Link"),
              _customField(_resumeController, "Google Drive or LinkedIn link", Icons.link_rounded),

              const SizedBox(height: 40),

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
                      : const Text("Confirm & Submit",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0E2A47))),
    );
  }

  Widget _customField(TextEditingController ctrl, String hint, IconData icon, {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      validator: (val) => val!.isEmpty ? "This information is required" : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF4A90E2)),
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
        ),
      ),
    );
  }
}