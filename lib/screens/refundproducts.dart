import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/paymentdetails.dart';
import '../widgets/customButton.dart';
import '../widgets/customTextField.dart';
import '../widgets/customAppBar.dart';
import '../models/database.dart';
import '../models/products.dart';

class RefundProducts extends StatefulWidget {
  final String date;
  final String time;
  final String saleID;

  const RefundProducts(
      {@required this.date, @required this.time, @required this.saleID});

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
    await databaseReference
        .child('D')
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

  showError(String errormessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ERROR'),
            content: Text(errormessage),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  Future<void> _refundToDb(
      BuildContext context, Products product, bool refundedAll) async {
    String qtyToRefud = _qtyController.text;
    double priceForQty;
    double priceAfterDiscount;
    double priceAfterVat;
    double totalRefunded;
    double totalAfterRefund;
    int initialQty;

    if (refundedAll) {
      databaseReference
          .child('D')
          .child('Sales')
          .child(widget.date)
          .child(widget.time)
          .once()
          .then((result) {
        Map<dynamic, dynamic> values = result.value;
        values.forEach((prodNum, value) {
          if (int.tryParse(prodNum.toString()) != null) {
            if (value[product.name] != null) {
              //Update db
              setState(() {
                databaseReference
                    .child('D')
                    .child('Sales')
                    .child(widget.date)
                    .child(widget.time)
                    .child(prodNum)
                    .child(product.name)
                    .update({
                  'Qty': 0,
                  'Refunded': 'Yes',
                  'Refunded Qty': product.qty,
                });

                databaseReference
                    .child('D')
                    .child('Sales')
                    .child(widget.date)
                    .child(widget.time)
                    .update({
                  'Refunded Amount': _totalPrice,
                  'Total After Refund': 0,
                });

                _products.clear();
                _paymentDetails.clear();
                getSaleInfo(context, widget.date, widget.time);
              });
            }
          }
        });
      }).onError((error, stackTrace) => null);
    } else {
      if (qtyToRefud.isEmpty || int.tryParse(qtyToRefud) < 1) {
        showError('Refund Qty Should Be More Than 0!');
      } else {
        databaseReference
            .child('D')
            .child('Sales')
            .child(widget.date)
            .child(widget.time)
            .once()
            .then((result) {
          Map<dynamic, dynamic> values = result.value;
          values.forEach((prodNum, value) {
            if (int.tryParse(prodNum.toString()) != null) {
              if (value[product.name] != null) {
                int finalQty =
                    int.tryParse(product.qty) - int.tryParse(qtyToRefud);

                //Calculations
                _discount = _discount.substring(0, _discount.length - 1);

                _vat = _vat.substring(0, _vat.length - 1);
                priceForQty =
                    double.tryParse(product.price) * int.tryParse(product.qty);
                //If there is discount
                if (int.tryParse(_discount) > 0) {
                  priceAfterDiscount = priceForQty -
                      ((priceForQty * int.tryParse(_discount)) / 100);
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
                totalRefunded = priceAfterVat + double.tryParse(_refundedPrice);
                totalAfterRefund = double.tryParse(_totalPrice) - totalRefunded;

                //Update db
                setState(() {
                  databaseReference
                      .child('D')
                      .child('Sales')
                      .child(widget.date)
                      .child(widget.time)
                      .child(prodNum)
                      .child(product.name)
                      .update({
                    'Qty': finalQty,
                    'Refunded': finalQty == 0 ? 'Yes' : 'Partial',
                    'Refunded Qty': qtyToRefud,
                  }).then((_) {
                    databaseReference
                        .child('D')
                        .child('Sales')
                        .child(widget.date)
                        .child(widget.time)
                        .update({
                      'Refunded Amount': totalRefunded,
                      'Total After Refund': totalAfterRefund,
                    }).then((_) {
                      databaseReference
                          .child('D')
                          .child('Products')
                          .child(product.name)
                          .child('Qty')
                          .once()
                          .then((result) {
                            initialQty = int.tryParse(result.value.toString());
                          })
                          .then((_) => databaseReference
                                  .child('D')
                                  .child('Products')
                                  .child(product.name)
                                  .update({
                                'Qty': initialQty +
                                    int.tryParse(qtyToRefud.toString())
                              }))
                          .then((_) {
                            _products.clear();
                            _paymentDetails.clear();
                            getSaleInfo(context, widget.date, widget.time);

                            Fluttertoast.showToast(
                                msg: 'Refund Sucess',
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
        }).onError((error, stackTrace) => null);
      }
    }
  }

  @override
  void initState() {
    _getSaleInfo(context, widget.date, widget.time);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
              needBackButton: true,
              title: 'Refund Products',
              subtitle: 'Sale ID: ${widget.saleID}'),
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
                              title: Text(
                                  'Refund should be completed by admins only'),
                            )),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      width: double.infinity,
                      padding: EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Payment Details',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
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
                                  Text(
                                    element.title,
                                    style: GoogleFonts.openSans(
                                      textStyle: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(element.value),
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
                              Text(
                                'Choose Products',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
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
                                              color: Colors.white, width: 2.0),
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
                                              Text(
                                                product.name,
                                                style: GoogleFonts.openSans(
                                                  textStyle: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Text('Price: ${product.price}'),
                                              Text('Qty: ${product.qty}'),
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
                                leading: Icon(Icons.info_outline),
                                title: _products.isEmpty
                                    ? Text('All products have been refunded')
                                    : Text('This will refund all the products'),
                              )),
                        ),
                      ),
                    Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
                                ? _refundToDb(context, _productToRefund, false)
                                : _refundToDb(context, _productToRefund, true),
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
    );
  }
}
