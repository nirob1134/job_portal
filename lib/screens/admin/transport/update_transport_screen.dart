import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/transport_model.dart';
import '../../../providers/auth_provider/transport_provider.dart';

const Color primaryTeal = Color(0xFF3CC6C6);
const Color scaffoldBg = Color(0xFFF5F5F5);

class UpdateTransportScreen extends StatefulWidget {
  final TransportModel job;
  const UpdateTransportScreen({super.key, required this.job});

  @override
  State<UpdateTransportScreen> createState() => _UpdateTransportScreenState();
}

class _UpdateTransportScreenState extends State<UpdateTransportScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _routeController;
  late TextEditingController _salaryController;

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

  @override
  Widget build(BuildContext context) {
    final transportProvider = Provider.of<TransportProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Update Transport Job',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryTeal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a job title' : null,
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),

              // Route
              TextFormField(
                controller: _routeController,
                decoration: const InputDecoration(
                  labelText: 'Route',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Salary
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'Salary',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final updatedJob = TransportModel(
                        id: widget.job.id,
                        title: _titleController.text.trim(),
                        description: _descriptionController.text.trim(),
                        route: _routeController.text.trim(),
                        salary: _salaryController.text.trim(),
                        createdAt: widget.job.createdAt,
                        adminId: widget.job.adminId,
                      );

                      await transportProvider.updateTransportJob(updatedJob);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transport job updated successfully')),
                      );

                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Update Job',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
