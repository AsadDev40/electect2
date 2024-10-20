// ignore_for_file: file_names

import 'package:electech/controller/firebase_data_controller.dart';
import 'package:electech/screens/device_setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utiles/widgets/device_widget.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Fetch devices for the current user
      final devices = FirebaseDataController.instance.user.value.devices;

      if (devices.isNotEmpty) {
        return ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) => GestureDetector(
            onTap: () {
              String deviceId = devices[index].deviceID;
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) =>
                      DeviceSettingScreen(deviceId: deviceId)));
            },
            child: DeviceWidget(
              deviceData: devices[index],
            ),
          ),
        );
      } else {
        return const Center(
          child: Text(
            "No devices configured yet",
            style: TextStyle(fontSize: 20),
          ),
        );
      }
    });
  }
}
