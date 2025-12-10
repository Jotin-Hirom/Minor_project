class Student {
  final String id;
  final String name;
  final String email;
  final String roll;
  final String programme;
  final String semester;
  final String profileImageUrl;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.roll,
    required this.programme,
    required this.semester,
    required this.profileImageUrl,
  });

  factory Student.fromJson(Map<String, dynamic> j) => Student(
        id: j['id'].toString(),
        name: j['name'] ?? '',
        email: j['email'] ?? '',
        roll: j['roll_no'] ?? '',
        programme: j['programme'] ?? '',
        semester: j['semester']?.toString() ?? '',
        profileImageUrl: j['profile_image_url']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'roll_no': roll,
        'programme': programme,
        'semester': semester,
        'profile_image_url': profileImageUrl,
      };
}
