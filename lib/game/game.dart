import 'dart:async';
import 'dart:math';

import 'package:card_game_degree_project/game/deal_button.dart';
import 'package:card_game_degree_project/game/reshuffle_button.dart';
import 'package:card_game_degree_project/game/player.dart';
import 'package:card_game_degree_project/models/deck.dart';
import 'package:card_game_degree_project/models/discard_pile.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart' hide Card, Image, Draggable;
import 'package:flame/collisions.dart';

import '../models/card.dart';

const String spriteSheetPath = 'aeromancer_spritesheet_pixelated.png';

class CardGame extends FlameGame
    with
        HasTappableComponents,
        HasDraggables,
        HasCollisionDetection,
        HasTappablesBridge {
  static const double cardWidth = 300.0;
  static const double cardHeight = 420.0;
  static const double cardGap = 175.0;
  static const double cardRadius = 30;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);
  static final cardRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, cardWidth, cardHeight),
    const Radius.circular(cardRadius),
  );
  /* static final Vector2 deckPosition = Vector2(1860, 850);
  static final Vector2 discardPilePosition = Vector2(65, 850); */
  static final Vector2 discardPilePosition = Vector2(1860, 850);
  static final Vector2 deckPosition = Vector2(65, 850);
  //List<CardName> cardsToDeal = [];
  List<Card> hand = [];
  Deck playerDeck = Deck(cardList: [
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
  ]);
  DiscardPile discardPile = DiscardPile(cardList: [
    CardName.icecannon,
    CardName.coldtouch,
    CardName.warptime,
    CardName.icecannon,
    CardName.icecannon,
  ])
    ..priority = 100;
  bool animated = true;
  double dealSpeed = 1;
  double dealInterval = 0.1;
  int turnStartDelayMS = 150;
  final player = Player()..position = Vector2(1920 / 8, 1080 / 2.5);

  /*  @override
  Color backgroundColor() => const Color(0x00000000); */

  /* @override
  bool debugMode = true; */

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
    await super.onLoad();
    await Flame.images.load(spriteSheetPath);
    await Flame.images.load('player_idle.png');

    camera.viewport = FixedResolutionViewport(Vector2(1920, 1080));

    countdown = Timer(5);
    interval = Timer(
      0.01,
      onTick: () {
        elapsedMilliseconds += 1;
        if (elapsedMilliseconds == turnStartDelayMS) {
          for (final child in children) {
            if (child is Card) {
              if (child.id != 0) child.canBeMoved = true;
            }
          }
        }
      },
      repeat: true,
    );
    interval.start();

    //add(ScreenHitbox());

    add(player);

    playerDeck.shuffle();
    playerDeck.priority = 100;
    add(playerDeck);
    add(discardPile);
    dealCards(cardsToDeal: getCardsToDealFromDeck(1));

    add(PlayCardArea()
      ..width = size.x
      ..height = size.y / 3.5);

    add(ReshuffleButton()..position = Vector2(1800, 300));
    add(DealButton()..position = Vector2(1800, 200));
  }

  List<CardName> getCardsToDealFromDeck(int n) {
    List<CardName> cardsToDeal = [];
    if (playerDeck.cardList.length >= n) {
      for (var i = 0; i < n; i++) {
        cardsToDeal.add(playerDeck.removeCardFromTop());
      }
    }
    return cardsToDeal;
  }

  void dealCards({required List<CardName> cardsToDeal}) {
    double y = 850;
    disablePlayerInput((dealSpeed * 1000 + cardsToDeal.length * 100).toInt());
    if (cardsToDeal.length == 1) {
      hand.add(Card.create(cardsToDeal[0])
        ..dragStartingPosition = Vector2(size.x / 2, y)
        ..scale = (animated) ? Vector2(0, 0) : Vector2(1, 1)
        ..position = deckPosition
        ..priority = hand.length + 1
        ..handPosition = 0);
      addDealEffects(
          startDelay: 0,
          card: hand[hand.length - 1],
          dealSpeed: dealSpeed,
          moveToPosition: Vector2(size.x / 2, y));
      add(hand[hand.length - 1]);
    } else if (cardsToDeal.length > 1) {
      var padding =
          (cardsToDeal.length > 5) ? 320 : 320 + 100 * (5 - cardsToDeal.length);
      var space = (size.x - 2 * padding) / (cardsToDeal.length - 1);
      for (var i = 0; i < cardsToDeal.length; i++) {
        hand.add(Card.create(cardsToDeal[i])
          ..dragStartingPosition = Vector2(padding + space * i, y)
          ..scale = (animated) ? Vector2(0, 0) : Vector2(1, 1)
          ..position = deckPosition
          ..priority = i + 1
          ..handPosition = i);
        addDealEffects(
            startDelay: i * dealInterval,
            card: hand[i],
            dealSpeed: dealSpeed,
            moveToPosition: Vector2(padding + space * i, y));
        add(hand[i]);
      }
    }
    print("Hand after deal " + hand.toString());
  }

  void moveCardsFromDiscardPileToDeck() async {
    List<Card> flyingCards = [];
    discardPile.shuffle();
    var c = 5;
    final numberOfCards = discardPile.numberOfCards();
    for (var i = 0; i < numberOfCards; i++) {
      flyingCards.add(Card.create(discardPile.removeCardFromTop())
        ..scale = Vector2.all(0.3)
        ..position = discardPilePosition
        ..canBeMoved = false
        ..priority = 5
        ..toBeDestroyed);
      addFlyingCardEffects(
          startDelay: c * i * dealInterval / numberOfCards,
          card: flyingCards[i],
          dealSpeed: dealSpeed,
          moveToPosition: deckPosition);
      add(flyingCards[i]);
    }
    await Future.delayed(Duration(
        milliseconds: (dealSpeed * 1000 + c * dealInterval + 300).toInt()));
    for (var card in flyingCards) {
      CardName cardName = cardNameFromId(card);
      playerDeck.addCardToTop(cardName);
      card.removeFromParent();
    }
    print(hand);
    //for (var i = 0; i < flyingCards.length; i++) {}
  }

  void addFlyingCardEffects(
      {required Card card,
      required double dealSpeed,
      required Vector2 moveToPosition,
      required double startDelay}) {
    var displacement = deckPosition - discardPilePosition;
    Path path = Path();
    path.lineTo(displacement.x, displacement.y);
    //path.close();
    card.add(MoveAlongPathEffect(
        path,
        EffectController(
            startDelay: startDelay, duration: dealSpeed, curve: Curves.ease)));

    card.add(MoveByEffect(
        Vector2(0, -500),
        EffectController(
            startDelay: startDelay,
            duration: dealSpeed * 0.5,
            reverseDuration: dealSpeed * 0.5,
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
    /* card.add(ScaleEffect.to(
        Vector2.all(0.3),
        EffectController(
          startDelay: startDelay,
          duration: dealSpeed * 0.6,
          //reverseDuration: 0.15,
          curve: Curves.ease,
        ))); */
  }

  void moveCards() {
    double y = 850;
    //var count = 0;
    List<Card> hand = [];
    for (final child in children) {
      if (child is Card) {
        //count += 1;
        child.canBeMoved = false;
        if (!child.hasBeenPlayed) hand.add(child);
      }
    }
    //Vector2(size.x / 2, y)
    if (hand.length == 1) {
      hand[0].dragStartingPosition = Vector2(size.x / 2, y);
      hand[0].add(MoveEffect.to(
        Vector2(size.x / 2, y),
        EffectController(
          duration: dealSpeed,
          curve: Curves.easeOutCirc,
        ),
      ));
    } else if (hand.length > 1) {
      var padding = (hand.length > 5) ? 320 : 320 + 100 * (5 - hand.length);
      var space = (size.x - 2 * padding) / (hand.length - 1);
      for (var i = 0; i < hand.length; i++) {
        hand[i].dragStartingPosition = Vector2(padding + space * i, y);
        hand[i].add(MoveEffect.to(
          Vector2(padding + space * i, y),
          EffectController(
            duration: dealSpeed,
            curve: Curves.easeOutCirc,
          ),
        ));
      }
    }
  }

  void activateCards() {
    for (final child in children) {
      if (child is Card) {
        child.canBeMoved = true;
      }
    }
  }

  void disableRemainingCardsAndRemovePlayedCard(int milliseconds) async {
    for (final child in children) {
      if (child is Card) {
        child.canBeMoved = false;
      }
    }
    await Future.delayed(Duration(milliseconds: milliseconds));
    for (final child in children) {
      if (child is Card && child.toBeDestroyed) {
        remove(child);
      }
    }
  }

  void destroyCardsScheduledForDestructionAfterCountdown(
      int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    for (final child in children) {
      if (child is Card && child.toBeDestroyed) {
        CardName cardName = cardNameFromId(child);
        discardPile.addCardToTop(cardName);
        remove(child);
      }
    }
  }

  CardName cardNameFromId(Card card) {
    CardName cardName;
    if (card.id == 1) cardName = CardName.icecannon;
    if (card.id == 2) cardName = CardName.warptime;
    if (card.id == 3)
      cardName = CardName.coldtouch;
    else
      cardName = CardName.icecannon;
    return cardName;
  }

  void disablePlayerInput(int milliseconds) async {
    var inputBarrier = DisableInputBarrier()..priority = 2000;
    add(inputBarrier);
    await Future.delayed(Duration(milliseconds: milliseconds));
    inputBarrier.removeFromParent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    countdown.update(dt);
    interval.update(dt);
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

Sprite cardImageSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache(spriteSheetPath),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}

Sprite getPlayerSprite(
    double x, double y, double width, double height, String state) {
  if (state == "idle") {
    return Sprite(
      Flame.images.fromCache('player_idle.png'),
      srcPosition: Vector2(x, y),
      srcSize: Vector2(width, height),
    );
  }
  return Sprite(
    Flame.images.fromCache(spriteSheetPath),
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

class DisableInputBarrier extends PositionComponent with Draggable {
  static final _paint = Paint()..color = Colors.transparent;
  DisableInputBarrier() : super(size: Vector2(1920, 1080));
  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    add(RectangleHitbox(size: size, isSolid: true)..renderShape = false);
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }

  bool onDragStart(DragStartInfo startPosition) {
    return false;
  }
}
