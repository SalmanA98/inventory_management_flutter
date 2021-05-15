import 'package:flutter/material.dart';
import '../widgets/customButton.dart';
import '../widgets/customTextField.dart';
import '../widgets/customAppBar.dart';
import '../models/database.dart';
import '../models/products.dart';

class AddProducts extends StatefulWidget {
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
      return;
    }
    //Fix username for last changed by
    uploadProduct(
        context,
        Products(
            name: _nameInput.text,
            price: _priceInput.text,
            qty: _qtyInput.text));
    setState(() {
      _nameInput.clear();
      _priceInput.clear();
      _qtyInput.clear();
    });
    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
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
    var screenMaxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: 'Add Products',
            subtitle: 'Enter the product details!',
          ),
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
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(top: 50),
                      width: double.infinity,
                      child: Column(
                        children: [
                          CustomTextField(
                              textController: _nameInput,
                              textIcon: Icon(Icons.horizontal_split_outlined),
                              textHint: 'Product Name'),
                          SizedBox(
                            height: screenMaxHeight * 0.02,
                          ),
                          CustomTextField(
                            textController: _priceInput,
                            textHint: 'Price',
                            textIcon: Icon(Icons.attach_money_outlined),
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(
                            height: screenMaxHeight * 0.02,
                          ),
                          CustomTextField(
                            textController: _qtyInput,
                            textIcon: Icon(Icons.donut_small_outlined),
                            textHint: 'Quantity',
                            maximumLength: 3,
                            keyboardType: TextInputType.number,
                          ),
                          SizedBox(
                            height: screenMaxHeight * 0.02,
                          ),
                          CustomButton(
                            buttonFunction: _uploadData,
                            buttonText: 'Upload Product',
                          )
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
    );
  }
}
