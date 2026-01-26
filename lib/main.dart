import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'services/preferences_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const FitWhileWorkApp());
}

class FitWhileWorkApp extends StatelessWidget {
  const FitWhileWorkApp({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: PreferencesService.instance.themeColor,
      builder: (context, colorKey, _) {
        MaterialColor seedColor;
        List<Color> gradientColors;

        switch (colorKey) {
          case 'red':
            seedColor = Colors.red;
            gradientColors = [const Color(0xFFFFEBEE), const Color(0xFFFFCDD2)];
            break;
          case 'orange':
            seedColor = Colors.orange;
            gradientColors = [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)];
            break;
          case 'amber':
            seedColor = Colors.amber;
            gradientColors = [const Color(0xFFFFF8E1), const Color(0xFFFFECB3)];
            break;
          case 'green':
            seedColor = Colors.green;
            gradientColors = [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)];
            break;
          case 'teal':
            seedColor = Colors.teal;
            gradientColors = [const Color(0xFFE0F2F1), const Color(0xFFB2DFDB)];
            break;
          case 'cyan':
            seedColor = Colors.cyan;
            gradientColors = [const Color(0xFFE0F7FA), const Color(0xFFB2EBF2)];
            break;
          case 'indigo':
            seedColor = Colors.indigo;
            gradientColors = [const Color(0xFFE8EAF6), const Color(0xFFC5CAE9)];
            break;
          case 'purple':
            seedColor = Colors.purple;
            gradientColors = [const Color(0xFFF3E5F5), const Color(0xFFE1BEE7)];
            break;
          case 'pink':
            seedColor = Colors.pink;
            gradientColors = [const Color(0xFFFCE4EC), const Color(0xFFF8BBD0)];
            break;
          case 'blue':
          default:
            seedColor = Colors.blue;
            gradientColors = [const Color(0xFFE3F2FD), Colors.white]; // "Gorgeous" default
            break;
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DeskFlow',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: seedColor,
            scaffoldBackgroundColor:
                Colors.transparent, // Allow gradient from Container to show
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
          ),
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
              ),
              child: child,
            );
          },
          home: const HomeScreen(),
        );
      },
    );
  }
}