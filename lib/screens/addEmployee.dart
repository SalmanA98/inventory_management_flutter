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
  List<String> locations = [];

  final _ageInput = TextEditingController();

  final _numberInput = TextEditingController();

  final List<String> adminLabelList = const ['Admin', 'Not Admin'];

  int _adminChipChoice = -1;
  int _locationChipChoice = -1;
  String _employeeID;

  String _shopLocation;

  String adminPriv;
  bool _fetchedLocations = false;

  void _registerUser(
      TextEditingController ageController,
      TextEditingController nameController,
      TextEditingController numberController,
      String shopChosen) {
    String name = nameController.text;
    String age = ageController.text;
    String number = numberController.text;
    String shop = shopChosen;

    if (name.isNotEmpty &&
        age.isNotEmpty &&
        number.isNotEmpty &&
        adminPriv.isNotEmpty &&
        shop.isNotEmpty) {
      if (number.length >= 10) {
        showModalBottomSheet(
            context: context,
            builder: (_) => RegisterUser(
                  adminPriv: adminPriv,
                  userAge: age,
                  userName: name,
                  userNumber: number,
                  userLocation: shop,
                ));
      } else {
        Fluttertoast.showToast(
            msg: 'Number should be 10 digits!',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1);
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Fields cannot be empty!',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    }
  }

  void _onAdminChanged(int value) {
    switch (value) {
      case 0:
        adminPriv = 'Yes';
        break;
      case 1:
        adminPriv = 'No';
        break;
    }
  }

  void _onLocationChanged(String locationChosen) {
    _shopLocation = locationChosen.substring(0, 1).toUpperCase();
  }

  Future<void> getAllLocations() async {
    await databaseReference.child('Locations').once().then((datasnapshot) {
      if (datasnapshot.value != null) {
        List<dynamic> values = datasnapshot.value;
        values.forEach((element) {
          if (element != null) {
            locations.add(element.toString());
          }
        });
      }
      setState(() {
        _fetchedLocations = true;
      });
      // print(datasnapshot.value);
    }).catchError((errorMessage) {
      Fluttertoast.showToast(
          msg: errorMessage.toString(),
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getAllLocations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: !_fetchedLocations
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      child: Text('Please Wait..'))
                ],
              )
            : Column(
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
                            Container(
                              margin: EdgeInsets.only(top: 10),
                              width: double.infinity,
                              padding: EdgeInsets.all(5),
                              alignment: Alignment.center,
                              child: Text(
                                'Admin Privilege:',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
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
                                      label: Text(adminLabelList[index]),
                                      selected: _adminChipChoice == index,
                                      onSelected: (bool selected) {
                                        setState(() {
                                          _adminChipChoice =
                                              selected ? index : null;
                                        });
                                        _onAdminChanged(index);
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
                                'Location:',
                                style: GoogleFonts.openSans(
                                  textStyle: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Wrap(
                              children: List<Widget>.generate(
                                locations.isNotEmpty ? locations.length : 0,
                                (int index) {
                                  return Container(
                                    margin: EdgeInsets.all(5),
                                    child: ChoiceChip(
                                      label: Text(locations[index]),
                                      selected: _locationChipChoice == index,
                                      onSelected: (bool selected) {
                                        setState(() {
                                          _locationChipChoice =
                                              selected ? index : null;
                                        });
                                        _onLocationChanged(locations[index]);
                                      },
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: CustomButton(
                                buttonFunction: () => _registerUser(_ageInput,
                                    _nameInput, _numberInput, _shopLocation),
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
