import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider/my_auth_provider.dart';

class UpdateProfileScreen extends StatefulWidget {
  final Map<String, dynamic> existingData;

  const UpdateProfileScreen({super.key, required this.existingData});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _idController;
  late TextEditingController _deptController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.existingData['studentId'] ?? '');
    _deptController = TextEditingController(text: widget.existingData['department'] ?? '');
    _addressController = TextEditingController(text: widget.existingData['address'] ?? '');
  }

  @override
  void dispose() {
    _idController.dispose();
    _deptController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text("Update Academic Info", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF081A2F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Complete Your Profile",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0E2A47)),
              ),
              const SizedBox(height: 8),
              const Text(
                "These details will be stored in your student records.",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              _buildInputLabel("Student ID Number"),
              _customTextField(_idController, "e.g. 2024-0012", Icons.fingerprint_rounded),

              const SizedBox(height: 20),
              _buildInputLabel("Department / Faculty"),
              _customTextField(_deptController, "e.g. Computer Science", Icons.school_outlined),

              const SizedBox(height: 20),
              _buildInputLabel("Home Address"),
              _customTextField(_addressController, "e.g. Dhaka, Bangladesh", Icons.location_on_outlined, maxLines: 3),

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
                  onPressed: authProvider.loading ? null : () async {
                    if (_formKey.currentState!.validate()) {
                      await authProvider.updateAdditionalDetails(
                        studentId: _idController.text.trim(),
                        department: _deptController.text.trim(),
                        address: _addressController.text.trim(),
                      );

                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: authProvider.loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Save Profile Details",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0E2A47))),
    );
  }

  Widget _customTextField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (value) => value!.isEmpty ? "This field is required" : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF4A90E2)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF4A90E2), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}