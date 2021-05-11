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
  int _radioVat = -1;
  int _radioPayment = -1;
  bool _isCurrentEmployee = false;
  String vat;
  String paymentMethod;
  String currentEmployeeID;

  void _onVatRadioChanged(int value) {
    setState(() {
      _radioVat = value;
      switch (_radioVat) {
        case 0:
          vat = '5%';
          break;
        case 1:
          vat = '0%';
          break;
      }
    });
  }

  void _onPaymentRadioChanged(int value) {
    setState(() {
      _radioPayment = value;
      switch (_radioPayment) {
        case 0:
          paymentMethod = 'Cash';
          break;
        case 1:
          paymentMethod = 'Card';
          break;
      }
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
        body: GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            CustomAppBar(
              title: 'Final Step',
              subtitle: 'Enter details & complete sale!',
            ),
            Container(
              margin: EdgeInsets.only(top: 10),
              width: double.infinity,
              padding: EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              child: Text(
                'Customer Details',
                style: GoogleFonts.openSans(
                  textStyle:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                      textStyle:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  textStyle:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio(
                  value: 0,
                  groupValue: _radioVat,
                  onChanged: _onVatRadioChanged,
                ),
                Text('VAT'),
                Radio(
                  value: 1,
                  groupValue: _radioVat,
                  onChanged: _onVatRadioChanged,
                ),
                Text('No VAT')
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio(
                  value: 0,
                  groupValue: _radioPayment,
                  onChanged: _onPaymentRadioChanged,
                ),
                Text('Cash'),
                Radio(
                  value: 1,
                  groupValue: _radioPayment,
                  onChanged: _onPaymentRadioChanged,
                ),
                Text('Card')
              ],
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
    ));
  }
}
