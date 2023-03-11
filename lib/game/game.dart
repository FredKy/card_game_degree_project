import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:card_game_degree_project/game/player.dart';
import 'package:card_game_degree_project/models/my_collidable.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart' hide Card, Image, Draggable;
import 'package:flame/collisions.dart';

import '../models/card.dart';

class CardGame extends FlameGame
    with HasTappableComponents, HasDraggableComponents, HasCollisionDetection {
  static const double cardWidth = 300.0;
  static const double cardHeight = 420.0;
  static const double cardGap = 175.0;
  static const double cardRadius = 40;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);
  static final cardRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, cardWidth, cardHeight),
    const Radius.circular(cardRadius),
  );
  static final Vector2 deckPosition = Vector2(1720, 850);

  bool animated = true;
  double dealSpeed = 1;
  double dealInterval = 0.1;
  double turnStartDelayMS = 150;

  /*  @override
  Color backgroundColor() => const Color(0x00000000); */

  //Timer stuff starts here.

  static const String description = '''
    This example shows how to use the `Timer`.\n\n
    Tap down to start the countdown timer, it will then count to 5 and then stop
    until you tap the canvas again and it restarts.
  ''';

  final TextPaint textConfig = TextPaint(
    style: const TextStyle(color: Colors.white, fontSize: 20),
  );
  late Timer countdown;
  late Timer interval;

  int elapsedMilliseconds = 0;

  //Timer stuff ends here.

  @override
  Future<void> onLoad() async {
    await Flame.images.load('aeromancer_spritesheet.png');
    camera.viewport = FixedResolutionViewport(Vector2(1920, 1080));

    countdown = Timer(5);
    interval = Timer(
      0.01,
      onTick: () {
        elapsedMilliseconds += 1;
      },
      repeat: true,
    );
    interval.start();

    //add(ScreenHitbox());

    /* add(
      Player()
        ..position = size / 2
        ..width = 50
        ..height = 100
        ..anchor = Anchor.center,
    ); */

    /* final random = Random();
    for (var i = 0; i < 7; i++) {
      for (var j = 0; j < 4; j++) {
        final card = Card(id: i * j)
          ..position = Vector2(100 + i * 1150, 100 + j * 1500)
          ..addToParent(world);
        if (random.nextDouble() < 0.9) {
          // flip face up with 90% probability
          card.flip();
        }
      }
    } */

    Card myCard = Card(
        id: 1000,
        description: "Ice Cannon",
        dragStartingPosition: Vector2(300, 850))
      ..scale = (animated) ? Vector2(0, 0) : Vector2(1, 1)
      ..anchor = Anchor.center;
    myCard.position = Vector2(size.x - 200, 850);
    myCard.canBeMoved = false;
    print(myCard.size);
    print(myCard.anchor.toVector2());
    myCard.flip();
    myCard.priority = 2;
    myCard.add(
      MoveEffect.to(
        Vector2(300, 850),
        EffectController(
          duration: dealSpeed * 2,
          //reverseDuration: dealSpeed * 2,
          //infinite: true,
          curve: Curves.easeOutCirc,
        ),
      ),
    );
    myCard.add(MoveByEffect(
        Vector2(0, -300),
        EffectController(
            duration: dealSpeed * 0.4,
            reverseDuration: dealSpeed * 0.4,
            //infinite: true,
            curve: Curves.ease)));
    myCard.add(
      RotateEffect.by(
        -4.0 * pi,
        EffectController(
          duration: dealSpeed * 0.6,
          //reverseDuration: 0.15,
          curve: Curves.ease,
          //infinite: true,
        ),
      ),
    );
    myCard.add(ScaleEffect.to(
        Vector2.all(1),
        EffectController(
          duration: dealSpeed * 0.6,
          //reverseDuration: 0.15,
          curve: Curves.ease,
        )));

    Card mySecondCard = Card(
        id: 1000,
        description: "Warp Time",
        imageNumber: 29,
        dragStartingPosition: Vector2(700, 850))
      ..scale = (animated) ? Vector2(0, 0) : Vector2(1, 1)
      ..anchor = Anchor.center;
    mySecondCard.position = Vector2(size.x - 200, 850);
    mySecondCard.canBeMoved = false;
    mySecondCard.flip();
    mySecondCard.priority = 1;

    mySecondCard.add(
      MoveEffect.to(
        Vector2(700, 850),
        EffectController(
          startDelay: dealInterval,
          duration: dealSpeed * 2,
          //reverseDuration: dealSpeed * 2,
          //infinite: true,
          curve: Curves.easeOutCirc,
        ),
      ),
    );
    mySecondCard.add(MoveByEffect(
        Vector2(0, -300),
        EffectController(
            startDelay: dealInterval,
            duration: dealSpeed * 0.4,
            reverseDuration: dealSpeed * 0.4,
            //infinite: true,
            curve: Curves.ease)));
    mySecondCard.add(
      RotateEffect.by(
        -4 * pi,
        EffectController(
          startDelay: dealInterval,
          duration: dealSpeed * 0.6,
          //reverseDuration: 0.15,
          curve: Curves.ease,
          //infinite: true,
        ),
      ),
    );
    mySecondCard.add(ScaleEffect.to(
        Vector2.all(1),
        EffectController(
          startDelay: dealInterval,
          duration: dealSpeed * 0.6,
          //reverseDuration: 0.15,
          curve: Curves.ease,
        )));

    add(myCard);
    add(mySecondCard);
    add(PlayCardArea()
      ..width = size.x
      ..height = size.y / 3.5);

    //await Future.delayed(const Duration(milliseconds: 4000));
  }

  @override
  void update(double dt) {
    super.update(dt);
    countdown.update(dt);
    interval.update(dt);
    if (elapsedMilliseconds >= turnStartDelayMS) {
      for (final child in children) {
        if (child is Card) {
          child.canBeMoved = true;
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    textConfig.render(
      canvas,
      'Countdown: ${countdown.current.toStringAsPrecision(3)}',
      Vector2(30, 100),
    );
    textConfig.render(canvas,
        'Elapsed time in milliseconds: $elapsedMilliseconds', Vector2(30, 130));
  }

  /* @override
  void onTapDown(event) {
    super.onTapDown(event);
    //add(MyCollidable(event.eventPosition.game));
    add(MyCollidable(Vector2(500, 500)));
  } */
}

Sprite cardGameSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('aeromancer_spritesheet.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}

class PlayCardArea extends PositionComponent with CollisionCallbacks {
  static final _paint = Paint()..color = Colors.transparent;
  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    add(RectangleHitbox(size: size, isSolid: true)..renderShape = false);
    return super.onLoad();
  }

  /* @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  } */
}
