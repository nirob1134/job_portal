import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../providers/auth_provider/job_provider.dart';

const Color primaryTeal = Color(0xFF3CC6C6);

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final title = TextEditingController();
  final desc = TextEditingController();
  final dept = TextEditingController();
  final salary = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post Job'), backgroundColor: primaryTeal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildField(title, 'Job Title'),
            _buildField(desc, 'Description', maxLines: 3),
            _buildField(dept, 'Department'),
            _buildField(salary, 'Salary'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (title.text.isEmpty ||
                    desc.text.isEmpty ||
                    dept.text.isEmpty ||
                    salary.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Fill all fields!')),
                  );
                  return;
                }

                final job = JobModel(
                  id: '',
                  title: title.text,
                  description: desc.text,
                  department: dept.text,
                  salary: salary.text,
                  deadline: DateTime.now().add(const Duration(days: 30)),
                  createdAt: DateTime.now(),
                  adminId: '', // Will be set in provider
                );

                await context.read<JobProvider>().postJob(job);
                Navigator.pop(context);
              },
              child: const Text('Post Job'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
