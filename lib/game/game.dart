import 'dart:async';
import 'dart:math';

import 'package:card_game_degree_project/models/discard_pile.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
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
  static final Vector2 deckPosition = Vector2(1820, 850);
  static final Vector2 discardPilePosition = Vector2(100, 850);
  List<CardName> deckCards = [
    CardName.icecannon,
    CardName.coldtouch,
    CardName.warptime,
    CardName.icecannon,
    CardName.icecannon,
    CardName.coldtouch,
    CardName.warptime,
    CardName.icecannon,
    CardName.icecannon,
    CardName.coldtouch,
  ];
  List<Card> hand = [];
  bool animated = true;
  double dealSpeed = 1;
  double dealInterval = 0.1;
  double turnStartDelayMS = 150;

  /*  @override
  Color backgroundColor() => const Color(0x00000000); */

  //Timer stuff starts here.

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

    dealCards(cardsToDeal: deckCards);
    add(DiscardPile());
    add(PlayCardArea()
      ..width = size.x
      ..height = size.y / 3.5);
  }

  void dealCards({required List<CardName> cardsToDeal}) {
    double y = 850;
    if (cardsToDeal.length == 1) {
      hand.add(Card.create(cardsToDeal[0])
        ..dragStartingPosition = Vector2(size.x / 2, y)
        ..scale = (animated) ? Vector2(0, 0) : Vector2(1, 1));
      hand[0].position = deckPosition;
      hand[0].priority = 1;
      addDealEffects(
          startDelay: 0,
          card: hand[0],
          dealSpeed: dealSpeed,
          moveToPosition: Vector2(size.x / 2, y));
      add(hand[0]);
    } else if (cardsToDeal.length > 1) {
      /* var padding;
      if (cardsToDeal.length > 5) {
        padding = 200;
      } else {
        padding = 200 + 160 * (5 - cardsToDeal.length);
      } */
      var padding =
          (cardsToDeal.length > 5) ? 360 : 360 + 160 * (5 - cardsToDeal.length);
      var space = (size.x - 2 * padding) / (cardsToDeal.length - 1);
      for (var i = 0; i < cardsToDeal.length; i++) {
        //var tempCard;
        hand.add(Card.create(cardsToDeal[i])
          ..dragStartingPosition = Vector2(padding + space * i, y)
          ..scale = (animated) ? Vector2(0, 0) : Vector2(1, 1));
        hand[i].position = deckPosition;
        //hand[i].priority = cardsToDeal.length - i;
        hand[i].priority = i + 1;
        addDealEffects(
            startDelay: i * dealInterval,
            card: hand[i],
            dealSpeed: dealSpeed,
            moveToPosition: Vector2(padding + space * i, y));
        add(hand[i]);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    countdown.update(dt);
    interval.update(dt);
    if (elapsedMilliseconds >= turnStartDelayMS) {
      for (final child in children) {
        if (child is Card) {
          if (child.id != 0) child.canBeMoved = true;
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

void addDealEffects(
    {required Card card,
    required double dealSpeed,
    required Vector2 moveToPosition,
    required double startDelay}) {
  card.scale = Vector2(0, 0);
  card.add(
    MoveEffect.to(
      moveToPosition,
      EffectController(
        startDelay: startDelay,
        duration: dealSpeed * 2,
        curve: Curves.easeOutCirc,
      ),
    ),
  );
  card.add(MoveByEffect(
      Vector2(0, -300),
      EffectController(
          startDelay: startDelay,
          duration: dealSpeed * 0.4,
          reverseDuration: dealSpeed * 0.4,
          curve: Curves.ease)));
  card.add(
    RotateEffect.by(
      -4.0 * pi,
      EffectController(
        startDelay: startDelay,
        duration: dealSpeed * 0.6,
        curve: Curves.ease,
      ),
    ),
  );
  card.add(ScaleEffect.to(
      Vector2.all(1),
      EffectController(
        startDelay: startDelay,
        duration: dealSpeed * 0.6,
        //reverseDuration: 0.15,
        curve: Curves.ease,
      )));
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
