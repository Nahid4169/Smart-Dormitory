import 'package:flutter/material.dart';
import '../theme.dart';

class SafetySensorsPage extends StatefulWidget {
  const SafetySensorsPage({super.key});

  @override
  State<SafetySensorsPage> createState() => _SafetySensorsPageState();
}

class _SafetySensorsPageState extends State<SafetySensorsPage> {
  bool gasValveOpen = true;
  bool fireAlarmArmed = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        header('Safety & Sensors', 'Real-time dormitory safety, gas leak, and fire alarm monitoring.'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            sensorCard(
              'Gas Leak Detector',
              '0.0 ppm',
              Icons.warning_amber_rounded,
              green,
              'Secure • No Leak',
            ),
            sensorCard(
              'Fire Alarm System',
              fireAlarmArmed ? 'Armed & Ready' : 'Disarmed',
              Icons.local_fire_department_rounded,
              fireAlarmArmed ? green : red,
              fireAlarmArmed ? 'Protected' : 'Warning: Inactive',
            ),
            sensorCard(
              'Smoke Density',
              '0.02 dB/m',
              Icons.smoke_free_rounded,
              blue,
              'Normal Levels',
            ),
            sensorCard(
              'Automatic Gas Valve',
              gasValveOpen ? 'OPEN (Safe)' : 'CLOSED (Shut)',
              Icons.security_rounded,
              gasValveOpen ? green : orange,
              gasValveOpen ? 'Normal Operation' : 'Emergency Shut-off',
            ),
          ],
        ),
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Emergency Safety Controls',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 14),
              const Text(
                'Control building safety infrastructure, test emergency alarms, or trigger remote safety shutdowns.',
                style: TextStyle(color: muted, height: 1.5),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: fireAlarmArmed ? red : green,
                    ),
                    onPressed: () {
                      setState(() {
                        fireAlarmArmed = !fireAlarmArmed;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            fireAlarmArmed
                                ? 'Fire Alarm System Armed.'
                                : 'Fire Alarm System Disarmed.',
                          ),
                        ),
                      );
                    },
                    icon: Icon(fireAlarmArmed ? Icons.alarm_off : Icons.alarm),
                    label: Text(fireAlarmArmed ? 'Disarm Fire Alarm' : 'Arm Fire Alarm'),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: gasValveOpen ? orange : green,
                    ),
                    onPressed: () {
                      setState(() {
                        gasValveOpen = !gasValveOpen;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            gasValveOpen
                                ? 'Main Gas Valve Opened.'
                                : 'Emergency Gas Valve Shut Off!',
                          ),
                        ),
                      );
                    },
                    icon: Icon(gasValveOpen ? Icons.lock : Icons.lock_open),
                    label: Text(gasValveOpen ? 'Shut Off Gas Valve' : 'Open Gas Valve'),
                  ),
                ],
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
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(title, style: const TextStyle(color: muted, fontSize: 13)),
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
