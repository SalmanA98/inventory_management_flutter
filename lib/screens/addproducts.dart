import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../widgets/customButton.dart';
import '../widgets/customTextField.dart';
import '../widgets/customAppBar.dart';
import '../models/database.dart';
import '../models/products.dart';

class AddProducts extends StatefulWidget {
  final String _username;
  const AddProducts(this._username);
  @override
  _AddProductsState createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  final _nameInput = TextEditingController();
  final _priceInput = TextEditingController();
  final _qtyInput = TextEditingController();

  void _uploadData() {
    if (_nameInput.text.isEmpty ||
        _priceInput.text.isEmpty ||
        _qtyInput.text.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Fields cannot be empty',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    } else {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.WARNING,
        borderSide: BorderSide(color: Theme.of(context).accentColor, width: 2),
        width: double.infinity,
        buttonsBorderRadius: BorderRadius.all(Radius.circular(2)),
        headerAnimationLoop: true,
        useRootNavigator: true,
        animType: AnimType.BOTTOMSLIDE,
        title: 'Confirm Upload',
        desc:
            'Are you sure you want to add the product: ${_nameInput.text}? This cannot be undone once you press \'confirm\'.',
        dismissOnBackKeyPress: true,
        btnCancelOnPress: () {},
        btnOkText: 'Confirm',
        btnOkOnPress: () {
          //Fix username for last changed by
          uploadProduct(
              context,
              Products(
                name: _nameInput.text,
                price: _priceInput.text,
                qty: _qtyInput.text,
              ),
              widget._username);

          setState(() {
            _nameInput.clear();
            _priceInput.clear();
            _qtyInput.clear();
          });
          WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
          Fluttertoast.showToast(
              msg: 'Added product successfully!',
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1);
        },
      )..show();
    }
  }

  @override
  void dispose() {
    _nameInput.dispose();
    _priceInput.dispose();
    _qtyInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        child: CustomButton(
          buttonFunction: _uploadData,
          buttonText: 'Upload Product',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
              title: 'Add Products',
              subtitle: 'Enter the product details!',
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => WidgetsBinding.instance.focusManager.primaryFocus
                    ?.unfocus(),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(top: 50),
                        width: double.infinity,
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.all(10),
                              child: CustomTextField(
                                  textController: _nameInput,
                                  textIcon:
                                      Icon(Icons.horizontal_split_outlined),
                                  textHint: 'Product Name'),
                            ),
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
                          ],
                        ),
                      )
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
