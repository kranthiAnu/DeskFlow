import 'package:flutter/material.dart';
import '../models/tip.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wellness Tips'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: allTipSections.length,
        itemBuilder: (context, index) {
          final section = allTipSections[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 20),
            clipBehavior: Clip.antiAlias,
            elevation: 3,
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                initiallyExpanded: index == 0,
                backgroundColor: Colors.white.withOpacity(0.95),
                collapsedBackgroundColor: Colors.white.withOpacity(0.9),
                leading: CircleAvatar(
                  backgroundColor: section.color.withOpacity(0.2),
                  child: Icon(section.tips.first.icon, color: section.color),
                ),
                title: Text(
                  section.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                subtitle: Text(section.description),
                children: [
                   ...section.tips.map((tip) => ListTile(
                     leading: Icon(Icons.check_circle_outline, size: 20, color: section.color),
                     title: Text(tip.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                     subtitle: Text(tip.content),
                     contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                   )).toList(),
                   const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
