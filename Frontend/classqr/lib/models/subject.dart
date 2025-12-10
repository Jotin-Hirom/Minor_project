class Subject {
  final String code;
  final String courseName;

  Subject({required this.code, required this.courseName});

  // Convert JSON -> Dart object
  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(code: json['code'], courseName: json['course_name']);
  }

  // Convert Dart object -> JSON (optional)
  Map<String, dynamic> toJson() {
    return {'code': code, 'course_name': courseName};
  }
}
