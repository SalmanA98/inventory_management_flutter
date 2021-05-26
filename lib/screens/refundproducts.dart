import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:intl/intl.dart';
import '../models/paymentdetails.dart';
import '../widgets/customButton.dart';
import '../widgets/customTextField.dart';
import '../widgets/customAppBar.dart';
import '../models/database.dart';
import '../models/products.dart';

class RefundProducts extends StatefulWidget {
  final String _date;
  final String _time;
  final String _saleID;
  final String _username;

  const RefundProducts(this._date, this._time, this._saleID, this._username);

  @override
  _RefundProductsState createState() => _RefundProductsState();
}

class _RefundProductsState extends State<RefundProducts> {
  List<Products> _products = [];
  List<PaymentDetails> _paymentDetails = [];
  String _discount;
  String _vat;
  String _totalPrice;
  String _refundedPrice;

  Products _productToRefund;
  bool _refundEach = false;
  int _selectedIndex = -1;
  final TextEditingController _qtyController = new TextEditingController();

  Future<void> _getSaleInfo(
      BuildContext context, String date, String time) async {
    String _shopLocation;

    if (widget._username.toLowerCase().startsWith('a')) {
      _shopLocation = widget._username.substring(1, 2).toUpperCase();
    } else {
      _shopLocation = widget._username.substring(2, 3).toUpperCase();
    }

    await databaseReference
        .child(_shopLocation)
        .child('Sales')
        .child(date)
        .child(time)
        .once()
        .then((DataSnapshot datasnapshot) {
      Map<dynamic, dynamic> values = datasnapshot.value;
      values.forEach((key, value) {
        if (int.tryParse(key.toString()) == null &&
            key.toString() != 'Refund Details') {
          print(key);
          if (key == 'Discount') {
            _discount = value;
          }
          if (key == 'VAT') {
            _vat = value;
          }
          if (key == 'Refunded Amount') {
            _refundedPrice = value.toString();
          }
          if (key == 'Total After Refund') {
            _totalPrice = value.toString();
          }
          setState(() {
            _paymentDetails.add(
                PaymentDetails(title: key.toString(), value: value.toString()));
          });
        }
        if (int.tryParse(key.toString()) != null) {
          value.forEach((product, details) {
            if (details['Refunded'].toString() != 'Yes') {
              setState(() {
                _products.add(Products(
                    name: product,
                    price: details['Base Price'].toString(),
                    qty: details['Qty'].toString()));
              });
            }
          });
        }
      });
    });
  }

  void _onSelectedItem(int index, Products chosenProduct) {
    setState(() {
      _selectedIndex = index;
      _productToRefund = chosenProduct;
    });
  }

