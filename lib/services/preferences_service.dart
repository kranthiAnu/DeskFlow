import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart'; // for ValueNotifier
import '../models/workout.dart';

class WorkoutRecord {
  final DateTime date;
  final String workoutTitle;
  final int xp;

  WorkoutRecord({
    required this.date,
    required this.workoutTitle,
    required this.xp,
  });

  Map<String, dynamic> toJson() => {
        'date': date.toIso8601String(),
        'workoutTitle': workoutTitle,
        'xp': xp,
      };

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) {
    return WorkoutRecord(
      date: DateTime.parse(json['date']),
      workoutTitle: json['workoutTitle'],
      xp: json['xp'],
    );
  }
}

class PreferencesService {
  PreferencesService._();
  static final PreferencesService instance = PreferencesService._();

  late SharedPreferences _prefs;

  // Keys
  static const _kXp = 'xp';
  static const _kStreakDays = 'streakDays';
  static const _kWorkoutIndex = 'workoutIndex';
  static const _kLastCompletedDay = 'lastCompletedDay';
  static const _kBreaksToday = 'breaksToday';
  static const _kBreaksDay = 'breaksDay';
  static const _kHistory = 'workout_history';
  static const _kTimerDuration = 'timer_duration_minutes';
  static const _kAppTheme = 'app_theme';

  // State
  final ValueNotifier<String> themeColor = ValueNotifier('blue');

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    themeColor.value = _prefs.getString(_kAppTheme) ?? 'blue';
  }

  // --- Stats ---
  int get xp => _prefs.getInt(_kXp) ?? 0;
  int get streakDays => _prefs.getInt(_kStreakDays) ?? 0;
  int get workoutIndex => _prefs.getInt(_kWorkoutIndex) ?? 0;
  int get breaksToday {
    final savedDay = _prefs.getString(_kBreaksDay) ?? '';
    final dayOnly = DateTime.now().toIso8601String().split('T').first;
    // Simple check: if stored "breaksDay" (IsoString) starts with today's date YYYY-MM-DD
    if (savedDay.startsWith(dayOnly)) {
      return _prefs.getInt(_kBreaksToday) ?? 0;
    }
    return 0;
  }
  
  DateTime? get lastCompletedDay {
    final s = _prefs.getString(_kLastCompletedDay);
    if (s == null || s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  Future<void> setWorkoutIndex(int index) => _prefs.setInt(_kWorkoutIndex, index);

  // --- Settings ---
  int get timerDurationMinutes => _prefs.getInt(_kTimerDuration) ?? 45;
  Future<void> setTimerDurationMinutes(int minutes) => _prefs.setInt(_kTimerDuration, minutes);

  Future<void> setThemeColor(String colorKey) async {
    await _prefs.setString(_kAppTheme, colorKey);
    themeColor.value = colorKey;
  }

  // --- Logic for completing a workout ---
  Future<void> completeWorkout({required String title, required int earnedXp}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // 1. Update XP
    int currentXp = xp;
    await _prefs.setInt(_kXp, currentXp + earnedXp);

    // 2. Update Streak
    final last = lastCompletedDay == null ? null : DateTime(lastCompletedDay!.year, lastCompletedDay!.month, lastCompletedDay!.day);
    final yesterday = today.subtract(const Duration(days: 1));

    int currentStreak = streakDays;
    if (last == null) {
      currentStreak = 1;
    } else if (last == today) {
      // same day, streak unchanged
    } else if (last == yesterday) {
      currentStreak += 1;
    } else {
      currentStreak = 1;
    }
    await _prefs.setInt(_kStreakDays, currentStreak);
    await _prefs.setString(_kLastCompletedDay, now.toIso8601String());

    // 3. Update Daily Goal
    // 3. Update Daily Goal 
    // We already checked date in getter, but for setting we force update
    // If we haven't updated breaksToday for today yet, it would be 0 from getter logic but we need to verify write
    // Actually, simpler: read raw, check date, if match increment, else set 1.
    final savedBreaksDayStr = _prefs.getString(_kBreaksDay) ?? '';
    // Let's use clean "YYYY-MM-DD" comparison for safety or just store full object
    // Let's use clean "YYYY-MM-DD" comparison for safety or just store full object
    
    int newBreaksToday = 1;
    // Check if the stored day is today (ignoring time if we stored full iso, but we want day precision)
    // The previous code stored full Iso8601.
    if (savedBreaksDayStr.isNotEmpty) {
       final savedDate = DateTime.tryParse(savedBreaksDayStr);
       if (savedDate != null && DateTime(savedDate.year, savedDate.month, savedDate.day) == today) {
         newBreaksToday = (_prefs.getInt(_kBreaksToday) ?? 0) + 1;
       }
    }
    
    await _prefs.setInt(_kBreaksToday, newBreaksToday.clamp(0, 3));
    await _prefs.setString(_kBreaksDay, now.toIso8601String());

    // 4. Add to History
    final record = WorkoutRecord(date: now, workoutTitle: title, xp: earnedXp);
    final historyJsonList = _prefs.getStringList(_kHistory) ?? [];
    historyJsonList.add(jsonEncode(record.toJson()));
    await _prefs.setStringList(_kHistory, historyJsonList);
  }

  List<WorkoutRecord> getHistory() {
    final list = _prefs.getStringList(_kHistory) ?? [];
    return list.map((e) => WorkoutRecord.fromJson(jsonDecode(e))).toList().reversed.toList();
  }

  // --- Custom Workouts ---
  static const _kCustomWorkouts = 'custom_workouts';

  Future<void> saveCustomWorkout(Workout workout) async {
    final list = _prefs.getStringList(_kCustomWorkouts) ?? [];
    list.add(jsonEncode(workout.toJson()));
    await _prefs.setStringList(_kCustomWorkouts, list);
  }

  List<Workout> getCustomWorkouts() {
    final list = _prefs.getStringList(_kCustomWorkouts) ?? [];
    return list.map((e) => Workout.fromJson(jsonDecode(e))).toList();
  }
}
