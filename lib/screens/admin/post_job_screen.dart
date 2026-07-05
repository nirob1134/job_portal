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
  final _formKey = GlobalKey<FormState>();

  final title = TextEditingController();
  final desc = TextEditingController();
  final dept = TextEditingController();
  final salary = TextEditingController();

  // Controllers
  final vacancy = TextEditingController(text: "1");
  final requirements = TextEditingController();

  // Dropdown States
  String selectedWorkType = "Part-Time";
  String selectedStatus = "active";

  DateTime? deadline;
  bool loading = false;

  @override
  void dispose() {
    title.dispose();
    desc.dispose();
    dept.dispose();
    salary.dispose();
    vacancy.dispose();
    requirements.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: deadline ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        deadline = picked;
      });
    }
  }

  Future<void> _submitJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    List<String> requirementsList = requirements.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final job = JobModel(
      id: '',
      title: title.text.trim(),
      description: desc.text.trim(),
      department: dept.text.trim(),
      salary: salary.text.trim(),
      deadline: deadline ?? DateTime.now().add(const Duration(days: 30)),
      createdAt: DateTime.now(),
      adminId: '',
      workType: selectedWorkType,
      requirements: requirementsList,
      status: selectedStatus,
      vacancy: int.tryParse(vacancy.text.trim()) ?? 1,
    );

    await context.read<JobProvider>().postJob(job);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Job posted successfully")),
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
                        controller: title,
                        label: "Job Title",
                        icon: Icons.work_outline,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: desc,
                        label: "Description",
                        icon: Icons.description_outlined,
                        maxLines: 4,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: dept,
                        label: "Department",
                        icon: Icons.apartment,
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: salary,
                        label: "Salary / Remuneration",
                        icon: Icons.payments_outlined,
                      ),

                      const SizedBox(height: 16),

                      // Full-width Work Type Dropdown
                      _buildDropdown(
                        icon: Icons.schedule,
                        value: selectedWorkType,
                        items: ["Part-Time", "Full-Time", "Internship"],
                        onChanged: (val) => setState(() => selectedWorkType = val!),
                      ),

                      const SizedBox(height: 16),

                      // Vacancy Field (Stacked Vertically, No Label Text)
                      _buildField(
                        controller: vacancy,
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
                        value: selectedStatus,
                        items: ["active", "closed"],
                        onChanged: (val) => setState(() => selectedStatus = val!),
                      ),

                      const SizedBox(height: 16),

                      _buildField(
                        controller: requirements,
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
                              const Icon(Icons.calendar_month, color: primaryTeal),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  deadline == null
                                      ? "Select Deadline"
                                      : deadline!.toLocal().toString().split(' ')[0],
                                  style: TextStyle(
                                    color: deadline == null
                                        ? Colors.grey.shade600
                                        : const Color(0xFF081A2F),
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading ? null : _submitJob,
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
                            "Post Job",
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
            child: Icon(Icons.add_business, color: Colors.white),
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