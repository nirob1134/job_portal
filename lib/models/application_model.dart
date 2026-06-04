class ApplicationModel {
  final String id;
  final String jobId;
  final String jobTitle;
  final String userId;
  final String userName;
  final String userEmail;
  final String userPhone;
  final String studentId;
  final String runningSemester;
  final String cgpa;
  final String coverLetter;
  final String status;

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.userPhone,
    required this.studentId,
    required this.runningSemester,
    required this.cgpa,
    required this.coverLetter,
    required this.status,
  });


  factory ApplicationModel.fromMap(Map<String, dynamic> map, String id) {
    return ApplicationModel(
      id: id,
      jobId: map['jobId'] ?? '',
      jobTitle: map['jobTitle'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userPhone: map['userPhone'] ?? '',
      studentId: map['studentId'] ?? '',
      runningSemester: map['runningSemester'] ?? '',
      cgpa: map['cgpa'] ?? '',
      coverLetter: map['coverLetter'] ?? '',
      status: map['status'] ?? 'pending',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'jobTitle': jobTitle,
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
      'studentId': studentId,
      'runningSemester': runningSemester,
      'cgpa': cgpa,
      'coverLetter': coverLetter,
      'status': status,
    };
  }
}
