import 'package:flutter/material.dart';
import 'package:inventory_management/models/database.dart';
import 'package:inventory_management/models/paymentdetails.dart';
import 'package:inventory_management/screens/homepage.dart';
import 'package:inventory_management/widgets/customAppBar.dart';
import '../widgets/customTextField.dart';
import '../widgets/customButton.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProduct extends StatefulWidget {
  final String currentPrice;
  final String currentQty;
  final String productName;
  EditProduct(
      {@required this.currentPrice,
      @required this.currentQty,
      @required this.productName});

  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _qtyInput = TextEditingController();

  final _priceInput = TextEditingController();

  final List<PaymentDetails> productDetails = [];

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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Updated Price Successfully!'),
            ),
          );
        }).onError((error, stacktrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
            ),
          );
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Updated Qty Successfully!'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed Product Successfully!'),
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    productDetails
        .add(PaymentDetails(title: 'Name', value: widget.productName));
    productDetails.add(
        PaymentDetails(title: 'Current Price', value: widget.currentPrice));
    productDetails
        .add(PaymentDetails(title: 'Current Qty', value: widget.currentQty));
  }

  @override
  Widget build(BuildContext context) {
    var screenMaxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        body: GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
                title: 'Edit Product',
                subtitle: 'Update/Remove the product chosen'),
            Container(
                width: double.infinity,
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 15),
                alignment: Alignment.centerLeft,
                child: Text(
                  'Product Details',
                  style: GoogleFonts.openSans(
                    textStyle:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                )),
            ...productDetails.map((element) {
              return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          element.title,
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(element.value),
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
                child: Text(
                  'Update Product',
                  style: GoogleFonts.openSans(
                    textStyle:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        leading: Icon(Icons.info_outline),
                        title: Text('Leave the unchanged field blank')),
                  )),
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
            if (!_updateSuccess)
              CustomButton(
                buttonFunction: () => _updateProduct(widget.productName),
                buttonText: 'Update Product',
              ),
            if (_updateSuccess)
              CustomButton(
                buttonFunction: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => HomePage())),
                buttonText: 'Go Home',
              ),
            if (!_updateSuccess)
              CustomButton(
                buttonFunction: () => _deleteProduct(widget.productName),
                buttonText: 'Delete Product',
              )
          ],
        ),
      ),
    ));
  }
}
