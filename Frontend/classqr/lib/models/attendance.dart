class AttendanceRecord {
  final String id;
  final String subjectCode;
  final String studentId;
  final DateTime date;
  final bool present;

  AttendanceRecord({
    required this.id,
    required this.subjectCode,
    required this.studentId,
    required this.date,
    required this.present,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> j) => AttendanceRecord(
    id: j['id'].toString(),
    subjectCode: j['Code'] ?? '',
    studentId: j['studentId'] ?? '',
    date: DateTime.parse(j['date'] as String),
    present: j['present'] == true || j['present'] == 1,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'subjectCode': subjectCode,
    'studentId': studentId,
    'date': date.toIso8601String(),
    'present': present, 
  };
}
