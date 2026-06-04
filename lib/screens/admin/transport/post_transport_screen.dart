import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/transport_model.dart';
import '../../../providers/auth_provider/transport_provider.dart';

const Color primaryTeal = Color(0xFF3CC6C6);
const Color darkNavy = Color(0xFF081A2F);
const Color navy = Color(0xFF0E2A47);
const Color bgColor = Color(0xFFF8F9FB);

class PostTransportScreen extends StatefulWidget {
  const PostTransportScreen({super.key});

  @override
  State<PostTransportScreen> createState() => _PostTransportScreenState();
}

class _PostTransportScreenState extends State<PostTransportScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _routeController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _postTransportJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;

      final transport = TransportModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        route: _routeController.text.trim(),
        salary: _salaryController.text.trim(),
        createdAt: DateTime.now(),
        adminId: user.uid,
      );

      await Provider.of<TransportProvider>(
        context,
        listen: false,
      ).postTransportJob(transport);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transport job posted successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: _cardDecoration(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _inputField(
                        controller: _titleController,
                        label: "Job Title",
                        icon: Icons.work_outline,
                        validatorText: "Enter job title",
                      ),
                      const SizedBox(height: 16),
                      _inputField(
                        controller: _descriptionController,
                        label: "Description",
                        icon: Icons.description_outlined,
                        validatorText: "Enter description",
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      _inputField(
                        controller: _routeController,
                        label: "Route",
                        icon: Icons.route,
                        validatorText: "Enter route",
                      ),
                      const SizedBox(height: 16),
                      _inputField(
                        controller: _salaryController,
                        label: "Salary",
                        icon: Icons.payments_outlined,
                        validatorText: "Enter salary",
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: _isLoading
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.publish),
                          label: Text(
                            _isLoading ? "Posting..." : "Post Transport Job",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isLoading ? null : _postTransportJob,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 50, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [darkNavy, navy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white24,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Transport Admin",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                SizedBox(height: 4),
                Text(
                  "Post New Job",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const CircleAvatar(
            backgroundColor: Colors.white24,
            child: Icon(Icons.add_road, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.trim().isEmpty) return validatorText;
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: primaryTeal),
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}