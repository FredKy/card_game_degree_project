import 'dart:async';
import 'dart:math';

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
  static final Vector2 deckPosition = Vector2(1720, 850);
  List<CardName> deckCards = [
    CardName.icecannon,
    CardName.coldtouch,
    CardName.warptime,
    CardName.icecannon,
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

    /* Card myCard = Card.create(CardName.icecannon)
      ..dragStartingPosition = Vector2(300, 850)
      ..scale = (animated) ? Vector2(0, 0) : Vector2(1, 1);
    myCard.position = deckPosition;
    myCard.priority = 3;
    addDealEffects(
        card: myCard, dealSpeed: dealSpeed, moveToPosition: Vector2(300, 850));

    Card mySecondCard = Card.create(CardName.warptime)
      ..dragStartingPosition = Vector2(700, 850)
      ..scale = (animated) ? Vector2(0, 0) : Vector2(1, 1);
    mySecondCard.position = deckPosition;
    mySecondCard.priority = 2;
    addDealEffects(
        card: mySecondCard,
        dealSpeed: dealSpeed,
        moveToPosition: Vector2(700, 850));

    Card myThirdCard = Card.create(CardName.coldtouch)
      ..dragStartingPosition = Vector2(1100, 850)
      ..scale = (animated) ? Vector2(0, 0) : Vector2(1, 1);
    myThirdCard.position = deckPosition;
    myThirdCard.priority = 1;
    addDealEffects(
        card: myThirdCard,
        dealSpeed: dealSpeed,
        moveToPosition: Vector2(1100, 850));

    add(myCard);
    add(mySecondCard);
    add(myThirdCard); */
    dealCards(deck: deckCards);
    add(PlayCardArea()
      ..width = size.x
      ..height = size.y / 3.5);
  }

  void dealCards({required List<CardName> deck}) {
    for (var i = 0; i < deck.length; i++) {
      //var tempCard;
      hand.add(Card.create(deck[i])
        ..dragStartingPosition = Vector2(300 + 400.0 * i, 850)
        ..scale = (animated) ? Vector2(0, 0) : Vector2(1, 1));
      hand[i].position = deckPosition;
      hand[i].priority = deck.length - i;
      addDealEffects(
          startDelay: i * dealInterval,
          card: hand[i],
          dealSpeed: dealSpeed,
          moveToPosition: Vector2(300 + 400.0 * i, 850));
      add(hand[i]);
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
