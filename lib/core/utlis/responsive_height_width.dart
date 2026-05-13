import 'package:flutter/material.dart';

double getHeight(BuildContext context, double figmaHeight) {
  final screenHeight = MediaQuery.of(context).size.height;
  const figmaScreenHeight = 812; // Figma frame height
  return screenHeight * (figmaHeight / figmaScreenHeight);
}

double getWidth(BuildContext context, double figmaWidth) {
  final screenWidth = MediaQuery.of(context).size.width;
  const figmaScreenWidth = 375; // Figma frame width
  return screenWidth * (figmaWidth / figmaScreenWidth);
}
