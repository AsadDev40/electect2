// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names

import 'dart:async';

import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:electech/controller/firebase_data_controller.dart';
import 'package:electech/provider/timer_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeviceSettingScreen extends StatefulWidget {
  const DeviceSettingScreen({super.key, required this.deviceId});

  final String deviceId;

  @override
  State<DeviceSettingScreen> createState() => _DeviceSettingScreenState();
}

class _DeviceSettingScreenState extends State<DeviceSettingScreen> {
  // final timerProvider = Provider.of<Timeprovider>(context, listen: false);
  CountDownController controller = CountDownController();
  TimeOfDay _timeOfDay = TimeOfDay.now();
  final dataController = FirebaseDataController();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  late Stopwatch stopwatch;
  late Timer t;
  bool clicked = false;
  bool on1 = false;
  bool on2 = false;
  bool on3 = false;
  var token;
  int minutes = 1;
  bool isTimerActive = false;

  @override
  void initState() {
    super.initState();

    stopwatch = Stopwatch();
    t = Timer.periodic(const Duration(microseconds: 30), (timer) {
      if (mounted) {
        setState(() {});
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      final isDeviceOn = Provider.of<Timeprovider>(context, listen: false)
          .getDeviceState(widget.deviceId);

      if (!isDeviceOn) {
        // If isDeviceOn is false, stop and reset the timer
        Provider.of<Timeprovider>(context, listen: false)
            .stopAndResetTimer(widget.deviceId);
      }
    });

    Future.delayed(const Duration(seconds: 0), () {
      final isDeviceOn = Provider.of<Timeprovider>(context, listen: false)
          .getDeviceState(widget.deviceId);

      if (isDeviceOn) {
        setState(() {
          clicked = !clicked;
          on1 = !on1;
          if (clicked) {
            Provider.of<Timeprovider>(context, listen: false).startwatchTimer();
            Provider.of<Timeprovider>(context, listen: false)
                .startTimer(minutes);

            dataController.updateDevice(widget.deviceId, {
              'relay1': "ON",
              'relay2': "ON",
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.withOpacity(0.25),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            GestureDetector(
              onTap: () {
                setState(() {
                  clicked = !clicked;
                  on1 = !on1;
                  if (clicked) {
                    Provider.of<Timeprovider>(context, listen: false)
                        .startwatchTimer();
                    Provider.of<Timeprovider>(context, listen: false)
                        .startTimer(minutes);
                    Provider.of<Timeprovider>(context, listen: false)
                        .updateDeviceState(widget.deviceId, true);

                    dataController.updateDevice(widget.deviceId, {
                      'relay1': "ON",
                      'relay2': "ON",
                    });
                    // sendRequest("1", "ON");
                    // sendRequest("2", "ON");
                  } else {
                    Provider.of<Timeprovider>(context, listen: false)
                        .stopAndResetTimer(widget.deviceId);
                    Provider.of<Timeprovider>(context, listen: false)
                        .updateDeviceState(widget.deviceId, false);

                    // sendRequest("1", "OFF");
                    // sendRequest("2", "OFF");
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: on1
                      ? const Color(0xFF9ED2FC)
                      : const Color(0xFF9ED2FC), // Change color based on state
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  on1 ? "OFF" : "ON",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 250,
                width: 250,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF9ED2FC),
                    width: 4,
                  ),
                ),
                child: Text(
                  Provider.of<Timeprovider>(context, listen: false)
                      .returnFormattedText(),
                  // returnFormattedText(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // DropdownButton for selecting hours
                DropdownButton<int>(
                  value: minutes,
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        minutes = newValue;
                      });
                    }
                  },
                  items: const [
                    DropdownMenuItem<int>(
                      value: 1,
                      child: Text('1 minute'),
                    ),
                    DropdownMenuItem<int>(
                      value: 2,
                      child: Text('2 minutes'),
                    ),
                    DropdownMenuItem<int>(
                      value: 3,
                      child: Text('3 minutes'),
                    ),
                  ],
                ),
              ],
            ),
            // Container(
            //     margin: const EdgeInsets.only(right: 200, top: 20),
            //     child: Text(
            //       'Switches',
            //       style: TextStyle(color: theme.tertiary, fontSize: 25, fontWeight: FontWeight.bold),
            //     )),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Padding(
                      //     padding: const EdgeInsets.only(
                      //       top: 40,
                      //     ),
                      //     child: CircularPercentIndicator(
                      //       radius: 110,
                      //       lineWidth: 15,
                      //       percent: 0.90,
                      //       progressColor: theme.primary,
                      //     )),
                      const SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            _timeOfDay.format(context).toString(),
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _TimePicker();
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(1)),
                              backgroundColor: theme.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                            ),
                            child: Text(
                              'Time Select',
                              style: TextStyle(
                                  color: Colors.blue[100], fontSize: 18),
                            ),
                          ),
                        ],
                      )
                    ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _TimePicker() async {
  //   await showTimePicker(context: context, initialTime: TimeOfDay.now()).then((value) => setState(() {
  //         _timeOfDay = value!;
  //       }));
  // }

  Future<void> _TimePicker() async {
    TimeOfDay? selectedTime =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (selectedTime != null) {
      // Get the current time
      final now = DateTime.now();
      // Convert the selected time to DateTime
      final selectedDateTime = DateTime(
          now.year, now.month, now.day, selectedTime.hour, selectedTime.minute);

      // Check if the selected time is in the future
      if (selectedDateTime.isAfter(now)) {
        // Calculate the duration until the selected time
        final durationUntilSelectedTime = selectedDateTime.difference(now);

        // Start the timer with the calculated duration
        Timer(durationUntilSelectedTime, () {
          // Start the timer when the selected time is reached
          Provider.of<Timeprovider>(context, listen: false).startTimer(minutes);
        });
      } else {
        // The selected time is in the past, do something else if needed
      }

      setState(() {
        _timeOfDay = selectedTime;
      });
    }
  }
}
