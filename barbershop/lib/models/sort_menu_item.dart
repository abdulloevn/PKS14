import 'package:barbershop/models/shop_item.dart';

class SortMenuItem {
  Comparable Function(ShopItem)? getSortParameter;
  String menuOption;

  SortMenuItem(this.getSortParameter, this.menuOption);
  @override
  String toString() {
    return menuOption;
  }
}