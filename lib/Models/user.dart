import 'package:electech/controller/firebase_data_controller.dart';

import 'device.dart'; // Import Firebase package

class User {
  final String userId;
  final String name;
  final String email;
  final List<String> devicesIds;
  List<Device> devices = [];

  User({
    required this.userId,
    required this.name,
    required this.email,
    required this.devicesIds,
  });

  factory User.fromJson(Map<dynamic, dynamic> json) {
    List<String> d = [];
    for (Object? key in json['devices'].keys) {
      d.add(json['devices'][key]);
    }

    final user = User(
      userId: json['userId'] ?? "",
      name: json['name'] ?? "",
      email: json['email'] ?? "",
      devicesIds: d,
    );

    //user.fetchDevicesData(); // Call fetchDevicesData method
    return user;
  }
  factory User.dummy() {
    return User(
      userId: "1",
      name: "h",
      email: "h@gmail.com",
      devicesIds: [],
    );
  }
  void clearDevicesData() {
    devices = [];
  }

  Future<User> fetchDevicesData() async {
    List<String> updatedDevicesIds =
        []; // Temporary list to hold updated device IDs
    for (String deviceId in devicesIds) {
      final deviceData =
          await FirebaseDataController.instance.fetchDeviceData(deviceId);
      if (deviceData != null) {
        devices.add(deviceData);
        updatedDevicesIds
            .add(deviceId); // Add the device ID to the updated list
      }
    }
    // Return a new User object with the updated devicesIds list
    return User(
      userId: userId,
      name: name,
      email: email,
      devicesIds: updatedDevicesIds, // Use the updated list
    );
  }
}
