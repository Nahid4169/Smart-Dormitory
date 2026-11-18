import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/dorm_models.dart';

class RoomsPage extends StatelessWidget {
  final List<DormRoom> rooms;
  final List<Student> students;
  final String roomSearch;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddRoom;
  final ValueChanged<DormRoom> onDeleteRoom;
  final bool Function(String roomId) isOccupied;
  final int occupiedCount;
  final int availableCount;

  const RoomsPage({
    super.key,
    required this.rooms,
    required this.students,
    required this.roomSearch,
    required this.onSearchChanged,
    required this.onAddRoom,
    required this.onDeleteRoom,
    required this.isOccupied,
    required this.occupiedCount,
    required this.availableCount,
  });

  @override
  Widget build(BuildContext context) {
    final buildings = rooms.map((r) => r.building).toSet().toList()..sort();

    final filteredRooms = rooms.where((r) {
      final q = roomSearch.toLowerCase();
      return r.id.toLowerCase().contains(q);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        header('Room Management', '220 rooms • 10 buildings • Capacity: 1 student'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            statCard('Total Rooms', '${rooms.length}', Icons.bed, blue),
            statCard('Occupied', '$occupiedCount', Icons.person, green),
            statCard('Available', '$availableCount', Icons.meeting_room, orange),
          ],
        ),
        const SizedBox(height: 18),
        TextField(
          onChanged: onSearchChanged,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search building or room number',
          ),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: purple),
            onPressed: onAddRoom,
            icon: const Icon(Icons.add),
            label: const Text('Add Room'),
          ),
        ),
        const SizedBox(height: 12),
        ...buildings.map((building) {
          final buildingRooms = filteredRooms
              .where((r) => r.building == building)
              .toList();

          if (buildingRooms.isEmpty) return const SizedBox.shrink();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 18, bottom: 10),
                child: Text(
                  'Building $building  •  ${rooms.where((r) => r.building == building).length} rooms',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: purple,
                  ),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 270,
                  mainAxisExtent: 115,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: buildingRooms.length,
                itemBuilder: (context, i) {
                  final room = buildingRooms[i];
                  final occupied = isOccupied(room.id);
                  final student = students.where((s) => s.room == room.id);

                  return Container(
                    padding: const EdgeInsets.all(13),
                    decoration: cardDecoration(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bed,
                              color: occupied ? green : blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                room.id,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              onSelected: (v) {
                                if (v == 'delete') onDeleteRoom(room);
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete Room'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          occupied
                              ? student.first.name
                              : 'Available',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: occupied ? green : orange,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Capacity: 1',
                          style: const TextStyle(color: muted, fontSize: 10),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        }),
      ],
    );
  }
}
