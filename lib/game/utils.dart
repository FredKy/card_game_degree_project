library utils;

import 'dart:math';
import 'dart:ui';
import 'package:flame/game.dart';

T getRandomElement<T>(List<T> list) {
  final random = Random();
  var i = random.nextInt(list.length);
  return list[i];
}

Color getRandomColor() {
  var list = const [
    Color.fromRGBO(255, 217, 94, 1),
    Color.fromRGBO(255, 217, 94, 1),
    Color.fromARGB(255, 255, 158, 94),
    Color.fromARGB(255, 255, 158, 94),
    Color.fromARGB(255, 255, 113, 94),
  ];
  return getRandomElement(list);
}

Vector2 getRandomVector(double scalar) {
  return (Vector2.random(Random()) - Vector2(0.5, 0.5)) * scalar;
}

num fourth(double x, double lifespan) {
  int parts = 6;
  if (x < lifespan / parts) {
    return 1.0;
  } else {
    return pow((lifespan - (x - lifespan / parts)) / lifespan, 4);
  }
}


