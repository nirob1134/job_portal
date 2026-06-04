class TransportApplicationModel {
  final String id;
  final String transportJobId;
  final String transportJobTitle;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String studentId;
  final String runningSemester;
  final String cgpa;
  final String route;
  final String coverLetter;
  final String status;

  TransportApplicationModel({
    required this.id,
    required this.transportJobId,
    required this.transportJobTitle,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.studentId,
    required this.runningSemester,
    required this.cgpa,
    required this.route,
    required this.coverLetter,
    required this.status,
  });


  factory TransportApplicationModel.fromMap(
      Map<String, dynamic> map, String id) {
    return TransportApplicationModel(
      id: id,
      transportJobId: map['transportJobId'] ?? '',
      transportJobTitle: map['transportJobTitle'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'] ?? '',
      studentId: map['studentId'] ?? '',
      runningSemester: map['runningSemester'] ?? '',
      cgpa: map['cgpa'] ?? '',
      route: map['route'] ?? '',
      coverLetter: map['coverLetter'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'transportJobId': transportJobId,
      'transportJobTitle': transportJobTitle,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'studentId': studentId,
      'runningSemester': runningSemester,
      'cgpa': cgpa,
      'route': route,
      'coverLetter': coverLetter,
      'status': status,
    };
  }
}
