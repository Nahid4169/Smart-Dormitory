import 'package:flutter/material.dart';

const Color bg = Color(0xFF0B1020);
const Color panel = Color(0xFF151D30);
const Color panel2 = Color(0xFF1D2941);
const Color purple = Color(0xFF8B7CFF);
const Color blue = Color(0xFF55B8FF);
const Color green = Color(0xFF45D6A0);
const Color orange = Color(0xFFFFB45C);
const Color red = Color(0xFFFF6B78);
const Color muted = Color(0xFF9AA6BD);

ThemeData buildDormTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(
      seedColor: purple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF10182A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFF303B58)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFF303B58)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: purple, width: 1.5),
      ),
    ),
  );
}

BoxDecoration cardDecoration() {
  return BoxDecoration(
    color: panel,
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: const Color(0xFF293650)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.10),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );
}

Widget statCard(String title, String value, IconData icon, Color color) {
  return Container(
    width: 175,
    padding: const EdgeInsets.all(17),
    decoration: cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withOpacity(0.13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 25),
        ),
        const SizedBox(height: 15),
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(color: muted, fontSize: 11),
        ),
      ],
    ),
  );
}

Widget header(String title, String subtitle) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 22),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: const TextStyle(color: muted, fontSize: 12),
        ),
      ],
    ),
  );
}

Widget input(TextEditingController controller, String label) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
    ),
  );
}
