import 'dart:async';

import 'package:card_game_degree_project/game/game.dart';
import 'package:card_game_degree_project/models/card.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:card_game_degree_project/game/utils.dart' as utils;

class DiscardPile extends PositionComponent {
  final List<CardName> cardList;

  late ShapeHitbox hitbox;
  DiscardPile({required this.cardList})
      : super(
            size: CardGame.cardSize,
            anchor: Anchor.center,
            scale: Vector2.all(0.4),
            position: CardGame.discardPilePosition,
            priority: 500);

  void addCardToTop(CardName cardName) {
    cardList.add(cardName);
  }

  CardName removeCardFromTop() {
    return cardList.removeLast();
  }

  CardName removeCardFromBottom() {
    return cardList.removeAt(0);
  }

  void shuffle() {
    cardList.shuffle();
  }

  int numberOfCards() {
    print(cardList.length);
    return cardList.length;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(cardRRect, backBackgroundPaint);
    canvas.drawRRect(cardRRect, backBorderPaint1);
    canvas.drawRRect(backRRectInner, backBorderPaint2);
  }

  final digitsTextPaint = TextPaint(
      style: TextStyle(
          color: const Color.fromARGB(255, 231, 231, 231),
          fontSize: 50,
          fontFamily: 'Yoster',
          shadows: utils.getShadows(2)));

  final TextComponent _cardsInDiscardPileText = TextComponent();
  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    _cardsInDiscardPileText
      ..text = cardList.length.toString()
      ..textRenderer = digitsTextPaint
      ..anchor = Anchor.center
      ..position = size / 2
      ..scale = Vector2.all(3);
    add(_cardsInDiscardPileText);

    final hitbox = RectangleHitbox(size: size, isSolid: true);
    add(hitbox);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _cardsInDiscardPileText.text = cardList.length.toString();
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
}
