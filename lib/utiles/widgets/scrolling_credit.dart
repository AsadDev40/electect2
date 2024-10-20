// ignore_for_file: library_private_types_in_public_api, sized_box_for_whitespace

import 'package:flutter/material.dart';

List<String> aboutTextRows = [
  "This app, developed by Hadeel, ",
  "this is a home automation solution controlled  switches through mobile app.",
  "The app seamlessly integrates with Firebase for real-time data management and synchronization.",
  "When a switch is toggled on, ",
  "the app initiates a stopwatch timer within Flutter, ",
  "enabling precise control and automation.",
];

class ScrollingCreditsWidget extends StatefulWidget {
  const ScrollingCreditsWidget({super.key});
  @override
  _ScrollingCreditsWidgetState createState() => _ScrollingCreditsWidgetState();
}

class _ScrollingCreditsWidgetState extends State<ScrollingCreditsWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Start scrolling animation
    _scrollText();
  }

  void _scrollText() async {
    for (int i = 0; i < aboutTextRows.length; i++) {
      await Future.delayed(const Duration(seconds: 0)); // Delay for each line
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          i * 50.0, // Adjust the scroll offset as needed
          duration: const Duration(seconds: 7), // Scroll animation duration
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
        side: BorderSide(color: Theme.of(context).primaryColor, width: 1),
      ),
      //shape: RoundedRectangleBorder(side: BorderSide(width: 20)),
      title: Text(
        'About',
        style: Theme.of(context).textTheme.titleLarge,
      ),

      //contentPadding: EdgeInsets.all(8),
      content: Container(
        width: double.maxFinite,
        height: 100,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: aboutTextRows.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Text(
                aboutTextRows[index],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
      actionsPadding: const EdgeInsets.all(4),
    );
  }
}
