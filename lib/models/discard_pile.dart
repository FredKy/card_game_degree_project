import 'dart:async';

import 'package:card_game_degree_project/game/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class DiscardPile extends PositionComponent {
  late ShapeHitbox hitbox;
  DiscardPile()
      : super(
            size: CardGame.cardSize,
            anchor: Anchor.center,
            scale: Vector2.all(0.4),
            position: CardGame.discardPilePosition);

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(cardRRect, backBackgroundPaint);
    canvas.drawRRect(cardRRect, backBorderPaint1);
    canvas.drawRRect(backRRectInner, backBorderPaint2);
  }

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    final hitbox = RectangleHitbox(size: size, isSolid: true);
    add(hitbox);
  }

  static final Paint backBackgroundPaint = Paint()
    ..color = const Color.fromARGB(255, 40, 7, 0);
  static final Paint backBorderPaint1 = Paint()
    ..color = const Color.fromARGB(255, 65, 20, 0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint backBorderPaint2 = Paint()
    ..color = const Color.fromARGB(92, 158, 58, 0)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 35;
  static final RRect cardRRect = RRect.fromRectAndRadius(
    CardGame.cardSize.toRect(),
    const Radius.circular(CardGame.cardRadius),
  );
  static final RRect backRRectInner = cardRRect.deflate(40);
}
