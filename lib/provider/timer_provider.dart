// ignore_for_file: unused_local_variable, prefer_typing_uninitialized_variables

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:electech/controller/firebase_data_controller.dart';

class Timeprovider with ChangeNotifier {
  bool _isDeviceOn = false;

  // bool get isDeviceOn => _isDeviceOn;
  Stopwatch stopwatch = Stopwatch();
  Timer? t;
  bool isTimerActive = false;
  int minutes = 1;
  bool on1 = false;
  bool clicked = false;
  var token;
  final _firebaseInstance = FirebaseFirestore.instance.collection('FcmTokens');
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final dataController = FirebaseDataController();
  Map<String, bool> _deviceStates = {};
  bool getDeviceState(String deviceId) {
    return _deviceStates[deviceId] ??
        false; // Return false if the device is not found
  }

  void updateDeviceState(String deviceId, bool isOn) {
    // Update the state for the specific device
    _deviceStates[deviceId] = isOn;
    // Notify listeners of the change
    notifyListeners();
  }

  void startwatchTimer() {
    stopwatch.start();
    notifyListeners();
  }

  void stopTimer() {
    stopwatch.stop();
    addtimerdetails();
    notifyListeners();
  }

  void resetTimer() {
    stopwatch.reset();
    notifyListeners();
  }

  String returnFormattedText() {
    int elapsedTime = stopwatch.elapsed.inMilliseconds;
    int hours = elapsedTime ~/ (1000 * 60 * 60);
    int minutes = (elapsedTime % (1000 * 60 * 60)) ~/ (1000 * 60);
    int seconds = (elapsedTime % (1000 * 60)) ~/ 1000;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void updateMinutes(int newMinutes) {
    minutes = newMinutes;
    notifyListeners();
  }

  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
    notifyListeners();
  }

  Future<void> addtimerdetails() async {
    String randomId = _firebaseInstance.doc().id;
    DateTime now = DateTime.now();

    // Use the current time as the start time and date
    String formattedStartTime = DateFormat('h:mm a').format(now);
    String formattedStartDate = DateFormat('d/M/yyyy').format(now);

    // Add 3 hours to the current time to get the end time
    DateTime expirationTime = now.add(Duration(minutes: minutes));

    // Format the end time
    String formattedEndTime = DateFormat('h:mm a').format(expirationTime);
    String formattedDuration = returnFormattedText();

    // Format the date for the end time

    await _firebaseInstance.doc(randomId).set({
      'fcmT': token,
      "startDate": formattedStartDate, // Store start date
      "startTime": formattedStartTime, // Store start time
      "endTime": formattedEndTime, // Store end time
      "duration": formattedDuration,
      'timestamp': formattedEndTime,
      'userid': currentUserId,
    });
    notifyListeners();
  }

  Future<void> storeToken(String token) async {
    try {
      QuerySnapshot querySnapshot = await _firebaseInstance
          .where('fcmT', isEqualTo: token)
          .limit(1)
          .get();

      String randomId = _firebaseInstance.doc().id;

      await _firebaseInstance.doc(randomId).set({
        'fcmT': token,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteToken() async {
    String token = (await FirebaseMessaging.instance.getToken())!;
    try {
      QuerySnapshot querySnapshot = await _firebaseInstance
          .where('fcmT', isEqualTo: token)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Token exists in Firestore, delete it
        String documentId = querySnapshot.docs.first.id;
        await _firebaseInstance.doc(documentId).delete();
      } else {}
    } catch (e) {
      rethrow;
    }
    notifyListeners();
  }

  Future<void> savingFcmToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
    storeToken(token);
    notifyListeners();
  }

  String sendingRequset(String relay, String status) {
    String completeLink = 'http://192.168.254.137/cm?cmnd=Power$relay $status';
    return completeLink;
  }

  sendRequest(String relay, String status) async {
    String link = sendingRequset(relay, status);
    final url = Uri.parse(link);
    final response = await http.get(url);
    if (response.statusCode == 200) {
    } else {
      return;
    }
    notifyListeners();
  }

  void stopAndResetTimer(String deviceId) async {
    stopTimer();

    resetTimer();
    dataController.updateDevice(deviceId, {
      'relay1': "OFF",
      'relay2': "OFF",
    });
    notifyListeners();
  }

  void startTimer(int minute) {
    const Duration threeHours = Duration(minutes: 30);
    Timer(threeHours, () {
      if (on1) {
        clicked = false;
        on1 = false;

        sendRequest("1", "OFF");
        sendRequest("2", "OFF");
      }
    });

    Timer.periodic(Duration(minutes: minute), (timer) {
      int elapsedTime = stopwatch.elapsed.inMilliseconds;
      int minutesElapsed = (elapsedTime % (1000 * 60 * 60)) ~/ (1000 * 60);
      // Compare the elapsed time with the 'minutes' variable
      if (minutesElapsed >= minutes) {
        showNotification('Alert', 'You exceed the threshold');
      } else {
        return;
      }
    });
    notifyListeners();
  }
}
