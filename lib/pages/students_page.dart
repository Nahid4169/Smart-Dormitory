import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/dorm_models.dart';

class StudentsPage extends StatelessWidget {
  final List<Student> students;
  final String studentSearch;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddStudent;
  final ValueChanged<Student> onAllocateStudent;
  final ValueChanged<Student> onDeleteStudent;

  const StudentsPage({
    super.key,
    required this.students,
    required this.studentSearch,
    required this.onSearchChanged,
    required this.onAddStudent,
    required this.onAllocateStudent,
    required this.onDeleteStudent,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = students.where((s) {
      final q = studentSearch.toLowerCase();
      return s.name.toLowerCase().contains(q) ||
          s.id.toLowerCase().contains(q) ||
          s.department.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        header('Student Management', 'Manage all student records and room allocations.'),
        TextField(
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search name, ID or department',
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.spaceBetween,
          children: [
            Text(
              '${filtered.length} students displayed',
              style: const TextStyle(color: muted),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: purple),
              onPressed: onAddStudent,
              icon: const Icon(Icons.person_add),
              label: const Text('Add Student'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        ...filtered.map((s) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: cardDecoration(),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFF293650),
              child: Icon(Icons.person, color: purple),
            ),
            title: Text(s.name),
            subtitle: Text(
              '${s.id}\n${s.department}\nRoom: ${s.room.isEmpty ? 'Unassigned' : s.room}',
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'allocate') onAllocateStudent(s);
                if (v == 'delete') onDeleteStudent(s);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'allocate',
                  child: Text('Allocate / Change Room'),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete Student'),
                ),
              ],
            ),
          ),
        )),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(25),
            child: Center(child: Text('No matching students found.')),
          ),
      ],
    );
  }
}
