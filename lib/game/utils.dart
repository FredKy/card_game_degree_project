library utils;

import 'dart:math';
import 'package:card_game_degree_project/models/card.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' hide Card;

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

CardName cardNameFromId(Card card) {
  CardName cardName;
  if (card.id == 1) {
    cardName = CardName.icecannon;
  } else if (card.id == 2) {
    cardName = CardName.warptime;
  } else if (card.id == 3) {
    cardName = CardName.coldtouch;
  } else {
    cardName = CardName.icecannon;
  }
  return cardName;
}
