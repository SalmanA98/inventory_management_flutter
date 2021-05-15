import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/customButton.dart';
import '../widgets/customTextField.dart';
import '../widgets/customAppBar.dart';
import '../models/database.dart';
import '../models/sellToDb.dart';
import '../models/products.dart';

class CustomerInfo extends StatefulWidget {
  final List<Products> cartProducts;
  const CustomerInfo(this.cartProducts);

  @override
  _CustomerInfoState createState() => _CustomerInfoState();
}

class _CustomerInfoState extends State<CustomerInfo> {
  final TextEditingController _customerNameInput = TextEditingController();

  final TextEditingController _customerNumInput = TextEditingController();

  final TextEditingController _discInput = TextEditingController();

  final TextEditingController _employeeIdInput = TextEditingController();

  bool _isCurrentEmployee = false;
  String _vat;
  String _paymentMethod;
  String _currentEmployeeID;

  int _valueVat = -1;
  int _valuePM = -1;

  final List<String> _vatList = const ['VAT', 'No VAT'];
  final List<String> _paymentList = const ['Cash', 'Card'];

  void _onVatChoice(int value) {
    switch (value) {
      case -1:
        Fluttertoast.showToast(
            msg: 'Choose VAT/No Vat!',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1);
        break;
      case 0:
        _vat = '5%';
        break;
      case 1:
        _vat = '0%';
        break;
    }
  }

  void _onPaymentChoice(int value) {
    switch (value) {
      case -1:
        Fluttertoast.showToast(
            msg: 'Choose Payment Method!',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1);
        break;
      case 0:
        _paymentMethod = 'Cash';
        break;
      case 1:
        _paymentMethod = 'Card';
        break;
    }
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

  void _completeSale() {
    if (!_isCurrentEmployee) {
      _employeeIdInput.text = _currentEmployeeID.toString().toUpperCase();
      print(_employeeIdInput.text);
    }
    if (_customerNameInput.text.isEmpty ||
        _customerNumInput.text.isEmpty ||
        _vat.isEmpty ||
        _paymentMethod.isEmpty ||
        _employeeIdInput.text.isEmpty ||
        _discInput.text.isEmpty) {
      showError('Fields/Choices cannot be empty');
    } else if (_customerNumInput.text.length < 10) {
      showError('Number should be of 10-digits! (0501234567)');
    } else {
      var sell = WriteSaleToDb(
          customerName: _customerNameInput.text,
          customerNum: _customerNumInput.text,
          discount: _discInput.text,
          employeeID: _employeeIdInput.text,
          finalItems: widget.cartProducts,
          paymentMethod: _paymentMethod,
          vat: _vat);
      sell.processSale(context);
    }
  }

  @override
  void initState() {
    getUser();
    _currentEmployeeID = username;
    super.initState();
  }

  @override
  void dispose() {
    _customerNameInput.dispose();
    _customerNumInput.dispose();
    _discInput.dispose();
    _employeeIdInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        CustomAppBar(
          title: 'Final Step',
          subtitle: 'Enter details & complete sale!',
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
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Customer Details',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: CustomTextField(
                        textController: _customerNameInput,
                        textHint: 'Customer Name',
                        textIcon: Icon(Icons.person)),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: CustomTextField(
                        textController: _customerNumInput,
                        textHint: 'Customer Number',
                        keyboardType: TextInputType.phone,
                        maximumLength: 10,
                        textIcon: Icon(Icons.phone)),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Employee Details',
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Switch.adaptive(
                            value: _isCurrentEmployee,
                            onChanged: (val) {
                              setState(() {
                                _isCurrentEmployee = val;
                              });
                            })
                      ],
                    ),
                  ),
                  if (_isCurrentEmployee)
                    Container(
                        margin: EdgeInsets.all(10),
                        child: CustomTextField(
                            textController: _employeeIdInput,
                            textHint: 'Employee ID',
                            maximumLength: 7,
                            textIcon: Icon(Icons.person_outline_rounded))),
                  if (!_isCurrentEmployee)
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
                                  'Current employee is assumed to be the merchant'),
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
                  Container(
                    margin: EdgeInsets.all(10),
                    child: CustomTextField(
                        textController: _discInput,
                        textHint: 'Discount',
                        maximumLength: 2,
                        keyboardType: TextInputType.number,
                        textIcon: Icon(Icons.monetization_on_rounded)),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    width: double.infinity,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      'Choose VAT:',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Wrap(
                    children: List<Widget>.generate(
                      2,
                      (int index) {
                        return Container(
                          margin: EdgeInsets.all(5),
                          child: ChoiceChip(
                            label: Text(_vatList[index]),
                            selected: _valueVat == index,
                            onSelected: (bool selected) {
                              setState(() {
                                _valueVat = selected ? index : -1;
                              });
                              _onVatChoice(_valueVat);
                            },
                          ),
                        );
                      },
                    ).toList(),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    width: double.infinity,
                    padding: EdgeInsets.all(5),
                    alignment: Alignment.center,
                    child: Text(
                      'Payment Method:',
                      style: GoogleFonts.openSans(
                        textStyle: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Wrap(
                    children: List<Widget>.generate(
                      2,
                      (int index) {
                        return Container(
                          margin: EdgeInsets.all(5),
                          child: ChoiceChip(
                            label: Text(_paymentList[index]),
                            selected: _valuePM == index,
                            onSelected: (bool selected) {
                              setState(() {
                                _valuePM = selected ? index : -1;
                              });
                              _onPaymentChoice(_valuePM);
                            },
                          ),
                        );
                      },
                    ).toList(),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: CustomButton(
                      buttonFunction: _completeSale,
                      buttonText: 'Complete Sale',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ));
  }
}
