import 'dart:ui';

import 'package:card_game_degree_project/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class MiscButton extends PositionComponent
    with Tappable, HasGameReference<CardGame> {
  MiscButton() : super(size: Vector2(50, 50), anchor: Anchor.center);
  @override
  bool onTapDown(TapDownInfo info) {
    print("tap down");

    //game.moveCardsToMakeSpace(2);
    //game.dealCardsWhenHandNotEmpty(openPositions: game.moveCardsToMakeSpace(2));
    game.dealCards(2);

    return true;
  }

  @override
  void render(Canvas canvas) {
    // TODO: implement render
    super.render(canvas);
    canvas.drawRect(
        size.toRect(), Paint()..color = Color.fromARGB(255, 210, 203, 14));
  }
}
