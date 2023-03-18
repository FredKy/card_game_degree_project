import 'dart:async';
import 'dart:math';
//import 'dart:ui' hide TextStyle;
import 'package:card_game_degree_project/game/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart' hide Draggable;

import 'package:card_game_degree_project/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

import '../game/utils.dart' as utils;
import '../game/paints.dart' as paints;

class Card extends PositionComponent
    with Draggable, CollisionCallbacks, HasPaint, HasGameReference<CardGame> {
  String name, description, type;
  int id, cost, power, imageNumber;

  /* @override
  bool debugMode = true; */

  final TextComponent cardNameText = TextComponent();
  final TextComponent cardDescriptionText = TextComponent();
  //late final CostField costField;

  bool canBeMoved = false;
  bool _isDragging = false;
  bool _faceUp = true;
  bool _isInPlayCardArea = false;
  bool hasBeenPlayed = false;
  bool get isFaceUp => _faceUp;
  void flip() => _faceUp = !_faceUp;

  Vector2? dragStartingPosition;
  late int startingPriority;

  bool toBeDestroyed = false;

  int handPosition;

  final _collisionColor = Colors.amber;
  final _defaultColor = Colors.cyan;
  final _defaultBorderColor = const Color.fromARGB(255, 68, 68, 68);
  final ShapeHitbox hitbox =
      RectangleHitbox(size: CardGame.cardSize, isSolid: true);

  final Random _random = Random();
  bool showParticleTrail = false;

  Card({
    this.name = "",
    this.description = "Here is where\nthe description\nshould be",
    this.type = "",
    required this.id,
    this.cost = 0,
    this.power = 0,
    this.imageNumber = 19,
    this.dragStartingPosition,
    this.handPosition = -1,
  }) : super(size: CardGame.cardSize, anchor: Anchor.center);

  factory Card.create(CardName name) {
    switch (name) {
      case CardName.icecannon:
        return Card(
            id: 1,
            name: "Ice Cannon",
            description: "Deal 7 damage.",
            imageNumber: 19,
            cost: 2);
      case CardName.warptime:
        return Card(id: 2, name: "Warp Time", imageNumber: 29, cost: 3);
      case CardName.coldtouch:
        return Card(id: 3, name: "Cold Touch", imageNumber: 38, cost: 1);
      default:
        return Card(id: 0, dragStartingPosition: Vector2(0, 0));
    }
  }

  @override
  String toString() => name;

  @override
  void render(Canvas canvas) {
    if (_faceUp) {
      _renderFront(canvas);
    } else {
      _renderBack(canvas);
    }
  }

  static final Paint frontBackgroundPaint = Paint()
    ..color = const Color.fromARGB(255, 104, 104, 104);
  static final Paint redBorderPaint = Paint()
    ..color = const Color(0xffece8a3)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 7;
  final Paint frontBorderPaint = Paint()
    ..color = const Color.fromARGB(255, 68, 68, 68)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 12;

  static late final Sprite iceCannonSprite =
      cardImageSprite(19 * 256, 0, 256, 192);
  static late final Sprite warpTimeSprite =
      cardImageSprite(29 * 256, 64, 256, 192);
  static late final Sprite coldTouchSprite =
      cardImageSprite(38 * 256, 64, 256, 192);

  void _renderFront(Canvas canvas) {
    canvas.drawRRect(cardRRect, frontBackgroundPaint);
    canvas.drawRRect(
      cardRRect,
      frontBorderPaint,
    );

    var pos = Vector2(size.x / 2, size.y * (0.38));
    var scale = 1.125;
    switch (imageNumber) {
      case 19:
        iceCannonSprite.render(canvas,
            position: pos,
            anchor: Anchor.center,
            size: iceCannonSprite.srcSize.scaled(scale));
        break;
      case 29:
        warpTimeSprite.render(canvas,
            position: pos,
            anchor: Anchor.center,
            size: warpTimeSprite.srcSize.scaled(scale));
        break;
      case 38:
        coldTouchSprite.render(canvas,
            position: pos,
            anchor: Anchor.center,
            size: warpTimeSprite.srcSize.scaled(scale));
        break;
      default:
        iceCannonSprite.render(canvas,
            position: pos,
            anchor: Anchor.center,
            size: warpTimeSprite.srcSize.scaled(scale));
        break;
    }
    //canvas.drawRRect(cardCostRRect, costRectPaint);
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

  void _renderBack(Canvas canvas) {
    canvas.rotate(2 * pi);
    canvas.drawRRect(cardRRect, backBackgroundPaint);
    canvas.drawRRect(cardRRect, backBorderPaint1);
    canvas.drawRRect(backRRectInner, backBorderPaint2);
    /* flameSprite.render(canvas,
        position: Vector2(300, 300), anchor: Anchor.center); */
  }

  @override
  FutureOr<void> onLoad() {
    super.onLoad();

    startingPriority = priority;

    if (_faceUp) {
      cardNameText
        ..text = name
        ..textRenderer = paints.nameTextPaint
        ..anchor = Anchor.center
        ..position = Vector2(size.x / 2, 28);
      add(cardNameText);
      add(DescriptionField(description: description));
      add(CostField(position: Vector2(15, 15), cost: cost.toString()));
    }

    /* final defaultPaint = Paint()
      ..color = _defaultColor
      ..style = PaintingStyle.stroke;
    hitbox.paint = defaultPaint;
    hitbox.renderShape = true; */

    add(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (showParticleTrail) {
      final particleComponent = getTrail();
      game.add(particleComponent);
    }
  }

  //START Drag functions

  Vector2? dragDeltaPosition;
  bool get isDragging => dragDeltaPosition != null;

  @override
  bool onDragStart(DragStartInfo startPosition) {
    print("onDragStart: " + canBeMoved.toString());
    if (canBeMoved) {
      dragDeltaPosition = startPosition.eventPosition.game - position;
      priority = 100;
    }
    return false;
  }

  @override
  bool onDragUpdate(DragUpdateInfo event) {
    if (canBeMoved) {
      if (isDragging) {
        final localCoords = event.eventPosition.game;
        position = localCoords - dragDeltaPosition!;
      }
    }
    return false;
  }

  @override
  bool onDragEnd(DragEndInfo event) {
    print(canBeMoved);
    if (_isInPlayCardArea) {
      //_isDragging = false;
      double duration = 0.4;
      canBeMoved = false;

      hasBeenPlayed = true;
      //showParticleTrail = true;
      //game.add(getParticleComponent());

      game.moveCards();
      add(MoveEffect.to(
        CardGame.discardPilePosition,
        EffectController(
          duration: duration / 2,
          curve: Curves.easeOut,
        ),
      ));
      add(ScaleEffect.to(
          Vector2.all(0.3),
          EffectController(
            duration: duration,
            curve: Curves.ease,
          )));
      add(MoveByEffect(
          Vector2(0, -500),
          EffectController(
              duration: duration / 2,
              reverseDuration: duration / 2,
              curve: Curves.ease)));
      add(RotateEffect.by(
        (8 / 4) * pi,
        EffectController(
          duration: duration * 0.8,
          curve: Curves.ease,
        ),
      ));
      /* 
      Fixed bug by moving this moveEffect to the top of the effects.
      The ending position in y-axis would be overshot if the duration parameter was set too low.
      For instance 0.3 instead of 0.6
      add(MoveEffect.to(
        CardGame.discardPilePosition,
        EffectController(
          duration: duration / 2,
          curve: Curves.easeOut,
        ),
      )); */

      hitbox.collisionType = CollisionType.inactive;
      frontBorderPaint.color = _defaultBorderColor;

      /* await Future.delayed(
          Duration(milliseconds: (duration * 1000 + 1).toInt())); */
      //delayTime((duration * 1000 + 1).toInt());
      game.disablePlayerInput((1000 * duration + 1).toInt());
      //game.hand.removeAt(handPosition);
      toBeDestroyed = true;
      game.destroyCardsScheduledForDestructionAfterCountdown(
          (1000 * duration + 100).toInt());

      /* game.disableRemainingCardsAndRemovePlayedCard(
          (duration * 1000 + 1).toInt()); */
      //game.activateCards();
      //destroy();
    } else {
      //_isDragging = false;
      canBeMoved = false;
      add(MoveEffect.to(
        dragStartingPosition ?? Vector2(0, 0),
        EffectController(
          duration: 0.2,
          curve: Curves.easeOut,
        ),
      ));
      //delayTime(201);
      //game.disableRemainingCardsAndRemovePlayedCard(201);
      game.disablePlayerInput((201).toInt());
      priority = startingPriority;
      canBeMoved = true;
    }
    dragDeltaPosition = null;
    return false;
  }

  @override
  bool onDragCancel() {
    dragDeltaPosition = null;
    return false;
  }

  //END Drag functions

  //START Collision

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayCardArea) {
      frontBorderPaint.color = _collisionColor;
      _isInPlayCardArea = true;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    frontBorderPaint.color = _defaultBorderColor;
    _isInPlayCardArea = false;
  }

  //END Collision

  void destroy() {
    removeFromParent();
    return;
  }

  // Utilities
  Vector2 getRandomVectorLocal() {
    return (Vector2.random(_random) - Vector2(0.5, -1)) * 100;
  }

  Color getRandomColor() {
    T getRandomElement<T>(List<T> list) {
      final random = Random();
      var i = random.nextInt(list.length);
      return list[i];
    }

    var list = [
      const Color.fromRGBO(255, 217, 94, 1),
      const Color.fromRGBO(255, 217, 94, 1),
      const Color.fromARGB(255, 255, 158, 94),
      const Color.fromARGB(255, 255, 158, 94),
      const Color.fromARGB(255, 255, 113, 94),
    ];
    return getRandomElement(list);
  }

  ParticleSystemComponent getParticleExplosion() {
    return ParticleSystemComponent(
        particle: Particle.generate(
            count: 30,
            lifespan: 1.5,
            generator: (i) => AcceleratedParticle(
                  acceleration: utils.getRandomVector(300),
                  speed: utils.getRandomVector(100),
                  position:
                      (/* Vector2(0, size[1] * 0.3) + */ position.clone()),
                  child: ComputedParticle(
                    renderer: (canvas, particle) {
                      // Override the color to dynamically update opacity
                      paint.color = utils.getRandomColor().withOpacity(
                          utils.fourth(particle.progress, 1.5) as double);

                      canvas.drawCircle(
                        Offset.zero,
                        // Closer to the end of lifespan particles
                        // will turn into larger glaring circles
                        Random().nextDouble() * particle.progress > .4
                            ? (particle.progress > 0.7
                                ? Random().nextDouble() *
                                    (10 * particle.progress)
                                : Random().nextDouble() *
                                    (3 * particle.progress))
                            : 1 + (30 * particle.progress),
                        paint,
                      );
                    },
                  ),
                )));
  }

  ParticleSystemComponent getTrail() {
    return ParticleSystemComponent(
      particle: Particle.generate(
          count: 10,
          lifespan: 3,
          generator: (i) => AcceleratedParticle(
              acceleration: getRandomVectorLocal(),
              speed: getRandomVectorLocal(),
              position: (/* Vector2(0, size.x * 0.3) + */ position.clone()),
              child: CircleParticle(
                radius: 5.5,
                paint: Paint()..color = getRandomColor(),
              ))),
    );
  }
}

class CostField extends PositionComponent {
  CostField({Paint? paint, Vector2? position, String? cost})
      : _paint = paint ?? Paint()
          ..color = const Color.fromARGB(255, 210, 138, 14)
          ..style = PaintingStyle.fill,
        _cost = cost ?? "0",
        super(
          position: position,
          size: Vector2.all(60),
          anchor: Anchor.center,
        );

  final Paint _paint;
  final String _cost;
  final TextComponent _costText = TextComponent();

  static final RRect cardCostRRect = RRect.fromRectAndCorners(
    Vector2(52, 52).toRect(),
    topLeft: const Radius.circular(15),
    topRight: const Radius.circular(15),
    bottomLeft: const Radius.circular(15),
    bottomRight: const Radius.circular(15),
  );

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    _costText
      ..text = _cost
      ..textRenderer = paints.costTextPaint
      ..anchor = Anchor.center
      ..position = Vector2(25, 25);
    add(_costText);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(cardCostRRect, _paint);
  }
}

class DescriptionField extends PositionComponent {
  DescriptionField({Paint? paint, Vector2? position, String? description})
      : _paint = paint ?? Paint()
          ..color = const Color.fromARGB(255, 210, 138, 14)
          ..style = PaintingStyle.fill,
        _description = description ?? "Description here.",
        super(
          position: Vector2(0, 270),
          size: Vector2(300, 140),
          anchor: Anchor.topLeft,
        );

  final Paint _paint;
  final String _description;
  final TextComponent _descriptionText = TextComponent();

  static final RRect cardDescriptionRRect =
      RRect.fromRectAndRadius(Vector2(300, 150).toRect(), Radius.zero);

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    _descriptionText
      ..text = _description
      ..textRenderer = paints.descriptionTextPaint
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, size.y / 2);
    add(_descriptionText);
  }

  /* @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(cardDescriptionRRect, _paint);
  } */
}

enum CardName {
  icecannon,
  warptime,
  coldtouch,
}
