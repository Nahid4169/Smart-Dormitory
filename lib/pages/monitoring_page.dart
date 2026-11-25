import 'package:flutter/material.dart';
import '../theme.dart';

class MonitoringPage extends StatelessWidget {
  const MonitoringPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        header('Dormitory Monitoring', 'Demonstration building sensor dashboard.'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            sensorCard(
              'Temperature',
              '24°C',
              Icons.thermostat,
              orange,
              'Normal',
            ),
            sensorCard(
              'Humidity',
              '55%',
              Icons.water_drop,
              blue,
              'Normal',
            ),
            sensorCard(
              'Air Quality',
              'Good',
              Icons.air,
              green,
              'Healthy',
            ),
            sensorCard(
              'Connectivity',
              'Online',
              Icons.wifi,
              purple,
              'Demo mode',
            ),
            sensorCard(
              'Gas Leak Detector',
              '0.0 ppm',
              Icons.warning_amber_rounded,
              green,
              'No Leak Detected',
            ),
            sensorCard(
              'Fire Alarm System',
              'Standby',
              Icons.local_fire_department_rounded,
              green,
              'System Armed',
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: cardDecoration(),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Building Environment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 14),
              Text(
                'The displayed readings are sample values for demonstration. '
                    'Live monitoring requires physical sensors, a controller, '
                    'and a connected IoT service.',
                style: TextStyle(color: muted, height: 1.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget sensorCard(
      String title,
      String value,
      IconData icon,
      Color color,
      String status,
      ) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(18),
      decoration: cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: muted)),
          const SizedBox(height: 10),
          Text(
            status,
            style: TextStyle(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
