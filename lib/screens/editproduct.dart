import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  const EditProduct(
      {@required this.currentPrice,
      @required this.currentQty,
      @required this.productName});

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _qtyInput = TextEditingController();

  final _priceInput = TextEditingController();

  final List<PaymentDetails> _productDetails = [];

  bool _updateSuccess = false;

  Future<void> _updateProduct(String productName) async {
    int _qtyToUpdate = int.tryParse(_qtyInput.text.toString());
    int _priceToUpdate = int.tryParse(_priceInput.text.toString());

    if (_priceToUpdate != null || _qtyToUpdate != null) {
      if (_priceToUpdate != null) {
        databaseReference
            .child('D')
            .child('Products')
            .child(productName)
            .update({
          'Price': _priceToUpdate,
          'Last Change': 'Updated Price',
          'Last Changed By': 'User',
          'Last Changed On': DateTime.now().toString()
        }).then((result) {
          setState(() {
            _updateSuccess = true;
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
      } else if (_qtyToUpdate != null) {
        databaseReference
            .child('D')
            .child('Products')
            .child(productName)
            .update({
          'Qty': _qtyToUpdate,
          'Last Change': 'Updated Qty',
          'Last Changed By': 'User',
          'Last Changed On': DateTime.now().toString()
        }).then((result) {
          setState(() {
            _updateSuccess = true;
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
    }
  }

  void _deleteProduct(String productName) {
    databaseReference
        .child('D')
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
        body: Column(
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
                            color: Colors.black,
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
                                subtitle: const Text(
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
    ));
  }
}
