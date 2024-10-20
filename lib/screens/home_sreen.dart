// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:electech/controller/firebase_data_controller.dart';
import 'package:electech/screens/history.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';

import '../utiles/widgets/my_drawer.dart';
import 'device_screen .dart';
import 'device_setting_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final deviceIdTextController = TextEditingController();

  var token;

  int minutes = 1; // Default selected hour

  final _firebaseInstance = FirebaseFirestore.instance.collection('FcmTokens');

  Future<void> savingFcmToken() async {
    token = (await FirebaseMessaging.instance.getToken())!;
    await storeToken(token);
  }

  Future<void> storeToken(String token) async {
    try {
      QuerySnapshot querySnapshot = await _firebaseInstance
          .where('fcmT', isEqualTo: token)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Token already exists in Firestore
      } else {
        // Token doesn't exist, save it with timestamp
        String randomId = _firebaseInstance.doc().id;
        DateTime now = DateTime.now();

        // Add 3 hours to the current time
        DateTime expirationTime = now.add(Duration(minutes: minutes));

        // Format the timestamp
        String formattedTime = DateFormat('h:mm a').format(expirationTime);
        // Format the date
        String formattedDate = DateFormat('d/M/yyyy').format(expirationTime);

        await _firebaseInstance.doc(randomId).set({
          'fcmT': token,
          "minutes": minutes,
          'timestamp': formattedTime, // Store formatted time
          'date': formattedDate, // Store formatted date
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    savingFcmToken();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Scaffold(
        drawer: const MyDrawer(),
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.grey[300],
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                color: Colors.black,
                icon: Icon(
                  Icons.info_outline,
                  size: 30,
                  color: theme.tertiary,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => history(
                                currentFCMToken: token,
                              )));
                },
              ),
            ),
          ],
          flexibleSpace: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Electech',
                style: TextStyle(fontSize: 20),
              ),
              Image.asset('assets/Images/elogo.png'),
            ],
          ),
        ),
        body: Obx(() {
          return FirebaseDataController
                      .instance.bottomNavigationCurrentIndex.value ==
                  0
              ? const DeviceScreen()
              : FirebaseDataController.instance.user.value.devices.isNotEmpty
                  ? DeviceSettingScreen(
                      deviceId: FirebaseDataController
                          .instance.user.value.devices[0].deviceID)
                  : const Center(
                      child: Text('device Not Configured Yet',
                          style: TextStyle(fontSize: 20)),
                    );
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Obx(() => FirebaseDataController
                    .instance.bottomNavigationCurrentIndex.value ==
                0
            ? Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FloatingActionButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Add New Device'),
                            content: TextField(
                              controller: deviceIdTextController,
                              autofocus: true,
                              decoration: InputDecoration(
                                label: Text(
                                  'Enter Device Id',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.secondary),
                                child: const Text('cencel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  FirebaseDataController.instance
                                      .addNewDeviceToUser(
                                          deviceIdTextController.text.trim());
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.secondary),
                                child: const Text('    ok    '),
                              ),
                            ],
                          );
                        });
                  },
                  backgroundColor: Colors.black87,
                  foregroundColor: theme.primary,
                  elevation: 3,
                  shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Icon(
                    Icons.add,
                    color: Colors.blue[100],
                  ),
                ),
              )
            : const Text("")),
      ),
    );
  }
}
