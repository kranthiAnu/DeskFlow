import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/preferences_service.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _durationController = TextEditingController(text: '2');
  final _stepController = TextEditingController();
  
  final List<String> _steps = [];
  Color _selectedColor = Colors.blue;

  final List<(Color, String)> _colors = [
    (Colors.blue, 'Blue'),
    (Colors.red, 'Red'),
    (Colors.orange, 'Orange'),
    (Colors.amber, 'Amber'),
    (Colors.green, 'Green'),
    (Colors.teal, 'Teal'),
    (Colors.cyan, 'Cyan'),
    (Colors.indigo, 'Indigo'),
    (Colors.purple, 'Purple'),
    (Colors.pink, 'Pink'),
  ];

  void _addStep() {
    if (_stepController.text.trim().isNotEmpty) {
      setState(() {
        _steps.add(_stepController.text.trim());
        _stepController.clear();
      });
    }
  }

  void _removeStep(int index) {
    setState(() {
      _steps.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate() && _steps.isNotEmpty) {
      final minutes = double.tryParse(_durationController.text) ?? 2.0;
      final seconds = (minutes * 60).round();
      // Simple XP calculation: 10 XP per minute
      final xp = minutes.ceil() * 10;

      final workout = Workout(
        title: _titleController.text.trim(),
        seconds: seconds,
        xp: xp,
        steps: List.from(_steps),
        // Use a generic icon for custom workouts or let user pick (future)
        icon: Icons.star_border,
        color: _selectedColor,
      );

      await PreferencesService.instance.saveCustomWorkout(workout);

      if (!mounted) return;
      Navigator.pop(context, true); // Return true to indicate saved
    } else if (_steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one step')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Workout')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: 'Duration (minutes)', border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) {
                 final n = double.tryParse(v ?? '');
                 return (n == null || n <= 0) ? 'Valid minutes required' : null;
              },
            ),
            const SizedBox(height: 16),
            const Text('Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _colors.map((pair) {
                final color = pair.$1;
                final name = pair.$2;
                final isSelected = _selectedColor == color;
                return ChoiceChip(
                  label: Text(name),
                  selected: isSelected,
                  selectedColor: color.withOpacity(0.3),
                  checkmarkColor: color,
                  labelStyle: TextStyle(
                      color: isSelected ? color : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedColor = color);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Steps', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _stepController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Stretch arms',
                      isDense: true,
                    ),
                    onSubmitted: (_) => _addStep(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.add), onPressed: _addStep),
              ],
            ),
            if (_steps.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                     for (int i = 0; i < _steps.length; i++)
                       ListTile(
                         dense: true,
                         title: Text('${i + 1}. ${_steps[i]}'),
                         trailing: IconButton(
                           icon: const Icon(Icons.close, size: 18),
                           onPressed: () => _removeStep(i),
                         ),
                       ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save Custom Workout'),
            ),
          ],
        ),
      ),
    );
  }
}
