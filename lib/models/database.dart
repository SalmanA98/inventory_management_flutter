import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import './products.dart';

final databaseReference = FirebaseDatabase.instance.reference();
final _auth = FirebaseAuth.instance;
String username;

getUser() async {
  User firebaseUser = _auth.currentUser;
  await firebaseUser?.reload();
  firebaseUser = _auth.currentUser;

  if (firebaseUser != null) {
    if (firebaseUser.email.startsWith('e')) {
      username = firebaseUser.email.substring(0, 7).toUpperCase();
    } else {
      username = firebaseUser.email.substring(0, 6).toUpperCase();
    }
  } else {
    username = null;
  }
}

//Done except username!
Future<void> uploadProduct(
    BuildContext context, Products product, String username) async {
  String _shopLocation;

  if (username.toLowerCase().startsWith('a')) {
    _shopLocation = username.substring(1, 2).toUpperCase();
  } else {
    _shopLocation = username.substring(2, 3).toUpperCase();
  }
  databaseReference
      .child(_shopLocation)
      .child('Products')
      .child(product.name)
      .set({
    'Price': product.price,
    'Qty': product.qty,
    'Last Change': 'Uploaded Product',
    'Last Changed By': username.toUpperCase(),
    'Last Changed On': DateTime.now().toString()
  }).then((result) {
    databaseReference
        .child(_shopLocation)
        .child('Employees')
        .child(username.toUpperCase())
        .update({
      'Last Activity': 'Uploaded ${product.name}',
      'Last Actvitiy Time':
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString(),
    });
  }).onError((error, stacktrace) {
    Fluttertoast.showToast(msg: error.toString());
  });
}

Future<void> getSaleInfo(
    BuildContext context, String date, String time, String shopLocation) async {
  List<Products> soldProducts = [];
  await databaseReference
      .child(shopLocation)
      .child('Sales')
      .child(date)
      .child(time)
      .once()
      .then((DataSnapshot datasnapshot) {
    Map<dynamic, dynamic> values = datasnapshot.value;
    values.forEach((key, value) {
      if (int.tryParse(key.toString()) != null) {
        value.forEach((product, details) {
          soldProducts.add(Products(
              name: product,
              price: details['Base Price'].toString(),
              qty: details['Qty'].toString()));
        });
      }
    });
  });
}
