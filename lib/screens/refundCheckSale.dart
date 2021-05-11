import 'package:flutter/material.dart';
import '../widgets/customAppBar.dart';
import '../models/database.dart';
import '../widgets/customButton.dart';
import '../widgets/customTextField.dart';

class RefundSaleID extends StatelessWidget {
  final _saleIdInput = TextEditingController();

  showError(String errormessage, BuildContext context) {
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

  void _checkSaleID(BuildContext context) {
    String saleID = _saleIdInput.text;
    if (saleID.isEmpty) {
      showError('The Sale ID Cannot Be Empty!', context);
    } else if (saleID.length < 15) {
      showError('The Sale ID is of 15 Characters!', context);
    } else {
      authenticateSale(context, saleID);
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
                    CustomButton(
                      buttonFunction: () => _checkSaleID(context),
                      buttonText: 'Authenticate Sale ID',
                    )
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
