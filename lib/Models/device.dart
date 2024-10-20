// ignore_for_file: non_constant_identifier_names

class Device {
  final String name;
  final int factor2;
  final int factor1;
  final int power1;
  final int power2;
  String relay1;
  String relay2;
  final String status;
  final String switch1State;
  final String switch2State;
  final int today;
  final int total;
  final DateTime totalStartTime;
  final int voltage;
  final int yesterday;
  final String deviceID;

  Device({
    required this.name,
    required this.deviceID,
    required this.factor1,
    required this.factor2,
    required this.power1,
    required this.power2,
    required this.relay1,
    required this.relay2,
    required this.status,
    required this.switch1State,
    required this.switch2State,
    required this.today,
    required this.total,
    required this.totalStartTime,
    required this.voltage,
    required this.yesterday,
  });

  factory Device.fromJson(json, String device_id) {
    return Device(
      name: json['name'] ?? "",
      factor1: json['factor1'] ?? 0,
      factor2: json['factor2'] ?? 0,
      power1: json['power1'] ?? 0,
      power2: json['power2'] ?? 0,
      relay1: json['relay1'] ?? "",
      relay2: json['relay2'] ?? "",
      status: json['status'] ?? "",
      switch1State: json['switch1State'] ?? "",
      switch2State: json['switch2State'] ?? "",
      today: json['today'] ?? 0,
      total: json['total'] ?? 0,
      totalStartTime: DateTime.parse(json['totalStartTime'] ?? ""),
      voltage: json['voltage'] ?? 0,
      yesterday: json['yesterday'] ?? 0,
      deviceID: device_id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'factor1': factor1,
      // 'factor2': factor2,
      // 'power1': power1,
      // 'power2': power2,
      'relay1': relay1,
      'relay2': relay2,
      // 'status': status,
      // 'switch1State': switch1State,
      // 'switch2State': switch2State,
      // 'today': today,
      // 'total': total,
      // 'totalStartTime': totalStartTime.toIso8601String(),
      // 'voltage': voltage,
      // 'yesterday': yesterday,
      // 'deviceID': deviceID,
    };
  }

  @override
  String toString() {
    return 'Device{name: $name, factor2: $factor2, factor1: $factor1, power1: $power1, power2: $power2, relay1: $relay1, relay2: $relay2, status: $status, switch1State: $switch1State, switch2State: $switch2State, today: $today, total: $total, totalStartTime: $totalStartTime, voltage: $voltage, yesterday: $yesterday, deviceID: $deviceID}';
  }
}
