import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job_model.dart';
import '../../providers/auth_provider/job_provider.dart';

class UpdateJobScreen extends StatefulWidget {
  final JobModel job;

  const UpdateJobScreen({super.key, required this.job});

  @override
  State<UpdateJobScreen> createState() => _UpdateJobScreenState();
}

class _UpdateJobScreenState extends State<UpdateJobScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _departmentController;
  late TextEditingController _salaryController;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.job.title);
    _descriptionController = TextEditingController(text: widget.job.description);
    _departmentController = TextEditingController(text: widget.job.department);
    _salaryController = TextEditingController(text: widget.job.salary);
    _deadline = widget.job.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _departmentController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _deadline = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final jobProvider = Provider.of<JobProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Job'),
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
                decoration: const InputDecoration(labelText: 'Job Title'),
                validator: (val) => val!.isEmpty ? 'Enter job title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Job Description'),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? 'Enter job description' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _salaryController,
                decoration: const InputDecoration(labelText: 'Salary'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Deadline'),
                subtitle: Text(_deadline != null
                    ? '${_deadline!.toLocal()}'.split(' ')[0]
                    : 'Select a date'),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDeadline,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3CC6C6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate() && _deadline != null) {
                    await jobProvider.updateJob(widget.job.id, {
                      'title': _titleController.text,
                      'description': _descriptionController.text,
                      'department': _departmentController.text,
                      'salary': _salaryController.text,
                      'deadline': _deadline,
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Job updated successfully')),
                    );

                    Navigator.pop(context);
                  }
                },
                child: const Text('Update Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
