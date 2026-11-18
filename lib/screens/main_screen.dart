import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme.dart';
import '../models/dorm_models.dart';
import '../pages/dashboard_page.dart';
import '../pages/students_page.dart';
import '../pages/rooms_page.dart';
import '../pages/payments_page.dart';
import '../pages/maintenance_page.dart';
import '../pages/monitoring_page.dart';

class MainScreen extends StatefulWidget {
  final Future<void> Function() onLogout;

  const MainScreen({super.key, required this.onLogout});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  bool loading = true;
  String studentSearch = '';
  String roomSearch = '';

  final List<Student> students = [];
  final List<DormRoom> rooms = [];
  final List<Map<String, dynamic>> payments = [];

  final List<MaintenanceRequest> requests = [
    MaintenanceRequest(
      room: 'A-105',
      issue: 'Air conditioner repair',
    ),
    MaintenanceRequest(
      room: 'B-202',
      issue: 'Water leakage',
      status: 'In Progress',
    ),
  ];

  final pageNames = [
    'Dashboard',
    'Students',
    'Rooms',
    'Payments',
    'Maintenance',
    'Monitoring',
  ];

  final pageIcons = [
    Icons.dashboard_rounded,
    Icons.people_alt_rounded,
    Icons.bed_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.build_rounded,
    Icons.sensors_rounded,
  ];

  final firstNames = [
    'Rahim', 'Karim', 'Sabbir', 'Nusrat', 'Ayesha',
    'Hasan', 'Tanvir', 'Sadia', 'Fahim', 'Mim',
    'Rafi', 'Arif', 'Sumaiya', 'Nabila', 'Imran',
    'Farhan', 'Jannat', 'Sakib', 'Tania', 'Mahmud',
  ];

  final lastNames = [
    'Ahmed', 'Hasan', 'Hossain', 'Akter', 'Rahman',
    'Islam', 'Chowdhury', 'Khan', 'Miah', 'Sarker',
  ];

  final departments = [
    'Computer Engineering',
    'Computer Science',
    'Electrical Engineering',
    'Business Administration',
    'Mechanical Engineering',
    'Civil Engineering',
    'AI & Computer Engineering',
    'Software Engineering',
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      students.clear();
      rooms.clear();

      final savedRooms = prefs.getString('dorm_rooms');
      final savedStudents = prefs.getString('students');

      if (savedRooms != null) {
        final data = jsonDecode(savedRooms) as List;
        rooms.addAll(
          data.map((e) => DormRoom.fromJson(
            Map<String, dynamic>.from(e),
          )),
        );
      }

      if (savedStudents != null) {
        final data = jsonDecode(savedStudents) as List;
        students.addAll(
          data.map((e) => Student.fromJson(
            Map<String, dynamic>.from(e),
          )),
        );
      }

      // Add enough rooms to reach 220.
      final existingRoomIds = rooms.map((r) => r.id).toSet();

      for (int b = 0; b < 10 && rooms.length < 220; b++) {
        final building = String.fromCharCode(65 + b);

        for (int n = 101; n <= 122 && rooms.length < 220; n++) {
          final room = DormRoom(
            building: building,
            number: '$n',
          );

          if (existingRoomIds.add(room.id)) {
            rooms.add(room);
          }
        }
      }

      // Add sample students until there are 200.
      final existingIds = students.map((s) => s.id).toSet();

      for (int i = 0; students.length < 200; i++) {
        final number = i + 1;
        final first = firstNames[i % firstNames.length];
        final last = lastNames[(i ~/ firstNames.length) % lastNames.length];
        final id = 'STU-${1000 + number}';

        if (!existingIds.add(id)) continue;

        students.add(
          Student(
            name: '$first $last ${number > 20 ? number : ''}'.trim(),
            id: id,
            department: departments[i % departments.length],
          ),
        );
      }

      // Remove invalid or duplicate room assignments.
      final assigned = <String>{};

      for (final student in students) {
        if (student.room.isNotEmpty) {
          final valid = existingRoomIds.contains(student.room) ||
              rooms.any((r) => r.id == student.room);

          if (!valid || !assigned.add(student.room)) {
            student.room = '';
          }
        }
      }

      // Assign unassigned students to free rooms.
      for (final student in students) {
        if (student.room.isNotEmpty) continue;

        final freeRoom = rooms.cast<DormRoom?>().firstWhere(
              (room) => room != null && !assigned.contains(room.id),
          orElse: () => null,
        );

        if (freeRoom != null) {
          student.room = freeRoom.id;
          assigned.add(freeRoom.id);
        }
      }

      // Create a payment demonstration record for every student.
      payments.clear();
      for (int i = 0; i < students.length; i++) {
        payments.add({
          'name': students[i].name,
          'studentId': students[i].id,
          'amount': 350000,
          'paid': i % 2 == 0,
        });
      }

      await saveRooms();
      await saveStudents();
    } catch (e) {
      debugPrint('Data loading error: $e');
    }

