import 'dart:async';

import 'package:card_game_degree_project/game/game.dart';
import 'package:card_game_degree_project/models/card.dart';
import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:card_game_degree_project/game/utils.dart' as utils;

class Deck extends PositionComponent {
  //Deck()
  final List<CardName> cardList;

  Deck({required this.cardList})
      : super(
            size: CardGame.cardSize,
            anchor: Anchor.center,
            scale: Vector2.all(0.4),
            position: CardGame.deckPosition,
            priority: 100);

  void addCardToTop(CardName cardName) {
    cardList.add(cardName);
  }

  CardName removeCardFromTop() {
    return cardList.removeLast();
  }

  void shuffle() {
    cardList.shuffle();
  }

  final digitsTextPaint = TextPaint(
      style: TextStyle(
          color: const Color.fromARGB(255, 231, 231, 231),
          fontSize: 50,
          fontFamily: 'Yoster',
          shadows: utils.getShadows(2)));

  final TextComponent _cardsLeftText = TextComponent();
  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    _cardsLeftText
      ..text = cardList.length.toString()
      ..textRenderer = digitsTextPaint
      ..anchor = Anchor.center
      ..position = size / 2
      ..scale = Vector2.all(3);
    add(_cardsLeftText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _cardsLeftText.text = cardList.length.toString();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(cardRRect, backBackgroundPaint);
    canvas.drawRRect(cardRRect, backBorderPaint1);
    canvas.drawRRect(backRRectInner, backBorderPaint2);
  }

  static final Paint backBackgroundPaint = Paint()
    ..color = const Color.fromARGB(255, 21, 57, 165);
  static final Paint backBorderPaint1 = Paint()
    ..color = const Color.fromARGB(255, 35, 73, 188)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10;
  static final Paint backBorderPaint2 = Paint()
    ..color = const Color.fromARGB(255, 52, 92, 210)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 35;
  static final RRect cardRRect = RRect.fromRectAndRadius(
    CardGame.cardSize.toRect(),
    const Radius.circular(CardGame.cardRadius),
  );
  static final RRect backRRectInner = cardRRect.deflate(40);
}
