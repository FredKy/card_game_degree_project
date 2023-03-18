library paints;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

List<Shadow> getShadows(double n) {
  return [
    Shadow(
        // bottomLeft
        offset: Offset(-n, -n),
        color: Colors.black),
    Shadow(
        // bottomRight
        offset: Offset(n, -n),
        color: Colors.black),
    Shadow(
        // topRight
        offset: Offset(n, n),
        color: Colors.black),
    Shadow(
        // topLeft
        offset: Offset(-n, n),
        color: Colors.black),
  ];
}

final nameTextPaint = TextPaint(
    style: TextStyle(
        color: const Color.fromARGB(255, 231, 231, 231),
        fontSize: 30,
        fontFamily: 'Yoster',
        shadows: getShadows(2)));
final costTextPaint = TextPaint(
    style: const TextStyle(
        color: Color.fromARGB(255, 46, 46, 46),
        fontSize: 50,
        fontFamily: 'Yoster'));
final descriptionTextPaint = TextPaint(
    style: TextStyle(
        color: const Color.fromARGB(255, 231, 231, 231),
        fontSize: 25,
        fontFamily: 'Yoster',
        shadows: getShadows(2)));