    if (mounted) setState(() => loading = false);
  }

  Future<void> saveStudents() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'students',
      jsonEncode(students.map((s) => s.toJson()).toList()),
    );
  }

  Future<void> saveRooms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'dorm_rooms',
      jsonEncode(rooms.map((r) => r.toJson()).toList()),
    );
  }

  int occupants(String roomId) =>
      students.where((s) => s.room == roomId).length;

  bool isOccupied(String roomId) => occupants(roomId) >= 1;

  int get occupiedCount =>
      rooms.where((r) => isOccupied(r.id)).length;

  int get availableCount => rooms.length - occupiedCount;

  double get occupancyRate =>
      rooms.isEmpty ? 0 : occupiedCount / rooms.length;

  List<String> get availableRooms => rooms
      .where((r) => !isOccupied(r.id))
      .map((r) => r.id)
      .toList();

  void message(String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(value)),
    );
  }

  // Dialogs & Actions
  Future<void> addStudent() async {
    final name = TextEditingController();
    final id = TextEditingController();
    final department = TextEditingController();
    String selectedRoom = '';

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final choices = availableRooms;

          return AlertDialog(
            title: const Text('Register Student'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  input(name, 'Student full name'),
                  input(id, 'Student ID'),
                  input(department, 'Department'),
                  DropdownButtonFormField<String>(
                    value: selectedRoom,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Room'),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('Unassigned'),
                      ),
                      ...choices.map((r) => DropdownMenuItem(
                        value: r,
                        child: Text(r),
                      )),
                    ],
                    onChanged: (v) {
                      setDialogState(() => selectedRoom = v ?? '');
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (name.text.trim().isEmpty ||
                      id.text.trim().isEmpty ||
                      department.text.trim().isEmpty) {
                    message('Complete all required fields.');
                    return;
                  }

                  if (students.any((s) =>
                  s.id.toLowerCase() == id.text.trim().toLowerCase())) {
                    message('Student ID already exists.');
                    return;
                  }

                  if (selectedRoom.isNotEmpty && isOccupied(selectedRoom)) {
                    message('That room is already occupied.');
                    return;
                  }

                  students.add(Student(
                    name: name.text.trim(),
                    id: id.text.trim(),
                    department: department.text.trim(),
                    room: selectedRoom,
                  ));

                  payments.add({
                    'name': name.text.trim(),
                    'studentId': id.text.trim(),
                    'amount': 350000,
                    'paid': false,
                  });

                  await saveStudents();
                  if (!mounted) return;
                  setState(() {});
                  Navigator.pop(dialogContext);
                  message('Student registered successfully.');
                },
                child: const Text('Save Student'),
              ),
            ],
          );
        },
      ),
    );

    name.dispose();
    id.dispose();
    department.dispose();
  }

  Future<void> allocateStudent(Student student) async {
    String selected = student.room;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final choices = availableRooms;

          return AlertDialog(
            title: Text('Allocate ${student.name}'),
            content: DropdownButtonFormField<String>(
              value: selected,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Choose room'),
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Unassigned'),
                ),
                if (selected.isNotEmpty && !choices.contains(selected))
                  DropdownMenuItem(
                    value: selected,
                    child: Text(selected),
                  ),
                ...choices.map((r) => DropdownMenuItem(
                  value: r,
                  child: Text(r),
                )),
              ],
              onChanged: (v) => setDialogState(() => selected = v ?? ''),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  if (selected.isNotEmpty &&
                      students.any((s) =>
                      s.id != student.id && s.room == selected)) {
                    message('Room already occupied.');
                    return;
                  }

                  student.room = selected;
                  await saveStudents();
                  if (!mounted) return;
                  setState(() {});
                  Navigator.pop(dialogContext);
                  message('Room allocation updated.');
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> deleteStudent(Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete student?'),
        content: Text('Delete ${student.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      students.remove(student);
      payments.removeWhere((p) => p['studentId'] == student.id);
      await saveStudents();
      if (mounted) setState(() {});
      message('Student deleted.');
    }
  }

  Future<void> addRoom() async {
    final building = TextEditingController();
    final number = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add New Room'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            input(building, 'Building name (A, B, C...)'),
            input(number, 'Room number (101, 102...)'),
            const Text(
              'Room capacity is fixed at one student.',
              style: TextStyle(color: muted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final b = building.text.trim().toUpperCase();
              final n = number.text.trim();

              if (b.isEmpty || n.isEmpty) {
                message('Enter building and room number.');
                return;
              }

              if (rooms.any((r) => r.id.toLowerCase() == '$b-$n'.toLowerCase())) {
                message('This room already exists.');
                return;
              }

              rooms.add(DormRoom(building: b, number: n));
              await saveRooms();
              if (!mounted) return;
              setState(() {});
              Navigator.pop(dialogContext);
              message('Room $b-$n added.');
            },
            child: const Text('Add Room'),
          ),
        ],
      ),
    );

    building.dispose();
    number.dispose();
  }

  Future<void> deleteRoom(DormRoom room) async {
    if (isOccupied(room.id)) {
      message('Cannot delete an occupied room. Reassign the student first.');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete room?'),
        content: Text('Delete room ${room.id}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      rooms.remove(room);
      await saveRooms();
      if (mounted) setState(() {});
      message('Room deleted.');
    }
  }

  Future<void> addMaintenance() async {
    final room = TextEditingController();
    final issue = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Maintenance Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            input(room, 'Room number'),
            input(issue, 'Describe the problem'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (room.text.trim().isEmpty || issue.text.trim().isEmpty) {
                message('Complete all fields.');
                return;
              }

              setState(() {
                requests.add(MaintenanceRequest(
                  room: room.text.trim(),
                  issue: issue.text.trim(),
                ));
              });

              Navigator.pop(dialogContext);
              message('Maintenance request added.');
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    room.dispose();
    issue.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      DashboardPage(
        students: students,
        rooms: rooms,
        occupiedCount: occupiedCount,
        availableCount: availableCount,
        occupancyRate: occupancyRate,
        onViewAllStudents: () => setState(() => selectedIndex = 1),
      ),
      StudentsPage(
        students: students,
        studentSearch: studentSearch,
        onSearchChanged: (v) => setState(() => studentSearch = v),
        onAddStudent: addStudent,
        onAllocateStudent: allocateStudent,
        onDeleteStudent: deleteStudent,
      ),
      RoomsPage(
        rooms: rooms,
        students: students,
        roomSearch: roomSearch,
        onSearchChanged: (v) => setState(() => roomSearch = v),
        onAddRoom: addRoom,
        onDeleteRoom: deleteRoom,
        isOccupied: isOccupied,
        occupiedCount: occupiedCount,
        availableCount: availableCount,
      ),
      PaymentsPage(
        payments: payments,
        onTogglePayment: (p) => setState(() => p['paid'] = !(p['paid'] == true)),
      ),
      MaintenancePage(
        requests: requests,
        onAddRequest: addMaintenance,
        onUpdateStatus: (r, v) => setState(() => r.status = v),
      ),
      const MonitoringPage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 800;

            if (wide) {
              return Row(
                children: [
                  sidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        topBar(),
                        Expanded(child: pages[selectedIndex]),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                topBar(),
                Expanded(child: pages[selectedIndex]),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 800
          ? NavigationBar(
        backgroundColor: panel,
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) {
          setState(() => selectedIndex = i);
        },
        destinations: List.generate(
          pageNames.length,
              (i) => NavigationDestination(
            icon: Icon(pageIcons[i]),
            label: pageNames[i],
          ),
        ),
      )
          : null,
    );
  }

  Widget sidebar() {
    return Container(
      width: 220,
      color: panel,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(22),
            child: Row(
              children: [
                Icon(Icons.apartment, color: purple, size: 29),
                SizedBox(width: 10),
                Text(
                  'DORMITORY',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFF273149)),
          Expanded(
            child: ListView.builder(
              itemCount: pageNames.length,
              itemBuilder: (context, i) {
                final selected = selectedIndex == i;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 3,
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    selected: selected,
                    selectedTileColor: purple.withOpacity(0.16),
                    leading: Icon(
                      pageIcons[i],
                      color: selected ? purple : muted,
                    ),
                    title: Text(
                      pageNames[i],
                      style: TextStyle(
                        color: selected ? Colors.white : muted,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () => setState(() => selectedIndex = i),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(14),
            child: Text(
              'SMART DORMITORY v2.0',
              style: TextStyle(fontSize: 10, color: muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget topBar() {
    return Container(
      color: panel,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              pageNames[selectedIndex],
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(Icons.admin_panel_settings, color: purple),
          const SizedBox(width: 8),
          const Text('Administrator', style: TextStyle(color: muted)),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') await widget.onLogout();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
