// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class CustomToggleButton extends StatefulWidget {
  final bool isOn;
  final VoidCallback onTap;
  final Color themeColor; // Changed from MaterialColor to Color

  const CustomToggleButton({
    super.key,
    required this.isOn,
    required this.onTap,
    required this.themeColor,
  });

  @override
  _CustomToggleButtonState createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          widget.onTap();
        });
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: Colors.lightBlue),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          widget.isOn ? "OFF" : "ON",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
