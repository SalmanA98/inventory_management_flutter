import 'package:flutter/widgets.dart';

class Products {
  String name;
  String price;
  String qty;
  String refundedQty;

  Products(
      {@required this.name,
      @required this.price,
      @required this.qty,
      this.refundedQty});
}
