import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/transport_model.dart';
import '../../../providers/auth_provider/transport_provider.dart';

const Color primaryTeal = Color(0xFF3CC6C6);
const Color darkNavy = Color(0xFF081A2F);
const Color navy = Color(0xFF0E2A47);
const Color bgColor = Color(0xFFF8F9FB);

class UpdateTransportScreen extends StatefulWidget {
  final TransportModel job;

  const UpdateTransportScreen({
    super.key,
    required this.job,
  });

  @override
  State<UpdateTransportScreen> createState() => _UpdateTransportScreenState();
}

class _UpdateTransportScreenState extends State<UpdateTransportScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _routeController;
  late TextEditingController _salaryController;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job.title);
    _descriptionController = TextEditingController(text: widget.job.description);
    _routeController = TextEditingController(text: widget.job.route);
    _salaryController = TextEditingController(text: widget.job.salary);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _routeController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _updateTransportJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUpdating = true);

    try {
      final updatedJob = TransportModel(
        id: widget.job.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        route: _routeController.text.trim(),
        salary: _salaryController.text.trim(),
        createdAt: widget.job.createdAt,
        adminId: widget.job.adminId,
      );

      await Provider.of<TransportProvider>(
        context,
        listen: false,
      ).updateTransportJob(updatedJob);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Transport job updated successfully")),
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
      if (mounted) setState(() => _isUpdating = false);
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
                          icon: _isUpdating
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.save),
                          label: Text(
                            _isUpdating ? "Updating..." : "Update Job",
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
                          onPressed: _isUpdating ? null : _updateTransportJob,
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
                  "Update Transport Job",
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
            child: Icon(Icons.edit_road, color: Colors.white),
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