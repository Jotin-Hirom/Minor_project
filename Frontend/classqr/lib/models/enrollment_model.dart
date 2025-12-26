class EnrolledStudent {
  final String userId;
  final String rollNo;
  final String name;
  final bool present;

  EnrolledStudent({
    required this.userId,
    required this.rollNo,
    required this.name,
    required this.present,
  });

  factory EnrolledStudent.fromJson(Map<String, dynamic> json) {
    return EnrolledStudent(
      userId: json['user_id'],
      rollNo: json['roll_no'],
      name: json['sname'],
      present: json['present'],
    );
  }
}
