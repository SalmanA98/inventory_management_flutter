import 'package:flutter/material.dart';

class DashItems {
  String title;
  Widget screen;
  String img;
  bool visibile;
  DashItems(
      {@required this.title,
      @required this.screen,
      @required this.img,
      this.visibile = true});
}
