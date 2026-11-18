import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/dorm_models.dart';

class DashboardPage extends StatelessWidget {
  final List<Student> students;
  final List<DormRoom> rooms;
  final int occupiedCount;
  final int availableCount;
  final double occupancyRate;
  final VoidCallback onViewAllStudents;

  const DashboardPage({
    super.key,
    required this.students,
    required this.rooms,
    required this.occupiedCount,
    required this.availableCount,
    required this.occupancyRate,
    required this.onViewAllStudents,
  });

  @override
  Widget build(BuildContext context) {
    final buildingCount = rooms.map((r) => r.building).toSet().length;

    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        header(
          'Welcome Back 👋',
          'Here is your dormitory overview and activity summary.',
        ),
        Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            statCard('Total Students', '${students.length}', Icons.people, purple),
            statCard('Total Rooms', '${rooms.length}', Icons.bed, blue),
            statCard('Occupied Rooms', '$occupiedCount', Icons.home, green),
            statCard('Available Rooms', '$availableCount', Icons.meeting_room, orange),
          ],
        ),
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.all(21),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Room Occupancy',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '$buildingCount buildings • One student per room',
                style: const TextStyle(color: muted),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: occupancyRate,
                  minHeight: 13,
                  backgroundColor: const Color(0xFF293650),
                  color: purple,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(occupancyRate * 100).toStringAsFixed(1)}% occupied',
                    style: const TextStyle(
                      color: purple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$availableCount rooms free',
                    style: const TextStyle(color: muted),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Students',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: onViewAllStudents,
              child: const Text('View all'),
            ),
          ],
        ),
        ...students.take(6).map(
              (s) => Container(
            margin: const EdgeInsets.only(bottom: 9),
            decoration: cardDecoration(),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFF293650),
                child: Icon(Icons.person, color: purple),
              ),
              title: Text(s.name),
              subtitle: Text('${s.id} • ${s.room}'),
            ),
          ),
        ),
      ],
    );
  }
}
