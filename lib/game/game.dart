
import 'package:card_game_degree_project/game/player.dart';
import 'package:flame/game.dart';
import 'package:flame/widgets.dart';

class CardGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    add(
      Player()
        ..position = size / 2
        ..width = 50
        ..height = 100
        ..anchor = Anchor.center,
    );
  }
}