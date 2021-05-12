import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inventory_management/models/database.dart';
import 'package:inventory_management/models/employee.dart';
import 'package:inventory_management/widgets/customAppBar.dart';
import 'package:inventory_management/widgets/customButton.dart';
import 'package:inventory_management/widgets/customTextField.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';

import 'package:inventory_management/widgets/registerUser.dart';

class AddEmployee extends StatefulWidget {
  @override
  _AddEmployeeState createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  final _nameInput = TextEditingController();

  final _ageInput = TextEditingController();

  final _numberInput = TextEditingController();

  int _adminRadio = -1;

  String _employeeID;

  String shopLocation = 'D';

  String adminPriv;

  void _registerUser() {
    String name = _nameInput.text;
    String age = _ageInput.text;
    String number = _numberInput.text;

    if (name.isNotEmpty &&
        age.isNotEmpty &&
        number.isNotEmpty &&
        adminPriv.isNotEmpty) {
      showModalBottomSheet(
          context: context,
          builder: (_) => RegisterUser(
                adminPriv: adminPriv,
                userAge: age,
                userName: name,
                userNumber: number,
              ));
    } else {
      Fluttertoast.showToast(
          msg: 'Fields cannot be empty!',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    }
  }

  void _onAdminRadioChanged(int value) {
    setState(() {
      _adminRadio = value;
      switch (_adminRadio) {
        case 0:
          adminPriv = 'Yes';
          break;
        case 1:
          adminPriv = 'No';
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        CustomAppBar(
            title: 'Add Employee',
            subtitle: 'Add new user and login credentials'),
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
                    margin: EdgeInsets.only(top: 70),
                    padding: EdgeInsets.all(10),
                    child: CustomTextField(
                        textController: _nameInput,
                        textHint: 'Name',
                        textIcon: Icon(Icons.person)),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: CustomTextField(
                        textController: _ageInput,
                        textHint: 'Age',
                        keyboardType: TextInputType.number,
                        maximumLength: 2,
                        textIcon: Icon(Icons.view_agenda)),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: CustomTextField(
                        textController: _numberInput,
                        textHint: 'Number',
                        maximumLength: 10,
                        keyboardType: TextInputType.phone,
                        textIcon: Icon(Icons.phone)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Radio(
                        value: 0,
                        groupValue: _adminRadio,
                        onChanged: _onAdminRadioChanged,
                      ),
                      Text('Admin'),
                      Radio(
                        value: 1,
                        groupValue: _adminRadio,
                        onChanged: _onAdminRadioChanged,
                      ),
                      Text('Not Admin')
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: CustomButton(
                      buttonFunction: _registerUser,
                      buttonText: 'Register User',
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
