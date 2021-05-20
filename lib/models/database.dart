import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
Future<void> uploadProduct(BuildContext context, Products product) async {
  databaseReference.child('D').child('Products').child(product.name).set({
    'Price': product.price,
    'Qty': product.qty,
    'Last Change': 'Uploaded Product',
    'Last Changed By': 'User',
    'Last Changed On': DateTime.now().toString()
  }).then((result) {
    print('Success');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Uploaded successfully!'),
      ),
    );
  }).onError((error, stacktrace) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
      ),
    );
  });
}

Future<void> getSaleInfo(BuildContext context, String date, String time) async {
  List<Products> soldProducts = [];
  await databaseReference
      .child('D')
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
