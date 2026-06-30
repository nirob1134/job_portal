import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> sendEmailJS({
  required String userName,
  required String userEmail,
  required String jobTitle,
  required String status,
}) async {
  final serviceId = 'service_p5oftvq';
  final templateId = status == 'accepted'
      ? 'template_lfzzncx'
      : 'template_1xw74eq';
  final userId = 'vmX9YYo3sye5bIv8w';

  final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

  final response = await http.post(
    url,
    headers: {
      'origin': 'http://localhost',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'service_id': serviceId,
      'template_id': templateId,
      'user_id': userId,
      'template_params': {
        'user_name': userName,
        'user_email': userEmail,
        'job_title': jobTitle,
        'status': status,
      },
    }),
  );

  if (response.statusCode == 200) {
    print('Email sent to $userEmail');
  } else {
    print('Failed to send email: ${response.body}');
  }
}