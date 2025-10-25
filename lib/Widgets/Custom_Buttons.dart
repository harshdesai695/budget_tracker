// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class NormalButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final Color textcolor;
  final Color backgroundColor;
  final double borderRadius;
  final double elevation;
  final double width;
  final double height;
  final double fontSize;

  const NormalButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.textcolor,
    required this.backgroundColor,
    this.elevation = 0.5,
    required this.width,
    required this.height,
    this.fontSize = 15,
    this.borderRadius = 0.0,
  });

  @override
  Widget build(BuildContext context) {
  return MaterialButton(
      onPressed: onPressed,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      color: backgroundColor,
  child: Text(
        text,
        style: TextStyle(
          color: textcolor,
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final Function()? onPressed;
  final Color backgroundColor;

  const CustomIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
  return MaterialButton(
      onPressed: onPressed,
      shape: const CircleBorder(), // Ensure circular shape
      color: backgroundColor,
      padding: const EdgeInsets.all(20.0),
  child: Icon(icon, color: Colors.white),
    );
  }
}
