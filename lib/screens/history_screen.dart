import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/preferences_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = PreferencesService.instance.getHistory(); // ordered newest first

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: history.isEmpty
          ? const Center(
              child: Text(
                'No workouts completed yet.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final record = history[index];
                final dateStr = DateFormat.yMMMd().add_Hm().format(record.date);
                
                return ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(record.workoutTitle),
                  subtitle: Text(dateStr),
                  trailing: Text('+${record.xp} XP', style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
    );
  }
}