  Future<void> _refundToDb(
      BuildContext context, Products product, bool refundedAll) async {
    String _shopLocation;

    if (widget._username.toLowerCase().startsWith('a')) {
      _shopLocation = widget._username.substring(1, 2).toUpperCase();
    } else {
      _shopLocation = widget._username.substring(2, 3).toUpperCase();
    }

    String qtyToRefud = _qtyController.text;
    double priceForQty;
    double priceAfterDiscount;
    double priceAfterVat;
    double totalRefunded;
    double totalAfterRefund;
    int initialQty;

    showDialog(
        context: context,
        builder: (_) => NetworkGiffyDialog(
              image: Image.asset('assets/images/logo.png'),
              title: Text('Confirm Refund?',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
              description: Text(
                'This cannot be undone.\nAre you sure?',
                textAlign: TextAlign.center,
              ),
              entryAnimation: EntryAnimation.BOTTOM_LEFT,
              onOkButtonPressed: () {
                Navigator.of(context, rootNavigator: true).pop(context);
                if (refundedAll) {
                  databaseReference
                      .child(_shopLocation)
                      .child('Sales')
                      .child(widget._date)
                      .child(widget._time)
                      .once()
                      .then((result) {
                    Map<dynamic, dynamic> values = result.value;
                    values.forEach((prodNum, value) {
                      if (int.tryParse(prodNum.toString()) != null) {
                        if (value[product.name] != null) {
                          //Update db
                          setState(() {
                            databaseReference
                                .child(_shopLocation)
                                .child('Sales')
                                .child(widget._date)
                                .child(widget._time)
                                .child(prodNum)
                                .child(product.name)
                                .update({
                              'Qty': 0,
                              'Refunded': 'Yes',
                              'Refunded Qty': product.qty,
                            });

                            databaseReference
                                .child(_shopLocation)
                                .child('Sales')
                                .child(widget._date)
                                .child(widget._time)
                                .update({
                              'Refunded Amount': _totalPrice,
                              'Total After Refund': 0,
                            });

                            _products.clear();
                            _paymentDetails.clear();
                            getSaleInfo(context, widget._date, widget._time,
                                _shopLocation);
                          });
                        }
                      }
                    });
                  }).onError((error, stackTrace) => null);
                } else {
                  if (qtyToRefud.isEmpty || int.tryParse(qtyToRefud) < 1) {
                    Fluttertoast.showToast(
                        msg: 'Refund qty should be more than 0!',
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 1,
                        fontSize: 16.0);
                  } else {
                    databaseReference
                        .child(_shopLocation)
                        .child('Sales')
                        .child(widget._date)
                        .child(widget._time)
                        .once()
                        .then((result) {
                      Map<dynamic, dynamic> values = result.value;
                      values.forEach((prodNum, value) {
                        if (int.tryParse(prodNum.toString()) != null) {
                          if (value[product.name] != null) {
                            int finalQty = int.tryParse(product.qty) -
                                int.tryParse(qtyToRefud);

                            //Calculations
                            _discount =
                                _discount.substring(0, _discount.length - 1);

                            _vat = _vat.substring(0, _vat.length - 1);
                            priceForQty = double.tryParse(product.price) *
                                int.tryParse(product.qty);
                            //If there is discount
                            if (int.tryParse(_discount) > 0) {
                              priceAfterDiscount = priceForQty -
                                  ((priceForQty * int.tryParse(_discount)) /
                                      100);
                            } else {
                              priceAfterDiscount = priceForQty;
                            }
                            //If there is vat
                            if (int.tryParse(_vat) > 0) {
                              priceAfterVat = priceAfterDiscount +
                                  ((priceForQty * int.tryParse(_vat)) / 100);
                            } else {
                              priceAfterVat = priceAfterDiscount;
                            }
                            totalRefunded =
                                priceAfterVat + double.tryParse(_refundedPrice);
                            totalAfterRefund =
                                double.tryParse(_totalPrice) - totalRefunded;

                            //Update db
                            setState(() {
                              databaseReference
                                  .child(_shopLocation)
                                  .child('Sales')
                                  .child(widget._date)
                                  .child(widget._time)
                                  .child(prodNum)
                                  .child(product.name)
                                  .update({
                                'Qty': finalQty,
                                'Refunded': finalQty == 0 ? 'Yes' : 'Partial',
                                'Refunded Qty': qtyToRefud,
                              }).then((_) {
                                databaseReference
                                    .child(_shopLocation)
                                    .child('Sales')
                                    .child(widget._date)
                                    .child(widget._time)
                                    .update({
                                  'Refunded Amount': totalRefunded,
                                  'Total After Refund': totalAfterRefund,
                                }).then((_) {
                                  databaseReference
                                      .child(_shopLocation)
                                      .child('Products')
                                      .child(product.name)
                                      .child('Qty')
                                      .once()
                                      .then((result) {
                                        initialQty = int.tryParse(
                                            result.value.toString());
                                      })
                                      .then((_) => databaseReference
                                              .child(_shopLocation)
                                              .child('Products')
                                              .child(product.name)
                                              .update({
                                            'Qty': initialQty +
                                                int.tryParse(
                                                    qtyToRefud.toString())
                                          }))
                                      .then((_) {
                                        databaseReference
                                            .child(_shopLocation)
                                            .child('Employees')
                                            .child(username.toUpperCase())
                                            .update({
                                          'Last Activity':
                                              'Refunded ${widget._saleID}',
                                          'Last Activity Time':
                                              DateFormat('yyyy-MM-dd HH:mm:ss')
                                                  .format(DateTime.now())
                                                  .toString(),
                                        });
                                        _products.clear();
                                        _paymentDetails.clear();
                                        getSaleInfo(context, widget._date,
                                            widget._time, _shopLocation);

                                        Fluttertoast.showToast(
                                            msg: 'Refund Success',
                                            gravity: ToastGravity.CENTER,
                                            toastLength: Toast.LENGTH_SHORT,
                                            timeInSecForIosWeb: 1,
                                            fontSize: 16.0);
                                      });
                                });
                              });
                            });
                          }
                        }
                      });
                    }).onError((error, stackTrace) => Fluttertoast.showToast(
                            msg: error.toString(),
                            toastLength: Toast.LENGTH_SHORT,
                            timeInSecForIosWeb: 1,
                            fontSize: 16.0));
                  }
                }
              },
              onCancelButtonPressed: () {
                Navigator.of(context, rootNavigator: true).pop(context);
              },
            ));
  }

  @override
  void initState() {
    super.initState();
    _getSaleInfo(context, widget._date, widget._time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
                needBackButton: true,
                title: 'Refund Products',
                subtitle: 'Sale ID: ${widget._saleID}'),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        child: Card(
                          elevation: 3,
                          child: Container(
                              padding: EdgeInsets.all(10),
                              child: ListTile(
                                leading: Icon(Icons.info_outline),
                                subtitle: const Text(
                                    'Refund should be completed by admins only'),
                              )),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: const Text(
                            'Payment Details',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      ..._paymentDetails.map((element) {
                        return Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(
                                        element.title,
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    FittedBox(
                                        fit: BoxFit.contain,
                                        child: Text(element.value)),
                                  ],
                                ),
                                Divider(
                                  color: Colors.black,
                                )
                              ],
                            ));
                      }),
                      Container(
                          margin: EdgeInsets.only(top: 10),
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_products.isNotEmpty)
                                FittedBox(
                                  fit: BoxFit.contain,
                                  child: const Text(
                                    'Choose Products',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              if (_products.isNotEmpty)
                                Switch.adaptive(
                                    value: _refundEach,
                                    onChanged: (val) {
                                      setState(() {
                                        _refundEach = val;
                                      });
                                    })
                            ],
                          )),
                      if (_refundEach && _products.isNotEmpty)
                        ..._products.map(
                          (product) {
                            return Container(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                width: double.infinity,
                                child: GestureDetector(
                                  onTap: () {
                                    _onSelectedItem(
                                        _products.indexOf(product), product);
                                  },
                                  child: Card(
                                    shape: _selectedIndex != null &&
                                            _selectedIndex ==
                                                _products.indexOf(product)
                                        ? new RoundedRectangleBorder(
                                            side: new BorderSide(
                                                color: Colors.blue, width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(4.0))
                                        : new RoundedRectangleBorder(
                                            side: new BorderSide(
                                                color: Colors.white,
                                                width: 2.0),
                                            borderRadius:
                                                BorderRadius.circular(4.0)),
                                    elevation: 5,
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.all(5),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    product.name,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                                FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: Text(
                                                        'Price: ${product.price}')),
                                                FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: Text(
                                                        'Qty: ${product.qty}')),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ));
                          },
                        ),
                      if (_refundEach && _products.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(10),
                          child: CustomTextField(
                              textController: _qtyController,
                              textHint: 'Qty to refund',
                              keyboardType: TextInputType.number,
                              textIcon: Icon(Icons.refresh)),
                        ),
                      if (!_refundEach)
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          width: double.infinity,
                          child: Card(
                            elevation: 3,
                            child: Container(
                                padding: EdgeInsets.all(10),
                                child: ListTile(
                                  leading: const Icon(Icons.info_outline),
                                  subtitle: _products.isEmpty
                                      ? const Text(
                                          'All products have been refunded')
                                      : const Text(
                                          'This will refund all the products'),
                                )),
                          ),
                        ),
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          child: Visibility(
                            visible: _products.isEmpty
                                ? false
                                : _refundEach
                                    ? _selectedIndex >= 0
                                        ? true
                                        : false
                                    : true,
                            child: CustomButton(
                              buttonFunction: () => _refundEach
                                  ? _refundToDb(
                                      context, _productToRefund, false)
                                  : _refundToDb(
                                      context, _productToRefund, true),
                              buttonText: 'Confirm Refund',
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
