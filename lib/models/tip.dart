import 'package:flutter/material.dart';

class Tip {
  final String title;
  final String content;
  final IconData icon;

  const Tip({
    required this.title,
    required this.content,
    required this.icon,
  });
}

class TipSection {
  final String title;
  final String description;
  final List<Tip> tips;
  final Color color;

  const TipSection({
    required this.title,
    required this.description,
    required this.tips,
    required this.color,
  });
}

// Data Content
const sectionPosture = TipSection(
  title: 'Office Posture',
  description: 'Maintain a healthy spine and avoid back pain.',
  color: Colors.blueAccent,
  tips: [
    Tip(
      title: 'Monitor Height',
      content: 'The top of your screen should be at or slightly below eye level. You shouldn\'t need to tilt your head up or down.',
      icon: Icons.desktop_windows,
    ),
    Tip(
      title: 'Elbow Position',
      content: 'Keep your elbows at a 90-degree angle while typing. Your forearms should be parallel to the floor.',
      icon: Icons.accessibility_new,
    ),
    Tip(
      title: 'Chair Support',
      content: 'Sit back in your chair so your lower back is supported. Use a lumbar cushion if needed.',
      icon: Icons.chair,
    ),
    Tip(
      title: 'Flat Feet',
      content: 'Keep your feet flat on the floor. If they don\'t reach, use a footrest.',
      icon: Icons.format_align_justify,
    ),
  ],
);

const sectionEyeStrain = TipSection(
  title: 'Eye Strain Prevention',
  description: 'Protect your vision from digital fatigue.',
  color: Colors.teal,
  tips: [
    Tip(
      title: '20-20-20 Rule',
      content: 'Every 20 minutes, look at something 20 feet away for at least 20 seconds.',
      icon: Icons.visibility,
    ),
    Tip(
      title: 'Blink Often',
      content: 'We blink less when staring at screens. Make a conscious effort to blink to keep eyes moist.',
      icon: Icons.remove_red_eye,
    ),
    Tip(
      title: 'Adjust Brightness',
      content: 'Ensure your screen is not significantly brighter or darker than your surrounding room lighting.',
      icon: Icons.brightness_6,
    ),
    Tip(
      title: 'Reduce Glare',
      content: 'Position your screen to avoid reflections from windows or overhead lights.',
      icon: Icons.wb_sunny,
    )
  ],
);

const allTipSections = [
  sectionPosture,
  sectionEyeStrain,
];
