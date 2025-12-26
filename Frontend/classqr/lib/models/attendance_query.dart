class AttendanceQuery {
  final String course_id;
  final String date; // yyyy-MM-dd

  AttendanceQuery({required this.course_id, required this.date});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceQuery &&
          course_id == other.course_id &&
          date == other.date;

  @override
  int get hashCode => course_id.hashCode ^ date.hashCode;
}
