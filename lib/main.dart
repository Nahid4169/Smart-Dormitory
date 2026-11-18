import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DormitoryApp());
}

class DormitoryApp extends StatelessWidget {
  const DormitoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Dormitory',
      debugShowCheckedModeBanner: false,
      theme: buildDormTheme(),
      home: const AuthGate(),
    );
  }
}
