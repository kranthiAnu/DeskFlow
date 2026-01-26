import 'package:flutter/material.dart';

class Workout {
  final String title;
  final int seconds;
  final int xp;
  final List<String> steps;
  final IconData? icon; // Added for UI enhancement

  const Workout({
    required this.title,
    required this.seconds,
    required this.xp,
    required this.steps,
    this.icon,
    this.color, // Added color property
  });

  final Color? color;

  Map<String, dynamic> toJson() => {
        'title': title,
        'seconds': seconds,
        'xp': xp,
        'steps': steps,
        'color': color?.value, // Store int value
      };

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      title: json['title'] as String,
      seconds: json['seconds'] as int,
      xp: json['xp'] as int,
      steps: List<String>.from(json['steps']),
      icon: Icons.star, // Default icon for loaded custom workouts
      color: json['color'] != null ? Color(json['color']) : null,
    );
  }
}

const workoutNeckShoulder = Workout(
  title: 'Neck + Shoulder Reset',
  seconds: 120,
  xp: 20,
  steps: [
    'Neck circles (slow) x 20 sec',
    'Shoulder rolls x 20 sec',
    'Chin tucks x 8',
    'Deep breaths x 5',
  ],
  icon: Icons.person_outline,
  color: Colors.orange,
);

const workoutLegsGlutes = Workout(
  title: 'Desk Legs + Glutes',
  seconds: 180,
  xp: 30,
  steps: [
    'Seated knee lifts x 20',
    'Calf raises (standing) x 20',
    'Bodyweight squats x 10',
    'Short walk 30-60 sec',
  ],
  icon: Icons.directions_walk,
  color: Colors.purple,
);

const workoutEyesPosture = Workout(
  title: 'Eyes + Posture Break',
  seconds: 90,
  xp: 15,
  steps: [
    '20-20-20 rule: look 20 ft for 20 sec',
    'Stand up & reach overhead',
    'Scapular squeeze x 10',
  ],
  icon: Icons.visibility,
  color: Colors.green,
);

const allWorkouts = <Workout>[
  workoutNeckShoulder,
  workoutLegsGlutes,
  workoutEyesPosture,
];
