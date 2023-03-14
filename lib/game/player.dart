import 'dart:async';

import 'package:card_game_degree_project/game/game.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart' hide Draggable;

class Player extends PositionComponent
    with CollisionCallbacks, HasGameReference<CardGame>, Draggable {
  static final _paint = Paint()..color = Colors.white;
  Player() : super(size: Vector2(256, 320), anchor: Anchor.center);

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    //add(RectangleHitbox(size: size, isSolid: true)..renderShape = false);
    super.onLoad();
    print(size);
  }

  @override
  void render(Canvas canvas) {
    //canvas.drawRect(size.toRect(), _paint);
    /* playerSprite.render(canvas,
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
        size: playerSprite.srcSize.scaled(4)); */
    //_paint.color = _isDragged ? Colors.red : Colors.white;
    //canvas.drawRect(size.toRect(), _paint);
    idleAnimation.getSprite().render(canvas,
        position: Vector2(size.x / 2, size.y / 2),
        anchor: Anchor.center,
        size: playerSprite.srcSize.scaled(6));
  }

  void update(double dt) {
    idleAnimation.update(dt);
  }

  static late final Sprite playerSprite =
      getPlayerSprite(256 + 32, 48, 128 - 2 * 32, 128, "idle");
  static late final idleAnimation = SpriteAnimation.spriteList([
    for (var i = 0; i < 8; i++)
      getPlayerSprite(i * 128 + 32, 48, 128 - 2 * 32, 128, "idle")
  ], stepTime: 0.125);

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    if (parent is! CardGame) {
      return true;
    }

    position.add(info.delta.game);
    return false;
  }
}
