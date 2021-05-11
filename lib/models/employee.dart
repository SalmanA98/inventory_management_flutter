import 'package:flutter/material.dart';

class Employee {
  String id;
  String age;
  String adminPriv;
  String lastActivity;
  String name;
  String number;
  Employee(
      {@required this.id,
      @required this.name,
      @required this.number,
      this.adminPriv,
      this.age,
      this.lastActivity});
}
