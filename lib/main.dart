import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isNight = prefs.getBool('isNight') ?? false;
  runApp(DreamCatcherApp(isNightMode: isNight));
}

class DreamCatcherApp extends StatefulWidget {
  final bool isNightMode;
  const DreamCatcherApp({super.key, required this.isNightMode});

  @override
  State<DreamCatcherApp> createState() => _DreamCatcherAppState();
}

class _DreamCatcherAppState extends State<DreamCatcherApp> {
  late bool isNight;

  @override
  void initState() {
    super.initState();
    isNight = widget.isNightMode;
  }

  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isNight = !isNight;
    });
    await prefs.setBool('isNight', isNight);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isNight ? Brightness.dark : Brightness.light,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: isNight
            ? ColorScheme.dark(
                primary: Colors.indigoAccent,
                secondary: Colors.purpleAccent,
              )
            : ColorScheme.light(
                primary: Colors.blue,
                secondary: Colors.pinkAccent,
              ),
        useMaterial3: true,
      ),
      home: HomeScreen(isNight: isNight, onToggleTheme: toggleTheme),
    );
  }
}
