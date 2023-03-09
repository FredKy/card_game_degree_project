import 'dart:math';
import 'dart:ui';

import 'package:card_game_degree_project/game/player.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/widgets.dart';

import '../models/card.dart';

class CardGame extends FlameGame
    with HasTappableComponents, HasDraggableComponents {
  static const double cardWidth = 1000.0;
  static const double cardHeight = 1400.0;
  static const double cardGap = 175.0;
  static const double cardRadius = 100.0;
  static final Vector2 cardSize = Vector2(cardWidth, cardHeight);
  static final cardRRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(0, 0, cardWidth, cardHeight),
    const Radius.circular(cardRadius),
  );

  @override
  Future<void> onLoad() async {
    await Flame.images.load('20.png');
    final sprite = await loadSprite('20.png');
    print(sprite.srcSize);

    /* add(
      Player()
        ..position = size / 2
        ..width = 50
        ..height = 100
        ..anchor = Anchor.center,
    ); */

    final world = World();
    add(world);

    final random = Random();
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
    }

    world.add(SpriteComponent(
        sprite: Sprite(
      Flame.images.fromCache('20.png'),
      srcPosition: Vector2(300, 300),
      srcSize: Vector2(512, 512),
    )));

    final camera = CameraComponent(world: world)
      ..viewfinder.visibleGameSize =
          Vector2(cardWidth * 7 + cardGap * 8, 4 * cardHeight + 3 * cardGap)
      ..viewfinder.position = Vector2(cardWidth * 3.5 + cardGap * 4, 0)
      ..viewfinder.anchor = Anchor.topCenter;
    add(camera);

    /* add(
      SpriteComponent(
        sprite: sprite,
        position: size / 2,
        size: sprite.srcSize / 2,
        anchor: Anchor.center,
      ),
    ); */
  }
}

Sprite cardGameSprite(double x, double y, double width, double height) {
  return Sprite(
    Flame.images.fromCache('20.png'),
    srcPosition: Vector2(x, y),
    srcSize: Vector2(width, height),
  );
}
