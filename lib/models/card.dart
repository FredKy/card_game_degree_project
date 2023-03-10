import 'dart:async';
import 'dart:math';
//import 'dart:ui' hide TextStyle;
import 'package:flutter/painting.dart';

import 'package:card_game_degree_project/game/game.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';

const style = TextStyle(
    color: Color.fromARGB(255, 231, 231, 231),
    fontSize: 120,
    fontFamily: 'Yoster');
final regular = TextPaint(style: style);

class Card extends PositionComponent with DragCallbacks {
  String name, description, type;
  int id, cost, power, imageNumber;

  TextComponent textComponent = TextComponent();

  bool _faceUp = false;
  double frame;

  set setFrame(double dt) {
    frame = dt;
  }

  bool get isFaceUp => _faceUp;
  void flip() => _faceUp = !_faceUp;

  Card({
    this.name = "",
    this.description = "",
    this.type = "",
    required this.id,
    this.cost = 0,
    this.power = 0,
    this.imageNumber = 19,
    this.frame = 0,
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

  void _drawSprite(
    Canvas canvas,
    Sprite sprite,
    double relativeX,
    double relativeY, {
    double scale = 1,
    bool rotate = false,
  }) {
    if (rotate) {
      canvas.save();
      canvas.translate(size.x / 2, size.y / 2);
      canvas.rotate(pi);
      canvas.translate(-size.x / 2, -size.y / 2);
    }
    sprite.render(
      canvas,
      position: Vector2(relativeX * size.x, relativeY * size.y),
      anchor: Anchor.center,
      size: sprite.srcSize.scaled(scale),
    );
    if (rotate) {
      canvas.restore();
    }
  }

  static final Paint frontBackgroundPaint = Paint()
    ..color = const Color.fromARGB(255, 104, 104, 104);
  static final Paint redBorderPaint = Paint()
    ..color = const Color(0xffece8a3)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint blackBorderPaint = Paint()
    ..color = const Color.fromARGB(255, 68, 68, 68)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 40;

  static late final Sprite iceCannonSprite =
      cardGameSprite(19 * 256, 0, 256, 192);
  static late final Sprite warpTimeSprite =
      cardGameSprite(29 * 256, 64, 256, 192);

  void _renderFront(Canvas canvas) {
    canvas.drawRRect(cardRRect, frontBackgroundPaint);
    canvas.drawRRect(
      cardRRect,
      blackBorderPaint,
    );
    switch (imageNumber) {
      case 19:
        iceCannonSprite.render(canvas,
            position: Vector2(size.x / 2, size.y * (0.38)),
            anchor: Anchor.center,
            size: iceCannonSprite.srcSize.scaled(3.765));
        break;
      default:
        warpTimeSprite.render(canvas,
            position: Vector2(size.x / 2, size.y * (0.38)),
            anchor: Anchor.center,
            size: warpTimeSprite.srcSize.scaled(3.765));
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

    textComponent
      ..text = description
      ..textRenderer = regular
      ..anchor = Anchor.center
      ..position = Vector2(size.x / 2, 90);
    add(textComponent);
  }
}
