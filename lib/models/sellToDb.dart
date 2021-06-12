import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inventory_management/screens/completedSale.dart';

import 'products.dart';
import 'database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WriteSaleToDb {
  final List<Products> finalItems;
  final String customerName;
  final String customerNum;
  final String discount;
  final String vat;
  final String paymentMethod;
  final String employeeID;
  bool saleSuccess = false;
  final String date =
      DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  final String time = DateFormat('HH:mm:ss').format(DateTime.now()).toString();

  WriteSaleToDb(
      {@required this.finalItems,
      @required this.customerName,
      @required this.customerNum,
      @required this.discount,
      @required this.employeeID,
      @required this.paymentMethod,
      @required this.vat});

  double _calculatePrice() {
    double totalProdPrice = 0.0;
    double sum = 0.0;
    double vatDouble;
    int discountInt = int.tryParse(discount);

    for (int i = 0; i < finalItems.length; i++) {
      totalProdPrice += double.tryParse(finalItems[i].qty) *
          double.tryParse(finalItems[i].price);
    }
    if (vat == '5%') {
      vatDouble = (totalProdPrice) * (5.0 / 100.0);
      sum = vatDouble + totalProdPrice;
    } else {
      sum = 0 + totalProdPrice;
    }

    if (discountInt > 0) {
      sum = sum * ((100 - discountInt) / 100);
    } else {
      sum += 0;
    }

    return sum;
  }

  Future<void> updateQtyDB() async {}

  Future<void> processSale(BuildContext context) async {
    String shopLocation;
    String saleID;
    if (employeeID.toLowerCase().startsWith('a')) {
      shopLocation = employeeID.substring(1, 2).toUpperCase();
    } else {
      shopLocation = employeeID.substring(2, 3).toUpperCase();
    }
    bool employeeExists = false;
    //check if employee exists
    databaseReference
        .child(shopLocation)
        .child('Employees')
        .once()
        .then((results) {
      Map<dynamic, dynamic> values = results.value;

      values.forEach((key, value) {
        if (employeeID.toUpperCase() == key.toString().toUpperCase() ||
            employeeID.toLowerCase().startsWith('a')) {
          employeeExists = true;
          int initalQty;
          saleID = date.replaceAll('-', '') +
              time.replaceAll(':', '') +
              customerName.substring(0, 1);
          double totalPrice = _calculatePrice();
          databaseReference
              .child(shopLocation)
              .child('Sales')
              .child(date)
              .child(time)
              .update({
            'Customer Name': customerName,
            'Customer Number': customerNum,
            'Discount': discount + '%',
            'VAT': vat,
            'Payment Method': paymentMethod,
            'Seller': employeeID.toLowerCase().startsWith('a')
                ? 'Super Admin(${employeeID.toUpperCase()})'
                : employeeID.toUpperCase(),
            'Number of products': finalItems.length,
            'Final Price': double.tryParse(totalPrice.toStringAsFixed(2)),
            'Refunded Amount': 0,
            'Sale ID': saleID,
            'Total After Refund':
                double.tryParse(totalPrice.toStringAsFixed(2)),
          }).then((_) {
            for (int i = 0; i < finalItems.length; i++) {
              databaseReference
                  .child(shopLocation)
                  .child('Sales')
                  .child(date)
                  .child(time)
                  .child((i + 1).toString())
                  .child(finalItems[i].name)
                  .update({
                'Base Price': double.tryParse(
                    int.tryParse(finalItems[i].price).toStringAsFixed(2)),
                'Qty': int.tryParse(finalItems[i].qty),
                'Refunded': 'No',
                'Refunded Qty': 0,
              }).then((_) {
                databaseReference
                    .child(shopLocation)
                    .child('Products')
                    .child(finalItems[i].name)
                    .child('Qty')
                    .once()
                    .then((result) {
                  initalQty = int.tryParse(result.value.toString());
                  databaseReference
                      .child(shopLocation)
                      .child('Products')
                      .child(finalItems[i].name)
                      .update({
                    'Qty': initalQty - int.tryParse(finalItems[i].qty)
                  }).then((value) {
                    if (employeeID.toLowerCase().startsWith('e')) {
                      databaseReference
                          .child(shopLocation)
                          .child('Employees')
                          .child(employeeID)
                          .update({
                        'Last Activity Time': date + ' ' + time,
                        'Last Activity': 'Sale $saleID'
                      });
                    }
                  });
                });
              });
            }
          }).then((value) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CompletedSale(
                  details: [
                    {'Customer Name': customerName},
                    {'Customer Number': customerNum},
                    {'Date': date},
                    {'Time': time},
                    {'Items Purchased': finalItems},
                    {'VAT': vat},
                    {'Discount': discount},
                    {'Payment Method': paymentMethod},
                    {
                      'Employee ID': employeeID.toLowerCase().startsWith('a')
                          ? 'Super Admin ($employeeID)'
                          : employeeID
                    },
                    {'Sale ID': saleID},
                    {'Total Price': totalPrice.toStringAsFixed(2)}
                  ],
                ),
              ),
            );
            Fluttertoast.showToast(
                msg: 'Sale Successful!',
                gravity: ToastGravity.CENTER,
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                fontSize: 16.0);
          });
        }
      });
      if (!employeeExists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("No Such Employee!"),
          behavior: SnackBarBehavior.floating,
          duration: Duration(milliseconds: 1000),
        ));
      }
    }).catchError((error, stackTrace) => Fluttertoast.showToast(
            msg: error.toString(),
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            fontSize: 16.0));
  }
}
