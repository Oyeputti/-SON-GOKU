import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int kAlarmId4AM = 400;
const int kAlarmId630AM = 630;
final AudioPlayer _globalAlarmPlayer = AudioPlayer();

@pragma('vm:entry-point')
Future<void> trigger4AMWakeUpCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _ringGokuAlarmTone();
  await SaiyanAlarmScheduler.scheduleDailyAlarms();
}

@pragma('vm:entry-point')
Future<void> trigger630AMWarningCallback() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _ringGokuAlarmTone();
}

Future<void> _ringGokuAlarmTone() async {
  final AudioContext alarmContext = AudioContext(
    android: const AudioContextAndroid(
      isSpeakerphoneOn: true,
      stayAwake: true,
      contentType: AndroidContentType.sonification,
      usageType: AndroidUsageType.alarm,
      audioFocus: AndroidAudioFocus.gainTransientExclusive,
    ),
  );
  await _globalAlarmPlayer.setAudioContext(alarmContext);
  await _globalAlarmPlayer.setReleaseMode(ReleaseMode.loop);
  await _globalAlarmPlayer.setVolume(1.0);
  await _globalAlarmPlayer.play(
    UrlSource('https://actions.google.com/sounds/v1/alarms/digital_watch_alarm_long.ogg'),
  );
}

class SaiyanAlarmScheduler {
  static Future<void> initAndSchedule() async {
    if (!Platform.isAndroid) return;
    await AndroidAlarmManager.initialize();
    if (await Permission.scheduleExactAlarm.isDenied) {
      await Permission.scheduleExactAlarm.request();
    }
    await scheduleDailyAlarms();
  }

  static Future<void> scheduleDailyAlarms() async {
    if (!Platform.isAndroid) return;
    final now = DateTime.now();
    DateTime next4AM = DateTime(now.year, now.month, now.day, 4, 0, 0);
    if (now.isAfter(next4AM)) next4AM = next4AM.add(const Duration(days: 1));

    DateTime next630AM = DateTime(now.year, now.month, now.day, 6, 30, 0);
    if (now.isAfter(next630AM)) next630AM = next630AM.add(const Duration(days: 1));

    await AndroidAlarmManager.oneShotAt(
      next4AM,
      kAlarmId4AM,
      trigger4AMWakeUpCallback,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      alarmClock: true,
      rescheduleOnReboot: true,
    );

    await AndroidAlarmManager.oneShotAt(
      next630AM,
      kAlarmId630AM,
      trigger630AMWarningCallback,
      exact: true,
      wakeup: true,
      allowWhileIdle: true,
      alarmClock: true,
      rescheduleOnReboot: true,
    );
  }

  static Future<void> testAlarmIn5Sec() async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.oneShot(
        const Duration(seconds: 5),
        999,
        trigger4AMWakeUpCallback,
        exact: true,
        wakeup: true,
        allowWhileIdle: true,
      );
    }
  }

  static Future<void> stopAlarm() async {
    await _globalAlarmPlayer.stop();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SaiyanAlarmScheduler.initAndSchedule();
  runApp(const SaiyanGlassWorkoutApp());
}

class SaiyanGlassWorkoutApp extends StatelessWidget {
  const SaiyanGlassWorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saiyan Protocol',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF04060B),
        primaryColor: const Color(0xFFFF6B00),
      ),
      home: const MainGlassDashboard(),
    );
  }
}

class Exercise {
  final String code;
  final String name;
  final String category;
  final int sets;
  final String targetReps;
  final int restSeconds;
  final String muscleWorked;
  final String gokuQuote;
  final String animeReference;
  bool isCompleted;
  int completedSets;

  Exercise({
    required this.code,
    required this.name,
    required this.category,
    required this.sets,
    required this.targetReps,
    required this.restSeconds,
    required this.muscleWorked,
    required this.gokuQuote,
    required this.animeReference,
    this.isCompleted = false,
    this.completedSets = 0,
  });
}

class WorkoutDay {
  final int dayNumber;
  final String title;
  final String focus;
  final List<Exercise> exercises;

  WorkoutDay({
    required this.dayNumber,
    required this.title,
    required this.focus,
    required this.exercises,
  });
}

