import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/dorm_models.dart';

class MaintenancePage extends StatelessWidget {
  final List<MaintenanceRequest> requests;
  final VoidCallback onAddRequest;
  final void Function(MaintenanceRequest request, String status) onUpdateStatus;

  const MaintenancePage({
    super.key,
    required this.requests,
    required this.onAddRequest,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        header('Maintenance Management', 'Manage dormitory repair requests.'),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: purple),
            onPressed: onAddRequest,
            icon: const Icon(Icons.add),
            label: const Text('New Request'),
          ),
        ),
        const SizedBox(height: 15),
        ...requests.map((r) {
          final color = r.status == 'Completed'
              ? green
              : r.status == 'In Progress'
              ? blue
              : orange;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: cardDecoration(),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withOpacity(0.14),
                child: Icon(Icons.build, color: color),
              ),
              title: Text(r.issue),
              subtitle: Text('Room ${r.room} • ${r.status}'),
              trailing: PopupMenuButton<String>(
                onSelected: (v) => onUpdateStatus(r, v),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'Pending', child: Text('Pending')),
                  PopupMenuItem(value: 'In Progress', child: Text('In Progress')),
                  PopupMenuItem(value: 'Completed', child: Text('Completed')),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
