import 'package:flutter/material.dart';
import 'package:inventory_management/widgets/customButton.dart';
import 'package:inventory_management/widgets/customTextField.dart';
import '../widgets/customAppBar.dart';
import '../models/database.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/sellToDb.dart';
import '../models/products.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class CustomerInfo extends StatefulWidget {
  final List<Products> cartProducts;
  CustomerInfo(this.cartProducts);

  @override
  _CustomerInfoState createState() => _CustomerInfoState();
}

class _CustomerInfoState extends State<CustomerInfo> {
  final TextEditingController customerNameInput = TextEditingController();

  final TextEditingController customerNumInput = TextEditingController();

  final TextEditingController discInput = TextEditingController();

  final TextEditingController employeeIdInput = TextEditingController();

  bool _isCurrentEmployee = false;
  String vat;
  String paymentMethod;
  String currentEmployeeID;

  int _valueVat = -1;
  int _valuePM = -1;

  final List<String> vatList = const ['VAT', 'No VAT'];
  final List<String> paymentList = const ['Cash', 'Card'];

  void _onVatChoice(int value) {
    switch (value) {
      case 0:
        print('VAT');
        vat = '5%';
        break;
      case 1:
        print('No VAT');
        vat = '0%';
        break;
    }
  }

  void _onPaymentChoice(int value) {
    switch (value) {
      case 0:
        print('CASH');

        paymentMethod = 'Cash';
        break;
      case 1:
        print('Card');

        paymentMethod = 'Card';
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
              FlatButton(
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
      employeeIdInput.text = currentEmployeeID.toString().toUpperCase();
      print(employeeIdInput.text);
    }
    if (customerNameInput.text.isEmpty ||
        customerNumInput.text.isEmpty ||
        vat.isEmpty ||
        paymentMethod.isEmpty ||
        employeeIdInput.text.isEmpty ||
        discInput.text.isEmpty) {
      showError('Fields cannot be empty');
    } else if (customerNumInput.text.length < 10) {
      showError('Number should be of 10-digits! (0501234567)');
    } else {
      var sell = WriteSaleToDb(
          customerName: customerNameInput.text,
          customerNum: customerNumInput.text,
          discount: discInput.text,
          employeeID: employeeIdInput.text,
          finalItems: widget.cartProducts,
          paymentMethod: paymentMethod,
          vat: vat);
      sell.processSale(context);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    currentEmployeeID = username;
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
                        textController: customerNameInput,
                        textHint: 'Customer Name',
                        textIcon: Icon(Icons.person)),
                  ),
                  Container(
                    margin: EdgeInsets.all(10),
                    child: CustomTextField(
                        textController: customerNumInput,
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
                            textController: employeeIdInput,
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
                        textController: discInput,
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
                            label: Text(vatList[index]),
                            selected: _valueVat == index,
                            onSelected: (bool selected) {
                              setState(() {
                                _valueVat = selected ? index : null;
                              });
                              _onVatChoice(index);
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
                            label: Text(paymentList[index]),
                            selected: _valuePM == index,
                            onSelected: (bool selected) {
                              setState(() {
                                _valuePM = selected ? index : null;
                              });
                              _onPaymentChoice(index);
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
