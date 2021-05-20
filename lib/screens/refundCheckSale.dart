import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../widgets/customAppBar.dart';
import '../models/database.dart';
import '../widgets/customButton.dart';
import '../widgets/customTextField.dart';
import '../screens/refundproducts.dart';

class RefundSaleID extends StatefulWidget {
  @override
  _RefundSaleIDState createState() => _RefundSaleIDState();
}

class _RefundSaleIDState extends State<RefundSaleID> {
  final _saleIdInput = TextEditingController();

  bool _startedCheck = false;
  Future<void> _authenticateSale(BuildContext context, String saleID) async {
    String year = saleID.substring(0, 4);
    String month = saleID.substring(4, 6);
    String day = saleID.substring(6, 8);
    String hr = saleID.substring(8, 10);
    String min = saleID.substring(10, 12);
    String sec = saleID.substring(12, 14);
    String date = '$year-$month-$day';
    String time = '$hr:$min:$sec';

    DataSnapshot dataSnapshot = await databaseReference
        .child('D')
        .child('Sales')
        .child(date)
        .child(time)
        .child('Sale ID')
        .once();
    if (dataSnapshot.value != null) {
      if (dataSnapshot.value == saleID) {
        databaseReference
            .child('D')
            .child('Sales')
            .child(date)
            .child(time)
            .child('Payment Method')
            .once()
            .then((paymentMethod) {
          if (paymentMethod.value.toString() == 'Cash') {
            Fluttertoast.showToast(
                msg: 'Sale ID matched!',
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                fontSize: 16.0);

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => RefundProducts(
                          date: date,
                          time: time,
                          saleID: saleID,
                        )));
          }
        }).onError((error, stackTrace) => Fluttertoast.showToast(
                msg: error.toString(),
                toastLength: Toast.LENGTH_SHORT,
                timeInSecForIosWeb: 1,
                fontSize: 16.0));
      } else {
        Fluttertoast.showToast(
            msg: 'Sale ID does not exist!',
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Sale does not exist!',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    }
    setState(() {
      _startedCheck = false;
    });
  }

  void _checkSaleID(BuildContext context) {
    String saleID = _saleIdInput.text;
    if (saleID.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Sale ID cannot be empty!',
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    } else if (saleID.length < 15) {
      Fluttertoast.showToast(
          msg: 'Sale ID should be 15 characters!',
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    } else {
      setState(() {
        _startedCheck = true;
      });
      _authenticateSale(context, saleID);
    }
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
            children: [
              CustomAppBar(
                title: 'Refund Sale',
                subtitle: 'Enter the sale details!',
              ),
              Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 50),
                width: double.infinity,
                child: Column(
                  children: [
                    CustomTextField(
                      textController: _saleIdInput,
                      textIcon: Icon(Icons.format_list_numbered),
                      textHint: 'Sale ID',
                      maximumLength: 15,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .02,
                    ),
                    if (!_startedCheck)
                      CustomButton(
                        buttonFunction: () => _checkSaleID(context),
                        buttonText: 'Authenticate Sale ID',
                      ),
                    if (_startedCheck) LinearProgressIndicator(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
