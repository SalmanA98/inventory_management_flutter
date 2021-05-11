import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory_management/screens/refundproducts.dart';
import 'package:inventory_management/widgets/customTextField.dart';
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

//get from db
Future<List<Products>> getAllProducts(BuildContext context) async {
  List<Products> products = [];
  await databaseReference
      .child('D')
      .child('Products')
      .once()
      .then((DataSnapshot dataSnapshot) {
    Map<dynamic, dynamic> values = dataSnapshot.value;
    values.forEach((key, value) {
      products.add(Products(
          name: key,
          price: value['Price'].toString(),
          qty: value['Qty'].toString()));
    });
  }).onError((error, stackTrace) {
    print(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.toString()),
      ),
    );
  });
  return products;
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

Future<void> authenticateSale(BuildContext context, String saleID) async {
  String year = saleID.substring(0, 4);
  String month = saleID.substring(4, 6);
  String day = saleID.substring(6, 8);
  String hr = saleID.substring(8, 10);
  String min = saleID.substring(10, 12);
  String sec = saleID.substring(12, 14);
  String date = '$year-$month-$day';
  String time = '$hr:$min:$sec';

  DataSnapshot dataSnapshot = await databaseReference
      .child('D')
      .child('Sales')
      .child(date)
      .child(time)
      .child('Sale ID')
      .once();
  if (dataSnapshot.value != null) {
    if (dataSnapshot.value == saleID) {
      databaseReference
          .child('D')
          .child('Sales')
          .child(date)
          .child(time)
          .child('Payment Method')
          .once()
          .then((paymentMethod) {
        if (paymentMethod.value.toString() == 'Cash') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Sale ID matched successfully!'),
            ),
          );
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => RefundProducts(
                        date: date,
                        time: time,
                        saleID: saleID,
                      )));
        }
      }).onError((error, stackTrace) => null);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Sale ID does not exist!'),
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sale does not exist!'),
      ),
    );
  }
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
        print('AFTER TYPE CHECK: $key');
        value.forEach((product, details) {
          print(
              'name: $product\nprice: ${details['Base Price']}\nqty: ${details['Qty']}');
          soldProducts.add(Products(
              name: product,
              price: details['Base Price'].toString(),
              qty: details['Qty'].toString()));
        });
      }
    });
  });
}
