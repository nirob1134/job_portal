import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/job_model.dart';
import '../../providers/auth_provider/job_provider.dart';

const Color primaryTeal = Color(0xFF3CC6C6);

class UpdateJobScreen extends StatefulWidget {
  final JobModel job;

  const UpdateJobScreen({
    super.key,
    required this.job,
  });

  @override
  State<UpdateJobScreen> createState() => _UpdateJobScreenState();
}

class _UpdateJobScreenState extends State<UpdateJobScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _departmentController;
  late TextEditingController _salaryController;
  late TextEditingController _vacancyController;
  late TextEditingController _requirementsController;

  // Dropdown States
  String _selectedWorkType = "Part-Time";
  String _selectedStatus = "active";

  DateTime? _deadline;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.job.title);
    _descriptionController = TextEditingController(text: widget.job.description);
    _departmentController = TextEditingController(text: widget.job.department);
    _salaryController = TextEditingController(text: widget.job.salary);
    _vacancyController = TextEditingController(text: widget.job.vacancy.toString());

    // Join the requirements list array into a comma-separated text string for editing
    _requirementsController = TextEditingController(text: widget.job.requirements.join(', '));

    _selectedWorkType = widget.job.workType.isNotEmpty ? widget.job.workType : "Part-Time";
    _selectedStatus = widget.job.status.isNotEmpty ? widget.job.status : "active";
    _deadline = widget.job.deadline;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _departmentController.dispose();
    _salaryController.dispose();
    _vacancyController.dispose();
    _requirementsController.dispose();
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

  Future<void> _updateJob() async {
    if (!_formKey.currentState!.validate() || _deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all required fields")),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    // Parse text field content back to a string array
    List<String> requirementsList = _requirementsController.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    await context.read<JobProvider>().updateJob(
      widget.job.id,
      {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'department': _departmentController.text.trim(),
        'salary': _salaryController.text.trim(),
        'workType': _selectedWorkType,
        'vacancy': int.tryParse(_vacancyController.text.trim()) ?? 1,
        'status': _selectedStatus,
        'requirements': requirementsList,
        'deadline': _deadline,
      },
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job updated successfully')),
      );

      Navigator.pop(context);
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildHeader(context),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: _cardDecoration(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(
                        controller: _titleController,
                        label: "Job Title",
                        icon: Icons.work_outline,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: _descriptionController,
                        label: "Job Description",
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: _departmentController,
                        label: "Department",
                        icon: Icons.apartment,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: _salaryController,
                        label: "Salary",
                        icon: Icons.payments_outlined,
                      ),

                      const SizedBox(height: 16),

                      // Full-width Work Type Dropdown
                      _buildDropdown(
                        icon: Icons.schedule,
                        value: _selectedWorkType,
                        items: ["Part-Time", "Full-Time", "Internship"],
                        onChanged: (val) => setState(() => _selectedWorkType = val!),
                      ),

                      const SizedBox(height: 16),

                      // Vacancy Field (Stacked Vertically, No Label Text)
                      _buildField(
                        controller: _vacancyController,
                        label: "",
                        icon: Icons.groups_outlined,
                        keyboardType: TextInputType.number,
                        hintText: "Number of Vacancies",
                        validator: (value) {
                          if (value == null || int.tryParse(value) == null || int.parse(value) <= 0) {
                            return "Required";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Status Dropdown (Stacked Vertically below Vacancy)
                      _buildDropdown(
                        icon: Icons.toggle_on_outlined,
                        value: _selectedStatus,
                        items: ["active", "closed"],
                        onChanged: (val) => setState(() => _selectedStatus = val!),
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: _requirementsController,
                        label: "Requirements (Comma-separated)",
                        icon: Icons.fact_check_outlined,
                        maxLines: 2,
                        hintText: "e.g., Flutter, Dart, Git, CGPA 3.0+",
                        isOptional: true,
                      ),

                      const SizedBox(height: 16),

                      GestureDetector(
                        onTap: _pickDeadline,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FB),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.grey.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_month,
                                color: primaryTeal,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _deadline == null
                                      ? "Select Deadline"
                                      : _deadline!
                                      .toLocal()
                                      .toString()
                                      .split(' ')[0],
                                  style: TextStyle(
                                    color: _deadline == null
                                        ? Colors.grey.shade600
                                        : const Color(0xFF081A2F),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : _updateJob,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryTeal,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: loading
                              ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Text(
                            "Update Job",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
      padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF081A2F), Color(0xFF0E2A47)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            style: IconButton.styleFrom(backgroundColor: Colors.white24),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Admin Action",
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                SizedBox(height: 2),
                Text(
                  "Update Job",
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
            child: Icon(Icons.edit_note, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
    String? Function(String?)? validator,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator ?? (value) {
        if (!isOptional && (value == null || value.trim().isEmpty)) {
          return "This field is required";
        }
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryTeal),
        labelText: label.isEmpty ? null : label,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryTeal),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(fontSize: 13, color: Color(0xFF081A2F)),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryTeal),
        filled: true,
        fillColor: const Color(0xFFF8F9FB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryTeal),
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
          color: Colors.black.withOpacity(0.05),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}