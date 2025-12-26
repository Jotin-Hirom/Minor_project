// ignore_for_file: deprecated_member_use
import 'package:classqr/models/app_user.dart';
import 'package:classqr/services/image_Picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../components/field_Style.dart';
import '../../../providers/image_provider.dart';

final profileImagePathProvider = StateProvider<String?>((ref) => null);

class ProfileTab extends ConsumerWidget {
  final User? user;
  ProfileTab({super.key, required this.user});

  dynamic profileImageFile;
  final TextEditingController batchYearController = TextEditingController();
  String? studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final imagePath = ref.watch(profileImagePathProvider);
    // user.id
    studentId = user?.id.toString();
    print(studentId);
    return ListView(
      padding: const EdgeInsets.all(16),

      children: [
        // PROFILE CARD
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(.05),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 45,
                backgroundColor: Colors.indigo.shade100,
                child: Text(
                  user?.name?[0].toUpperCase() ?? "S",
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? "Student",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      user?.email ?? "",
                      style: const TextStyle(color: Colors.black54),
                    ),
                    Text(
                      user?.role?.toUpperCase() ?? "STUDENT",
                      style: const TextStyle(color: Colors.black87),
                    ),
                  ],
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, // required for strict width
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,

                    builder: (context) {
                      return _edit_profile(context, ref);
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text("Edit Profile", textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // CALENDAR
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(8),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            dayHitTestBehavior: HitTestBehavior.opaque,
            onDaySelected: (selectedDay, focusedDay) {
              // Handle day selection if needed
              print('Selected day: $selectedDay');
              print('Focused day: $focusedDay');
            },
            focusedDay: DateTime.now(),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }

  WillPopScope _edit_profile(BuildContext context, WidgetRef ref) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        return true;
      },
      child: AlertDialog(
        backgroundColor: Colors.white54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text(
            "Edit Profile",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        content: SingleChildScrollView(
          child: Column(
            // mainAxisSize: MainAxisSize.min,
            children: [
              // ---------------- PROFILE IMAGE ----------------
              Consumer(
                builder: (context, ref, _) {
                  final imageBytes = ref.watch(profileImageProvider);

                  return Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.indigo.shade100,
                        backgroundImage: imageBytes != null
                            ? MemoryImage(imageBytes)
                            : null,
                        child: imageBytes == null
                            ? Text(
                                user?.name?[0].toUpperCase() ?? "S",
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.indigo,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final bytes =
                                await ImagePickerService.pickProfileImageFromGallery();
                            if (bytes != null) {
                              ref
                                  .read(profileImageProvider.notifier)
                                  .setImage(bytes);
                            }
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // ---------------- FIXED FIELDS ----------------
              TextFormField(
                initialValue: user?.name ?? "",
                readOnly: true,
                decoration: fieldStyle("Name"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                initialValue: "",
                readOnly: true,
                decoration: fieldStyle("Roll Number"),
              ),
              const SizedBox(height: 12),

              TextFormField(
                initialValue: "",
                // initialValue: user.programme ?? "",
                readOnly: true,
                decoration: fieldStyle("Programme"),
              ),

              const SizedBox(height: 20),
              TextFormField(
                initialValue: "",
                // initialValue: user.programme ?? "",
                readOnly: true,
                decoration: fieldStyle("Semester"),
              ),

              const SizedBox(height: 12),

              TextFormField(
                // controller: batchController,
                decoration: fieldStyle("Batch Year"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),

        // ---------------- ACTION BUTTONS ----------------
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
               final imageBytes = ref.read(profileImageProvider);

              if (imageBytes != null) {
                // Call backend upload
                // await ProfileService.uploadProfileImage(imageBytes);
              }
              // final uri = Uri.parse('${Env.apiBaseUrl}/api/student/$user?.id');

              // final request = http.MultipartRequest('PUT', uri);
              dynamic request;
              // ---- Headers (add auth if required)
              // request.headers.addAll({
              //   'Accept': 'application/json',
              //   'Authorization': 'Bearer $',
              // });

              // ---- Text fields
              request.fields['batchYear'] = batchYearController.text
                  .toLowerCase();
              // request.fields['semester'] = selectedSemester ?? '';

              // ---- Image file
              if (profileImageFile != null) {
                request.files.add(
                  await http.MultipartFile.fromPath(
                    'profileImage', // MUST match backend key
                    profileImageFile!.path,
                  ),
                );
              }

              // ---- Send request
              final streamedResponse = await request.send();
              final response = await http.Response.fromStream(streamedResponse);

              if (response.statusCode == 200) {
                final data = jsonDecode(response.body);
                debugPrint('Profile updated: $data');
              } else {
                debugPrint(
                  'Update failed [${response.statusCode}]: ${response.body}',
                );
                throw Exception('Profile update failed');
              }
              Navigator.pop(context);
            },
            child: const Text(
              "Save Changes",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _info(String title, String value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4),
  //     child: Row(
  //       children: [
  //         Text("$title: ", style: const TextStyle(fontWeight: FontWeight.bold)),
  //         Expanded(child: Text(value)),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> updateStudentProfile() async {

  // }
}
