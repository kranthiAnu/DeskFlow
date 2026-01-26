import 'dart:async';
import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutScreen extends StatefulWidget {
  final Workout workout;
  const WorkoutScreen({super.key, required this.workout});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  Timer? timer;
  late int remaining;
  bool started = false;

  @override
  void initState() {
    super.initState();
    remaining = widget.workout.seconds;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String _mmss(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _start() {
    if (started) return;
    setState(() => started = true);

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (remaining <= 1) {
          remaining = 0;
          timer?.cancel();
        } else {
          remaining -= 1;
        }
      });
    });
  }

  void _reset() {
    timer?.cancel();
    setState(() {
      started = false;
      remaining = widget.workout.seconds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.workout.seconds;
    final progress = total == 0 ? 0.0 : (total - remaining) / total;

    return Scaffold(
      appBar: AppBar(title: Text(widget.workout.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      _mmss(remaining),
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(value: progress),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton(
                            onPressed: started ? null : _start,
                            child: const Text('Start'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _reset,
                            child: const Text('Reset'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Steps',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...widget.workout.steps.map(
              (s) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(s),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed:
                  remaining == 0 ? () => Navigator.pop<int>(context, widget.workout.xp) : null,
              icon: const Icon(Icons.check_circle),
              label: Text('Complete (+${widget.workout.xp} XP)'),
            ),
          ],
        ),
      ),
    );
  }
}
