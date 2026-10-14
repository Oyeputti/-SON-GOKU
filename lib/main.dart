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
    if (now.isAfter(next
