import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:intl/intl.dart';
import '../models/database.dart';
import '../models/paymentdetails.dart';
import './homepage.dart';
import '../widgets/customAppBar.dart';
import '../widgets/customTextField.dart';
import '../widgets/customButton.dart';

class EditProduct extends StatefulWidget {
  final String currentPrice;
  final String currentQty;
  final String productName;
  final String currentUser;
  const EditProduct(
      {@required this.currentPrice,
      @required this.currentQty,
      @required this.productName,
      @required this.currentUser});

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _qtyInput = TextEditingController();

  final _priceInput = TextEditingController();

  final List<PaymentDetails> _productDetails = [];

  bool _updateSuccess = false;

  Future<void> _updateProduct(String productName) async {
    String _shopLocation;

    if (widget.currentUser.toLowerCase().startsWith('a')) {
      _shopLocation = widget.currentUser.substring(1, 2).toUpperCase();
    } else {
      _shopLocation = widget.currentUser.substring(2, 3).toUpperCase();
    }
    int _qtyToUpdate = int.tryParse(_qtyInput.text.toString());
    int _priceToUpdate = int.tryParse(_priceInput.text.toString());

    if (_priceToUpdate != null || _qtyToUpdate != null) {
      showDialog(
          context: context,
          builder: (_) => NetworkGiffyDialog(
                image: Image.asset('assets/images/logo.png'),
                title: Text('Confirm Changes?',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
                description: Text(
                  'This cannot be undone.\nAre you sure you want to update: $productName?',
                  textAlign: TextAlign.center,
                ),
                entryAnimation: EntryAnimation.BOTTOM_LEFT,
                onOkButtonPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(context);

                  if (_priceToUpdate != null) {
                    databaseReference
                        .child(_shopLocation)
                        .child('Products')
                        .child(productName)
                        .update({
                      'Price': _priceToUpdate,
                      'Last Change': 'Updated Price',
                      'Last Changed By': widget.currentUser.toUpperCase(),
                      'Last Changed On': DateTime.now().toString()
                    }).then((result) {
                      databaseReference
                          .child(_shopLocation)
                          .child('Employees')
                          .child(username.toUpperCase())
                          .update({
                        'Last Activity': 'Updated Price $productName',
                        'Last Actvitiy Time': DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(DateTime.now())
                            .toString(),
                      });
                      setState(() {
                        _updateSuccess = true;
                        _productDetails[1].value = _priceToUpdate.toString();
                      });
                      Fluttertoast.showToast(
                          msg: 'Updated Price Successfully',
                          gravity: ToastGravity.CENTER,
                          toastLength: Toast.LENGTH_SHORT,
                          timeInSecForIosWeb: 1);
                    }).onError((error, stacktrace) {
                      Fluttertoast.showToast(
                          msg: error.toString(),
                          gravity: ToastGravity.CENTER,
                          toastLength: Toast.LENGTH_SHORT,
                          timeInSecForIosWeb: 1);
                    });
                  }
                  if (_qtyToUpdate != null) {
                    databaseReference
                        .child(_shopLocation)
                        .child('Products')
                        .child(productName)
                        .update({
                      'Qty': _qtyToUpdate,
                      'Last Change': 'Updated Qty',
                      'Last Changed By': widget.currentUser.toUpperCase(),
                      'Last Changed On': DateTime.now().toString()
                    }).then((result) {
                      databaseReference
                          .child(_shopLocation)
                          .child('Employees')
                          .child(username.toUpperCase())
                          .update({
                        'Last Activity': 'Updated Qty $productName',
                        'Last Actvitiy Time': DateFormat('yyyy-MM-dd HH:mm:ss')
                            .format(DateTime.now())
                            .toString(),
                      });
                      setState(() {
                        _updateSuccess = true;
                        _productDetails[2].value = _qtyToUpdate.toString();
                      });
                      Fluttertoast.showToast(
                          msg: 'Updated Qty Successfully',
                          gravity: ToastGravity.CENTER,
                          toastLength: Toast.LENGTH_SHORT,
                          timeInSecForIosWeb: 1);
                    }).onError((error, stacktrace) {
                      Fluttertoast.showToast(
                          msg: error.toString(),
                          gravity: ToastGravity.CENTER,
                          toastLength: Toast.LENGTH_SHORT,
                          timeInSecForIosWeb: 1);
                    });
                  }
                },
                onCancelButtonPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(context);
                },
              ));
    } else {
      Fluttertoast.showToast(msg: 'Fields are empty! Not updated.');
    }
  }

  Future<void> _deleteProduct(String productName) async {
    String _shopLocation;

    if (widget.currentUser.toLowerCase().startsWith('a')) {
      _shopLocation = widget.currentUser.substring(1, 2).toUpperCase();
    } else {
      _shopLocation = widget.currentUser.substring(2, 3).toUpperCase();
    }
    showDialog(
        context: context,
        builder: (_) => NetworkGiffyDialog(
              image: Image.asset('assets/images/logo.png'),
              title: Text('Confirm Delete?',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
              description: Text(
                'This cannot be undone.\nAre you sure you want to delete product: $productName?',
                textAlign: TextAlign.center,
              ),
              entryAnimation: EntryAnimation.BOTTOM_LEFT,
              onOkButtonPressed: () {
                Navigator.of(context, rootNavigator: true).pop(context);
                databaseReference
                    .child(_shopLocation)
                    .child('Products')
                    .child(productName)
                    .remove()
                    .then((_) {
                  setState(() {
                    _updateSuccess = true;
                  });
                  Fluttertoast.showToast(
                      msg: 'Removed product -> $productName!',
                      gravity: ToastGravity.CENTER,
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 1);
                }).onError((error, stacktrace) {
                  Fluttertoast.showToast(
                      msg: error.toString(),
                      gravity: ToastGravity.CENTER,
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 1);
                });
              },
              onCancelButtonPressed: () {
                Navigator.of(context, rootNavigator: true).pop(context);
              },
            ));
  }

  @override
  void initState() {
    super.initState();
    _productDetails
        .add(PaymentDetails(title: 'Name', value: widget.productName));
    _productDetails.add(
        PaymentDetails(title: 'Current Price', value: widget.currentPrice));
    _productDetails
        .add(PaymentDetails(title: 'Current Qty', value: widget.currentQty));
  }

  @override
  void dispose() {
    _qtyInput.dispose();
    _priceInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          CustomAppBar(
              title: 'Edit Product',
              subtitle: 'Update/Remove the product chosen'),
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
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(top: 15),
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: const Text(
                            'Product Details',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        )),
                    ..._productDetails.map((element) {
                      return Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(10),
                          child: Column(children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              color: Theme.of(context).primaryColor,
                            )
                          ]));
                    }).toList(),
                    Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(top: 15),
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: const Text(
                            'Update Product',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        )),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        child: Card(
                          elevation: 3,
                          child: Container(
                              padding: EdgeInsets.all(10),
                              child: ListTile(
                                  leading: const Icon(Icons.info_outline),
                                  title: const Text(
                                      'Leave the unchanged data field blank'))),
                        )),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: CustomTextField(
                        textController: _priceInput,
                        textHint: 'Price',
                        textIcon: Icon(Icons.attach_money_outlined),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: CustomTextField(
                        textController: _qtyInput,
                        textIcon: Icon(Icons.donut_small_outlined),
                        textHint: 'Quantity',
                        maximumLength: 3,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    if (!_updateSuccess)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: CustomButton(
                          buttonFunction: () =>
                              _updateProduct(widget.productName),
                          buttonText: 'Update Product',
                        ),
                      ),
                    if (_updateSuccess)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: CustomButton(
                          buttonFunction: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => HomePage())),
                          buttonText: 'Go Home',
                        ),
                      ),
                    if (!_updateSuccess)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: CustomButton(
                          buttonFunction: () =>
                              _deleteProduct(widget.productName),
                          buttonText: 'Delete Product',
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
