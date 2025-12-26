class StudentModel {
  final String userId;
  final String rollNo;
  final String name;
  final int semester;
  final String programme;
  final int batch;
  final String? photoUrl;
  final bool isBlocked;

  StudentModel({
    required this.userId,
    required this.rollNo,
    required this.name,
    required this.semester,
    required this.programme,
    required this.batch,
    this.photoUrl,
    required this.isBlocked,
  });

  /// FROM JSON
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      userId: json['user_id'] as String,
      rollNo: json['roll_no'] as String,
      name: json['sname'] as String,
      semester: json['semester'] as int,
      programme: json['programme'] as String,
      batch: json['batch'] as int,
      photoUrl: json['photo_url'],
      isBlocked: json['isblocked'] as bool,
    );
  }

  /// TO JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'roll_no': rollNo,
      'sname': name,
      'semester': semester,
      'programme': programme,
      'batch': batch,
      'photo_url': photoUrl,
      'isblocked': isBlocked,
    };
  }
}
