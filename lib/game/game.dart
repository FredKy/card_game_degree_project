import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';

import '../models/card.dart';

class CardGame extends FlameGame
    with HasTappableComponents, HasDraggableComponents {
  static const double cardWidth = 300.0;
  static const double cardHeight = 420.0;
  static const double cardGap = 175.0;
  static const double cardRadius = 40;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);
  static final cardRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, cardWidth, cardHeight),
    const Radius.circular(cardRadius),
  );

  bool animated = false;

  @override
  Future<void> onLoad() async {
    await Flame.images.load('aeromancer_spritesheet.png');
    camera.viewport = FixedResolutionViewport(Vector2(1920, 1080));

    /* add(
      Player()
        ..position = size / 2
        ..width = 50
        ..height = 100
        ..anchor = Anchor.center,
    ); */

    /* final world = World();
    add(world);

    Card myCard = Card(id: 1000)
      ..position = Vector2(100 + 3 * 1150, 100 + 2 * 1500)
      ..addToParent(world); */

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

    /* final camera = CameraComponent(world: world)
      ..viewfinder.visibleGameSize =
          Vector2(cardWidth * 7 + cardGap * 8, 4 * cardHeight + 3 * cardGap)
      ..viewfinder.position = Vector2(cardWidth * 3.5 + cardGap * 4, 0)
      ..viewfinder.anchor = Anchor.topCenter;
    add(camera); */
    Card myCard = Card(id: 1000, description: "Ice Cannon")
      ..scale = (animated) ? Vector2(0, 0) : Vector2(1, 1)
      ..anchor = Anchor.center
      ..position = Vector2(800, 850);
    myCard.flip();

    Card mySecondCard =
        Card(id: 1000, description: "Warp Time", imageNumber: 29)
          ..scale = (animated) ? Vector2(0, 0) : Vector2(1, 1)
          ..anchor = Anchor.center
          ..position = Vector2(1200, 850);
    mySecondCard.flip();

    add(myCard);
    add(mySecondCard);

    /* world.add(SpriteComponent(
        sprite: Sprite(
      Flame.images.fromCache('20.png'),
      srcPosition: Vector2(300, 300),
      srcSize: Vector2(512, 512),
    ))); */

    /* add(
      SpriteComponent(
        sprite: sprite,
        position: size / 2,
        size: sprite.srcSize / 2,
        anchor: Anchor.center,
      ),
    ); */

    //children.register<Card>();
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (animated) {
      for (final child in children) {
        if (child is Card) {
          if (child.scale.length < 1) {
            child.scale += Vector2(0.01, 0.01);
          }
          var a = 500 * dt;
          //double power = -0.01*pow(a, 2).toDouble();
          //child.position += Vector2(a, power);
          child.angle -= dt * 1 * pi;
          child.position += Vector2(-40, 100 * sin(1 * child.angle));

          //print(child.toString());
        }
      }
    }

    //children.firstWhere((value) => );
  }
}

Sprite cardGameSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('aeromancer_spritesheet.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
