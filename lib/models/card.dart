import 'dart:async';
import 'dart:math';
//import 'dart:ui' hide TextStyle;
import 'package:card_game_degree_project/game/player.dart';
import 'package:flame/collisions.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import 'package:card_game_degree_project/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

const style = TextStyle(
    color: Color.fromARGB(255, 231, 231, 231),
    fontSize: 40,
    fontFamily: 'Yoster');
final regular = TextPaint(style: style);

class Card extends PositionComponent
    with
        DragCallbacks,
        CollisionCallbacks /* , HasPaint */ /* , HasGameReference<CardGame> */ {
  String name, description, type;
  int id, cost, power, imageNumber;

  final TextComponent textComponent = TextComponent();

  bool canBeMoved = true;
  bool _isDragging = false;
  bool _faceUp = false;
  bool _isInPlayCardArea = false;
  double frame;
  bool get isFaceUp => _faceUp;
  void flip() => _faceUp = !_faceUp;

  set setFrame(double dt) {
    frame = dt;
  }

  final Vector2 dragStartingPosition;
  late int startingPriority;

  final _collisionColor = Colors.amber;
  final _defaultColor = Colors.cyan;
  final _defaultBorderColor = const Color.fromARGB(255, 68, 68, 68);
  late ShapeHitbox hitbox;

  Card({
    this.name = "",
    this.description = "",
    this.type = "",
    required this.id,
    this.cost = 0,
    this.power = 0,
    this.imageNumber = 19,
    this.frame = 0,
    required this.dragStartingPosition,
  }) : super(size: CardGame.cardSize);

  @override
  String toString() => "Test";

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
      cardGameSprite(19 * 256, 0, 256, 192);
  static late final Sprite warpTimeSprite =
      cardGameSprite(29 * 256, 64, 256, 192);

  void _renderFront(Canvas canvas) {
    canvas.drawRRect(cardRRect, frontBackgroundPaint);
    canvas.drawRRect(
      cardRRect,
      frontBorderPaint,
    );
    switch (imageNumber) {
      case 19:
        iceCannonSprite.render(canvas,
            position: Vector2(size.x / 2, size.y * (0.38)),
            anchor: Anchor.center,
            size: iceCannonSprite.srcSize.scaled(1.125));
        break;
      default:
        warpTimeSprite.render(canvas,
            position: Vector2(size.x / 2, size.y * (0.38)),
            anchor: Anchor.center,
            size: warpTimeSprite.srcSize.scaled(1.125));
        break;
    }
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
    canvas.rotate(frame * 2 * pi);
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

    textComponent
      ..text = description
      ..textRenderer = regular
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, 25);
    add(textComponent);

    final defaultPaint = Paint()
      ..color = _defaultColor
      ..style = PaintingStyle.stroke;

    final hitbox = RectangleHitbox(size: size, isSolid: true)
      ..paint = defaultPaint
      //..renderShape = true;
      ..renderShape = false;
    add(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  void onDragStart(DragStartEvent event) {
    if (canBeMoved) {
      _isDragging = true;
      priority = 100;
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (canBeMoved) {
      if (!_isDragging) {
        return;
      }
      final delta = event.delta;
      position.add(delta);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) async {
    if (!_isDragging) {
      return;
    }
    if (_isInPlayCardArea) {
      _isDragging = false;
      canBeMoved = false;
      double duration = 0.6;
      add(ScaleEffect.to(
          Vector2.all(0.3),
          EffectController(
            duration: duration,
            curve: Curves.ease,
          )));
      add(RotateEffect.by(
        (3 / 4) * pi,
        EffectController(
          duration: duration,
          curve: Curves.ease,
        ),
      ));
      add(MoveEffect.to(
        CardGame.deckPosition,
        EffectController(
          duration: 0.3,
          curve: Curves.easeOut,
        ),
      ));
      /* add(
        OpacityEffect.fadeOut(
          EffectController(
            duration: 0.3,
          ),
        ),
      ); */

      await Future.delayed(
          Duration(milliseconds: (duration * 1000 + 1).toInt()));
      destroy();
    } else {
      _isDragging = false;
      canBeMoved = false;
      add(MoveEffect.to(
        dragStartingPosition,
        EffectController(
          duration: 0.2,
          curve: Curves.easeOut,
        ),
      ));
      await Future.delayed(const Duration(milliseconds: 201));
      //dragStartingPosition = Vector2(0, 0);
      priority = startingPriority;
      canBeMoved = true;
    }
  }

  //Collision

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    //blackBorderPaint.color = _defaultBorderColor;
    /* if (other is ScreenHitbox) {
      //...
    } else if (other is Player) {
      blackBorderPaint.color = _collisionColor;
    } */
    if (other is Player || other is PlayCardArea) {
      frontBorderPaint.color = _collisionColor;
      _isInPlayCardArea = true;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    frontBorderPaint.color = _defaultBorderColor;
    _isInPlayCardArea = false;
    /* if (other is ScreenHitbox) {
      //...
    } else if (other is Player) {
      hitbox.paint.color = _defaultColor;
    } */
  }

  void destroy() {
    /* final particleComponent = ParticleSystemComponent(
        particle: Particle.generate(
            count: 10,
            lifespan: 1.5,
            generator: (i) => AcceleratedParticle(
                  acceleration: utils.getRandomVector(300),
                  speed: utils.getRandomVector(100),
                  position: (Vector2(0, size[1] * 0.3) + position.clone()),
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
    gameRef.add(particleComponent); */

    removeFromParent();

    //gameRef.player.score += 100;
    /* final command = Command<Player>(action: ((player) {
      player.addToScore(100);
    }));
    gameRef.addCommand(command); */

    return;
  }
}
