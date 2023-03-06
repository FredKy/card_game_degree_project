class Card {
  String name, description, type;
  int id, cost, power;
  String? imageAssetPath;

  Card({
    this.name = "",
    this.description = "",
    this.type = "",
    required this.id,
    this.cost = 0,
    this.power = 0,
    this.imageAssetPath,
  });
}
