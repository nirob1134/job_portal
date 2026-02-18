import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider/event_provider.dart';

const Color primaryTeal = Color(0xFF3CC6C6);

class PostEvent extends StatefulWidget {
  const PostEvent({super.key});

  @override
  State<PostEvent> createState() => _PostEventState();
}

class _PostEventState extends State<PostEvent> {
  final _formKey = GlobalKey<FormState>();

  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final locationCtrl = TextEditingController();
  final organizerCtrl = TextEditingController();

  DateTime? eventDate;
  bool loading = false;

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => eventDate = picked);
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate() || eventDate == null) return;

    setState(() => loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final event = EventModel(
      id: '',
      adminId: uid,
      title: titleCtrl.text.trim(),
      description: descCtrl.text.trim(),
      location: locationCtrl.text.trim(),
      organizer: organizerCtrl.text.trim(),
      eventDate: eventDate!,
      createdAt: DateTime.now(),
    );

    await context.read<EventProvider>().postEvent(event);

    setState(() => loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Event Posted Successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Post Event"),
        backgroundColor: primaryTeal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildField(titleCtrl, "Event Title"),
                const SizedBox(height: 12),
                _buildField(descCtrl, "Description", maxLines: 4),
                const SizedBox(height: 12),
                _buildField(locationCtrl, "Location"),
                const SizedBox(height: 12),
                _buildField(organizerCtrl, "Organizer"),
                const SizedBox(height: 16),

                // Date Picker
                GestureDetector(
                  onTap: pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          eventDate == null
                              ? "Pick Event Date"
                              : eventDate!.toLocal().toString().split(' ')[0],
                          style: TextStyle(
                            fontSize: 16,
                            color: eventDate == null
                                ? Colors.grey.shade600
                                : Colors.black87,
                          ),
                        ),
                        const Icon(Icons.calendar_today, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Post Event Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: loading ? null : submit,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "Post Event",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: (v) => v!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
