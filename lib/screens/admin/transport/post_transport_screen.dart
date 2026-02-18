import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/transport_model.dart';
import '../../../providers/auth_provider/transport_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  void _postTransportJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser!;
      TransportModel transport = TransportModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        route: _routeController.text.trim(),
        salary: _salaryController.text.trim(),
        createdAt: DateTime.now(),
        adminId: user.uid,
      );

      await Provider.of<TransportProvider>(context, listen: false)
          .postTransportJob(transport);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transport job posted successfully!')),
      );
      _formKey.currentState!.reset();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post Transport Job'),
        backgroundColor: const Color(0xFF3CC6C6),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Job Title',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Enter job title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _routeController,
                decoration: const InputDecoration(
                  labelText: 'Route',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Enter route' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'Salary',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Enter salary' : null,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _postTransportJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3CC6C6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Post Transport Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
