// ignore_for_file: deprecated_member_use, unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';

import '../Models/device.dart';
import '../Models/user.dart';

class FirebaseDataController extends GetxController {
  final currentUserId = auth.FirebaseAuth.instance.currentUser!.uid;
  final currentuser = auth.FirebaseAuth.instance.currentUser!;
  static final FirebaseDataController instance = Get.find();
  Rx<User> user = User.dummy().obs;
  final fb = FirebaseDatabase.instance.ref();

  Rx<int> bottomNavigationCurrentIndex = 0.obs;

  set setIndex(int index) {
    bottomNavigationCurrentIndex.value = index;
  }

  @override
  void onInit() {
    fetchUserData(currentUserId).then((value) {
      user.value = value;
      user.value.fetchDevicesData().then((v) {
        addListonerToUser().then((value) {});
      });
    });

    super.onInit();
  }

  Future<void> addListonerToUser() async {
    fb.child('users/$currentUserId').onValue.listen((event) async {
      if (event.snapshot.exists) {
        var u = User.fromJson(event.snapshot.value as Map);
        await u.fetchDevicesData().then((value) {});

        user.value = u;
      } else {}
    });
  }

  Future<void> addListonerToAllDevices() async {
    // Iterate over the devicesIds list to fetch and listen for each device
    for (String deviceId in user.value.devicesIds) {
      fb.child('devices/$deviceId').onValue.listen((event) async {
        // Fetch the device data from Firebase
        Device? fetchedDevice =
            await FirebaseDataController.instance.fetchDeviceData(deviceId);
        if (fetchedDevice != null) {
          // Update the local devices list with the fetched device data
          user.value.devices.add(fetchedDevice);
        } else {}
      });
    }
  }

  // Inside your FirebaseDataController class

  Future<List<Device>> fetchDevicesForCurrentUser() async {
    try {
      // Fetch the current user's data
      final userSnapshot = await fb.child('users/$currentUserId').get();
      final userData = userSnapshot.value as Map<String, dynamic>;

      // Check if the user data exists and contains devices
      if (userData != null && userData.containsKey('devices')) {
        // Convert the devices data into a list of Device objects
        List<Device> devices = [];
        for (var deviceData in userData['devices']) {
          // Assuming deviceData is a Map<String, dynamic> representing a device
          // and your Device model has a constructor that takes a Map and a deviceId
          devices.add(Device.fromJson(deviceData, deviceData['deviceId']));
        }

        return devices;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<User> fetchUserData(String userId) async {
    try {
      final snapshot = await fb.child('users/$userId').get();
      final userData = snapshot.value;
      if (userData != null && userData is Map) {
        var u = User.fromJson(userData);

        return u;
      }
    } catch (e) {
      // Handle error gracefully
    }
    return User.dummy();
  }

  Future<Device?> fetchDeviceData(String deviceId) async {
    try {
      final snapshot = await fb.child('/devices/$deviceId').get();
      final deviceData = snapshot.value;

      if (deviceData != null && deviceData is Map) {
        return Device.fromJson(deviceData, deviceId);
      }
    } catch (e) {
      // Handle error gracefully
    }
    return null;
  }

  Future<void> removeDeviceFromUser(String deviceId) async {
    try {
      // Update local user object
      user.update((val) {
        val!.devices.removeWhere((element) => element.deviceID == deviceId);
      });
      await fb.child('users/$currentUserId/devices/$deviceId').remove();
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> addNewDeviceGlobally(
      String name,
      int factor1,
      int factor2,
      int power1,
      int power2,
      String relay1,
      String relay2,
      String status,
      String switch1State,
      String switch2State,
      int today,
      int total,
      DateTime totalStartTime,
      int voltage,
      int yesterday,
      String deviceID) async {
    try {
      // Create a new Device object with the provided parameters
      Device newDevice = Device(
        name: name,
        deviceID: deviceID,
        factor1: factor1,
        factor2: factor2,
        power1: power1,
        power2: power2,
        relay1: relay1,
        relay2: relay2,
        status: status,
        switch1State: switch1State,
        switch2State: switch2State,
        today: today,
        total: total,
        totalStartTime: totalStartTime,
        voltage: voltage,
        yesterday: yesterday,
      );

      // Add the new device to the global devices database
      await fb.child('devices').push().set(newDevice.toJson());
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> setDeviceData(Device device) async {
    try {
      await fb.child('devices/${device.deviceID}').update(device.toJson());
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> updateDevice(String deviceId, Map<String, dynamic> data) async {
    try {
      await fb.child('devices/$deviceId').update(data);
    } catch (e) {
      // Handle error gracefully
    }
  }

  Future<void> addNewDeviceToUser(String newDeviceId) async {
    try {
      final userDevicesRef = FirebaseDatabase.instance
          .reference()
          .child('users/$currentUserId/devices');

      final deviceExists = await userDevicesRef
          .orderByValue()
          .equalTo(newDeviceId)
          .once()
          .then((DatabaseEvent event) => event.snapshot.exists);

      if (deviceExists) {
        return;
      } else {
        final deviceSnapshot = await fb.child('devices/$newDeviceId').get();

        if (deviceSnapshot.exists) {
          await fb
              .child('/users/$currentUserId/devices')
              .push()
              .set(newDeviceId);
        } else {
          await fb.child('devices').push().set(newDeviceId);
          await fb
              .child('/users/$currentUserId/devices')
              .push()
              .set(newDeviceId);
        }
      }
    } catch (e) {
      return;
    }
  }

  void resetvalues() {
    user = User.dummy().obs;
    user.value.clearDevicesData();
  }

  Stream<List<Map<String, dynamic>>> get userDevicesStream {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(auth.FirebaseAuth.instance.currentUser!.uid)
        .collection('devices')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}
