// ignore_for_file: must_be_immutable, camel_case_types

import 'package:electech/controller/firebase_data_controller.dart';
import 'package:electech/provider/timer_provider.dart';
import 'package:electech/utiles/widgets/tooglebutton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../Models/device.dart';

class DeviceWidget extends StatefulWidget {
  DeviceWidget({super.key, required this.deviceData});

  Device deviceData;

  @override
  State<DeviceWidget> createState() => _deviceState();
}

class _deviceState extends State<DeviceWidget> with TickerProviderStateMixin {
  late final controller = SlidableController(this);

  final dataController = FirebaseDataController();

  @override
  Widget build(BuildContext context) {
    final isDeviceOn = Provider.of<Timeprovider>(context)
        .getDeviceState(widget.deviceData.deviceID);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Center(
        child: Slidable(
          key: Key(widget.deviceData.deviceID),
          startActionPane: ActionPane(
            // A motion is a widget used to control how the pane animates.
            motion: const ScrollMotion(),

            // A pane can dismiss the Slidable.
            dismissible: DismissiblePane(onDismissed: () {}),

            // All actions are defined in the children parameter.
            children: [
              // A SlidableAction can have an icon and/or a label.
              SlidableAction(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                onPressed: (context) {
                  Get.defaultDialog(
                      title: 'Are You Sure?',
                      content: Text(
                          'Remove Device ${widget.deviceData.name} from ${FirebaseDataController.instance.user.value.name} account'),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary),
                          child: const Text('Cencel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            FirebaseDataController.instance
                                .removeDeviceFromUser(
                                    widget.deviceData.deviceID);
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary),
                          child: const Text('   Ok    '),
                        ),
                      ]);
                },
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.delete,
              ),
              SlidableAction(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: TextField(
                          onTap: () {},
                          decoration: const InputDecoration(
                            label: Text('Enter name'),
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                              onPressed: () {}, child: const Text('ok'))
                        ],
                      );
                    },
                  );
                },
                spacing: BorderSide.strokeAlignCenter,
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.white,
                icon: Icons.edit,
              ),
            ],
          ),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            dismissible: DismissiblePane(onDismissed: () {}),
            children: [
              SlidableAction(
                // An action can be bigger than the others.
                flex: 2,
                onPressed: (context) {
                  Get.defaultDialog(
                      title: 'Are You Sure?',
                      content: Text('Remove Device ${widget.deviceData.name}?'),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary),
                          child: const Text('Cencel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            FirebaseDataController.instance
                                .removeDeviceFromUser(
                                    widget.deviceData.deviceID);
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.secondary),
                          child: const Text('   Ok    '),
                        ),
                      ]);
                },
                padding: const EdgeInsets.all(20),
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(30),
                    topLeft: Radius.circular(30)),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                icon: Icons.delete,
              ),
              SlidableAction(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: TextField(
                          onTap: () {},
                          decoration: const InputDecoration(
                            label: Text('Enter Name'),
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                              onPressed: () {}, child: const Text('ok'))
                        ],
                      );
                    },
                  );
                },
                spacing: BorderSide.strokeAlignCenter,
                padding: const EdgeInsets.all(20),
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.white,
                icon: Icons.edit,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(5),
            //height: size.height * 0.35,
            //width: size.width * 0.8,

            decoration: BoxDecoration(
                color: Colors.blue[100],
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black, blurRadius: 3, offset: Offset(2, 3))
                ],
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        size: 20,
                        Icons.online_prediction,
                        color: widget.deviceData.status == 'online'
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(
                      width: 1,
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, right: 40, left: 20),
                  child: Text(
                    widget.deviceData.name,
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 25, top: 10),
                  child: Text(
                    '2 Switch',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 0, left: 15),
                      child: Icon(Icons.add, size: 16, color: Colors.cyan),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 0, left: 10),
                      child: Text(
                        '',
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(top: 30, left: 20),
                    //   child: IconButton(
                    //       onPressed: () {},
                    //       icon: Icon(
                    //         Icons.delete,
                    //         color: Colors.blue[800],
                    //       )),
                    // )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /* Padding(
                  padding: const EdgeInsets.all(30),
                  child: Switch.adaptive(
                      materialTapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                      trackColor: (widget.deviceData.relay1=='ON'?true:false)
                          ? MaterialStatePropertyAll(theme.primaryColor)
                          : const MaterialStatePropertyAll(Colors.white),
                      value: widget.deviceData.relay1=='ON'?true:false,
                      onChanged: (value) {
          
                      }),
          
                ),*/
                    Padding(
                      padding: const EdgeInsets.all(30),
                      child: CustomToggleButton(
                        isOn: isDeviceOn,
                        onTap: () {
                          setState(() {
                            widget.deviceData.relay1 =
                                widget.deviceData.relay1 == 'ON' ? 'OFF' : 'ON';
                            widget.deviceData.relay2 =
                                widget.deviceData.relay2 == 'ON' ? 'OFF' : 'ON';
                          });
                          dataController.setDeviceData(widget.deviceData);
                          context.read<Timeprovider>().updateDeviceState(
                              widget.deviceData.deviceID,
                              widget.deviceData.relay1 == 'ON');

                          // update realtime firebase data to new value
                        },
                        themeColor: Colors.lightBlue == 'ON'
                            ? theme.primaryColor
                            : Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
