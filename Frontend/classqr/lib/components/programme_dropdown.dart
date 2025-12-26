import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final selectedProgrammeProvider = StateProvider<String?>((ref) => null);

class ProgrammeDropdown extends ConsumerWidget {
  const ProgrammeDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<String> programmes = [
      "Advanced Diploma in Healthcare Informatics and Management",
      "B.A. in Chinese",
      "B.A. B.Ed. (Integrated)",
      "B.Ed.",
      "B.Tech. in Civil Engineering",
      "B.Tech. in Computer Science & Engineering",
      "B.Tech. in Electrical Engineering",
      "B.Tech. in Electronics & Communication Engineering",
      "B.Tech. in Food Engineering & Technology",
      "B.Tech. in Mechanical Engineering",
      "B.Voc. in Food Processing",
      "B.Voc. in Renewable Energy",
      "Certificate in Air Ticketing and Computerized Reservation System",
      "Certificate in Chinese",
      "Certificate in NSE Academy Certified Capital Market Professional (NCCMP)",
      "Certificate in Technical Writing",
      "Diploma in Paralegal Practice",
      "Integrated B.Sc. B.Ed. (Chemistry)",
      "Integrated B.Sc. B.Ed. (Mathematics)",
      "Integrated B.Sc. B.Ed. (Physics)",
      "Integrated M.A. in English",
      "Integrated M.Com",
      "Integrated M.Sc. in Bioscience & Bioinformatics",
      "Integrated M.Sc. in Chemistry",
      "Integrated M.Sc. in Life Science",
      "Integrated M.Sc. in Mathematics",
      "Integrated M.Sc. in Physics",
      "LL.M.",
      "M.A. in Assamese",
      "M.A. in Cultural Studies",
      "M.A. in Education",
      "M.A. in English",
      "M.A. in Hindi",
      "M.A. in Linguistics and Language Technology",
      "M.A. in Mass Communication & Journalism",
      "M.A. in Social Work",
      "M.A. in Sociology",
      "M.A. in Women Studies",
      "Master of Business Administration",
      "Master of Computer Application (MCA)",
      "Master of Design",
      "Master of Tourism & Travel Management",
      "MBA (Executive) – Online/Part-time",
      "M.Com",
      "M.Ed.",
      "M.Sc. in Chemistry",
      "M.Sc. in Environmental Science",
      "M.Sc. in Mathematics",
      "M.Sc. in Molecular Biology & Biotechnology",
      "M.Sc. in Nanoscience & Technology",
      "M.Sc. in Physics",
      "M.Tech. in Bioelectronics",
      "M.Tech. in Civil Engineering",
      "M.Tech. in Computer Science & Engineering",
      "M.Tech. in Data Science",
      "M.Tech. in Electrical Engineering",
      "M.Tech. in Electronics Design & Technology",
      "M.Tech. in Energy Technology",
      "M.Tech. in Food Engineering & Technology",
      "M.Tech. in Mechanical Engineering",
      "M.Tech. in Polymer Science & Technology",
      "M.Tech. in Semiconductor Technology",
      "P.G. Diploma in Child Rights & Governance",
      "P.G. Diploma in Mobile & Multimedia Communication",
      "P.G. Diploma in Tourism Management (PGDTM)",
      "P.G. Diploma in Translation (Hindi)",
      "P.G. Diploma in Women’s Studies",
    ];

    final selectedProgramme = ref.watch(selectedProgrammeProvider);

    return DropdownButtonFormField<String>(
      value: selectedProgramme,
      decoration: InputDecoration(
        labelText: "Programme",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      isExpanded: true,

      selectedItemBuilder: (context) {
        return programmes.map((p) {
          return Text(
            p,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }).toList();
      },

      items: programmes.map(
        (p) => DropdownMenuItem<String>(
          value: p,
          child: Text(
            p,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ).toList(),

      onChanged: (value) {
        ref.read(selectedProgrammeProvider.notifier).state = value;
      },
    );
  }
}
