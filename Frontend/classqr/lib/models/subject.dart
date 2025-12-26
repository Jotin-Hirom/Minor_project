class Course {
  final String code;
  final String courseName;
  final String course_id;

  Course({
    required this.code,
    required this.courseName,
    required this.course_id,
  });

  // Convert JSON -> Dart object
  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      code: json['code'],
      courseName: json['course_name'],
      course_id: json['course_id'],
    );
  }

  // Convert Dart object -> JSON (optional)
  Map<String, dynamic> toJson() {
    return {'course_id': course_id, 'code': code, 'course_name': courseName};
  }
}
