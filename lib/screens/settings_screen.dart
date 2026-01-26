import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _minutes = 45;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    setState(() {
      _minutes = PreferencesService.instance.timerDurationMinutes;
    });
  }

  Future<void> _updateTimer(int newMinutes) async {
    await PreferencesService.instance.setTimerDurationMinutes(newMinutes);
    setState(() => _minutes = newMinutes);
    
    // Reschedule notification based on new preference? 
    // Ideally we just update the preference. Variable timer logic in HomeScreen will pick it up on next reset.
    // However, if the user changes it, they might expect immediate effect.
    // For simplicity, we'll let it apply on the next cycle, or the user can "Reset" from home.
    
    // But let's be nice and show a snackbar.
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Timer set to $newMinutes minutes (applies to next break)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Break Frequency'),
            subtitle: Text('Remind me to move every $_minutes minutes'),
            leading: const Icon(Icons.timer),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 10,
              children: [20, 30, 45, 60, 90].map((m) {
                return ChoiceChip(
                  label: Text('$m min'),
                  selected: _minutes == m,
                  onSelected: (selected) {
                    if (selected) _updateTimer(m);
                  },
                );
              }).toList(),
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text('App Theme'),
            leading: Icon(Icons.palette),
          ),
          Padding(
             padding: const EdgeInsets.symmetric(horizontal: 16),
             child: ValueListenableBuilder<String>(
               valueListenable: PreferencesService.instance.themeColor,
               builder: (context, currentTheme, _) {
                 return Wrap(
                   spacing: 8,
                   runSpacing: 8,
                   children: [
                     _ThemeChip('Blue', 'blue', Colors.blue, currentTheme),
                     _ThemeChip('Red', 'red', Colors.red, currentTheme),
                     _ThemeChip('Orange', 'orange', Colors.orange, currentTheme),
                     _ThemeChip('Amber', 'amber', Colors.amber, currentTheme),
                     _ThemeChip('Green', 'green', Colors.green, currentTheme),
                     _ThemeChip('Teal', 'teal', Colors.teal, currentTheme),
                     _ThemeChip('Cyan', 'cyan', Colors.cyan, currentTheme),
                     _ThemeChip('Indigo', 'indigo', Colors.indigo, currentTheme),
                     _ThemeChip('Purple', 'purple', Colors.purple, currentTheme),
                     _ThemeChip('Pink', 'pink', Colors.pink, currentTheme),
                   ],
                 );
               },
             ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications_active),
            title: const Text('Test Notification'),
            subtitle: const Text('Send a break reminder now'),
            onTap: () {
              NotificationService.instance.showNow();
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String currentSelection;

  const _ThemeChip(this.label, this.value, this.color, this.currentSelection);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == currentSelection;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: color.withOpacity(0.3),
      checkmarkColor: color, 
      labelStyle: TextStyle(
          color: isSelected ? color : Colors.black, 
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
      onSelected: (selected) {
        if (selected) {
           PreferencesService.instance.setThemeColor(value);
        }
      },
    );
  }
}
