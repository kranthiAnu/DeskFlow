import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/preferences_service.dart';
import '../services/notification_service.dart';
import 'workout_screen.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import 'create_workout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Local state for UI
  Duration nextBreak = const Duration(minutes: 45);
  Timer? breakTimer;
  int currentWorkoutIndex = 0;
  List<Workout> mixedWorkouts = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }
  
  Future<void> _initData() async {
    await PreferencesService.instance.init();
    
    // Load custom workouts and mix
    final customs = PreferencesService.instance.getCustomWorkouts();
    setState(() {
      mixedWorkouts = [...allWorkouts, ...customs];
    });
    
    // Load timer duration from settings
    final mins = PreferencesService.instance.timerDurationMinutes;
    setState(() {
      nextBreak = Duration(minutes: mins);
      currentWorkoutIndex = PreferencesService.instance.workoutIndex;
    });

    // Validating index range just in case
    if (currentWorkoutIndex >= mixedWorkouts.length) {
       currentWorkoutIndex = 0;
    }

    // Schedule notification
    NotificationService.instance.scheduleBreakIn(nextBreak);

    // Start ticker
    breakTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (nextBreak.inSeconds <= 1) {
           // Reset timer based on current settings
           final mins = PreferencesService.instance.timerDurationMinutes;
           nextBreak = Duration(minutes: mins);
           // Schedule next
           NotificationService.instance.scheduleBreakIn(nextBreak);
        } else {
              nextBreak -= const Duration(seconds: 1);
        }
      });
    });
  }

  void _reloadWorkouts() {
    final customs = PreferencesService.instance.getCustomWorkouts();
    setState(() {
      mixedWorkouts = [...allWorkouts, ...customs];
      // If index out of range after update?
      if (currentWorkoutIndex >= mixedWorkouts.length) {
        currentWorkoutIndex = 0;
      }
    });
  }

  @override
  void dispose() {
    breakTimer?.cancel();
    super.dispose();
  }

  String _mmss(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _pickRandomWorkout() {
    final random = Random();
    int newIndex = currentWorkoutIndex;

    if (mixedWorkouts.length > 1) {
      while (newIndex == currentWorkoutIndex) {
        newIndex = random.nextInt(mixedWorkouts.length);
      }
    }

    setState(() {
      currentWorkoutIndex = newIndex;
    });
    PreferencesService.instance.setWorkoutIndex(newIndex);
  }

  @override
  Widget build(BuildContext context) {
    // Get latest data from service (rebuilds when setState called)
    final streak = PreferencesService.instance.streakDays;
    final xp = PreferencesService.instance.xp;
    final breaksToday = PreferencesService.instance.breaksToday;
    
    final w = mixedWorkouts.isEmpty ? allWorkouts[0] : mixedWorkouts[currentWorkoutIndex];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()));
          if (res == true) {
            _reloadWorkouts();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Custom workout added!')));
          }
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('DeskFlow'),
        actions: [
          IconButton(
            tooltip: 'History',
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              // When coming back, maybe timer duration changed, but we won't interrupt the current countdown
              // until it resets or user manually resets, to be non-intrusive.
              // But we can trigger a UI rebuild just in case.
              setState(() {});
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              elevation: 2,
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Today',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('🔥 Streak: $streak days'),
                          Text('⭐ XP: $xp'),
                          Text('🎯 Goal: $breaksToday / 3 breaks'),
                          const SizedBox(height: 8),
                          Text(
                            'Next break in: ${_mmss(nextBreak)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.fitness_center, size: 42),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Suggested workout',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  tooltip: 'Shuffle workout',
                  onPressed: _pickRandomWorkout,
                  icon: const Icon(Icons.shuffle),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              color: Colors.white.withOpacity(0.9),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (w.icon != null) ...[
                          Icon(w.icon, size: 28, color: w.color ?? Colors.blue),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          w.title,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('${(w.seconds / 60).round()} min • +${w.xp} XP'),
                    const SizedBox(height: 10),
                    ...w.steps.map(
                      (s) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $s'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () async {
                final earnedXp = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(builder: (_) => WorkoutScreen(workout: w)),
                );

                if (earnedXp != null) {
                  await PreferencesService.instance.completeWorkout(title: w.title, earnedXp: earnedXp);
                  
                  // Reset timer logic after completion
                  final mins = PreferencesService.instance.timerDurationMinutes;
                  setState(() {
                    nextBreak = Duration(minutes: mins);
                    _pickRandomWorkout();
                  });
                  NotificationService.instance.scheduleBreakIn(nextBreak);
                }
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Break Now'),
            ),
          ],
        ),
      ),
    );
  }
}