final List<WorkoutDay> saiyanProtocolDays = [
  WorkoutDay(
    dayNumber: 1,
    title: "Day 1: Upper Body (Width & Stretch) + Lower Abs",
    focus: "Expanding lats, capping side delts, stretching arm fascia.",
    exercises: [
      Exercise(
        code: "1A",
        name: "Weighted Pull-Ups (or Lat Pulldowns)",
        category: "Back (Width)",
        sets: 4,
        targetReps: "6-8",
        restSeconds: 0,
        muscleWorked: "Upper Lats & Teres Major (V-Taper Width)",
        gokuQuote: "Come on, let's go! Pull your chest to the bar—spread those Saiyan lats!",
        animeReference: "Goku 100x Gravity Pull-Ups (DBZ)",
      ),
      Exercise(
        code: "1B",
        name: "Straight-Arm Cable Pulldowns",
        category: "Back (Width)",
        sets: 4,
        targetReps: "Failure",
        restSeconds: 120,
        muscleWorked: "Lower Lats & Serratus Anterior",
        gokuQuote: "Zero rest! Sweep down till your lats cramp up!",
        animeReference: "Goku Kaioken Aura Sweep (DBZ)",
      ),
      Exercise(
        code: "2A",
        name: "Incline Dumbbell Curls (45°)",
        category: "Biceps (Stretch & Width)",
        sets: 4,
        targetReps: "6-8",
        restSeconds: 0,
        muscleWorked: "Long Head Biceps Fascia",
        gokuQuote: "Keep your elbows pinned back! Let the weight stretch the bicep fascia!",
        animeReference: "Goku Weighted Arm Curls (DBZ)",
      ),
      Exercise(
        code: "2B",
        name: "Cross-Body Hammer Curls",
        category: "Biceps (Stretch & Width)",
        sets: 4,
        targetReps: "Failure",
        restSeconds: 120,
        muscleWorked: "Brachialis & Brachioradialis",
        gokuQuote: "Drive that dumbbell across your chest for thicker arm width!",
        animeReference: "Vi Hextech Gauntlet (Arcane)",
      ),
    ],
  ),
  WorkoutDay(
    dayNumber: 2,
    title: "Day 2: Lower Body (Quad Sweep) + Upper Abs",
    focus: "Outer quad sweep, hamstring stretch, blocky upper abs.",
    exercises: [
      Exercise(
        code: "1A",
        name: "Barbell Front Squats (or Hack Squats)",
        category: "Quads (Sweep)",
        sets: 4,
        targetReps: "6-8",
        restSeconds: 0,
        muscleWorked: "Vastus Lateralis (Outer Quad Sweep)",
        gokuQuote: "Keep your torso upright and sink deep! Build explosive leg drive!",
        animeReference: "Goku King Kai Planet Squats (DBZ)",
      ),
      Exercise(
        code: "1B",
        name: "Leg Extensions",
        category: "Quads (Sweep)",
        sets: 4,
        targetReps: "Failure",
        restSeconds: 120,
        muscleWorked: "Rectus Femoris & Teardrop",
        gokuQuote: "Hold the top for a split second! Squeeze every fiber in your quads!",
        animeReference: "Sanji Diable Jambe Kick (One Piece)",
      ),
    ],
  ),
  WorkoutDay(
    dayNumber: 3,
    title: "Day 3: Active Rest & Full Core",
    focus: "10,000-12,000 steps + Core Giant Set.",
    exercises: [
      Exercise(
        code: "GIANT",
        name: "Core Giant Set (Hanging Leg Raises + Cable Crunches + Side Bends)",
        category: "Full Core (4 Rounds)",
        sets: 4,
        targetReps: "Failure / 20 / 15",
        restSeconds: 60,
        muscleWorked: "Full Abdominal Wall",
        gokuQuote: "Even on rest days, a Saiyan sharpens his core! Hit all three back-to-back!",
        animeReference: "Goku Meditation Core Bracing (DBZ)",
      ),
    ],
  ),
  WorkoutDay(
    dayNumber: 4,
    title: "Day 4: Upper Body (Density & Thickness)",
    focus: "Raw mid-back thickness, heavy pressing, massive peaks.",
    exercises: [
      Exercise(
        code: "1A",
        name: "Heavy Pendlay Rows (Dead stop on floor)",
        category: "Back (Thickness)",
        sets: 4,
        targetReps: "6-8",
        restSeconds: 0,
        muscleWorked: "Rhomboids & Traps",
        gokuQuote: "Dead stop on the floor every rep! Explode that barbell to your stomach!",
        animeReference: "Goku Katchin Block Row (DBZ)",
      ),
      Exercise(
        code: "1B",
        name: "Chest-Supported Dumbbell Rows",
        category: "Back (Thickness)",
        sets: 4,
        targetReps: "Failure",
        restSeconds: 120,
        muscleWorked: "Mid-Back Density",
        gokuQuote: "Keep your chest glued to the pad and row with pure power!",
        animeReference: "Goku Gravity Row (DBZ)",
      ),
    ],
  ),
  WorkoutDay(
    dayNumber: 5,
    title: "Day 5: Lower Body (Posterior Power)",
    focus: "Raw deadlift power and deep glute/hamstring density.",
    exercises: [
      Exercise(
        code: "1",
        name: "Dead-Stop Barbell Deadlifts",
        category: "Heavy Pull",
        sets: 4,
        targetReps: "4-6",
        restSeconds: 180,
        muscleWorked: "Entire Posterior Chain",
        gokuQuote: "This is the ultimate test of power! Brace your belt and RIP IT UP!",
        animeReference: "Goku Super Saiyan 3 Earth-Shaking Pull (DBZ)",
      ),
    ],
  ),
];

class LiquidGlassCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final EdgeInsets padding;

  const LiquidGlassCard({
    super.key,
    required this.child,
    this.glowColor = const Color(0xFF00F0FF),
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.25),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.28),
                width: 1.5,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.18),
                  Colors.white.withOpacity(0.04),
                  glowColor.withOpacity(0.12),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class MainGlassDashboard extends StatefulWidget {
  const MainGlassDashboard({super.key});

  @override
  State<MainGlassDashboard> createState() => _MainGlassDashboardState();
}

class _MainGlassDashboardState extends State<MainGlassDashboard> {
  int selectedDayIndex = 0;
  int currentTab = 0;
  int caloriesBurned = 0;
  bool creatineDuringWorkout = false;
  bool postWorkout4Eggs = false;
  bool postWorkout2SoyaPackets = false;
  String aiMacroResult = "Snap a photo of your meal (Eggs, Soya Badi, etc.) to calculate exact macros.";
  bool isScanningFood = false;

  void _openGokuCoachingModal(Exercise ex) {
    int completedReps = 0;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(14.0),
              child: LiquidGlassCard(
                glowColor: const Color(0xFFFF6B00),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${ex.code}:${ex.name}", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: Colors.black.withOpacity(0
                                                        
