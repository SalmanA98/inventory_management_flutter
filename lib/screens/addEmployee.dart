import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/database.dart';
import '../widgets/customAppBar.dart';
import '../widgets/customButton.dart';
import '../widgets/customTextField.dart';
import '../widgets/registerUser.dart';

class AddEmployee extends StatefulWidget {
  @override
  _AddEmployeeState createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  final _nameInput = TextEditingController();

  final _ageInput = TextEditingController();

  final _numberInput = TextEditingController();

  List<String> _locations = [];

  final List<String> _adminLabelList = const ['Admin', 'Not Admin'];

  int _adminChipChoice = -1;
  int _locationChipChoice = -1;

  String _shopLocation;

  String _adminPriv;
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
        _adminPriv.isNotEmpty &&
        shop.isNotEmpty) {
      if (number.length >= 10) {
        showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) {
              return Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: RegisterUser(
                  adminPriv: _adminPriv,
                  userAge: age,
                  userName: name,
                  userNumber: number,
                  userLocation: shop,
                ),
              );
            });
      } else {
        Fluttertoast.showToast(
            msg: 'Number should be 10 digits!',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1);
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Fields/Choices cannot be empty!',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    }
  }

  void _onAdminChanged(int value) {
    switch (value) {
      case -1:
        Fluttertoast.showToast(
            msg: 'Choose Admin privilege',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1);
        break;

      case 0:
        _adminPriv = 'Yes';
        break;
      case 1:
        _adminPriv = 'No';
        break;
    }
  }

  void _onLocationChanged(String locationChosen, int choice) {
    if (choice != -1) {
      _shopLocation = locationChosen.substring(0, 1).toUpperCase();
      print(_shopLocation);
    } else {
      Fluttertoast.showToast(
          msg: 'Location cannot be empty!',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    }
  }

  Future<void> _getAllLocations() async {
    await databaseReference.child('Locations').once().then((datasnapshot) {
      if (datasnapshot.value != null) {
        List<dynamic> values = datasnapshot.value;
        values.forEach((element) {
          if (element != null) {
            _locations.add(element.toString());
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
    super.initState();
    _getAllLocations();
  }

  @override
  void dispose() {
    _ageInput.dispose();
    _numberInput.dispose();
    _nameInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        bottomNavigationBar: !_fetchedLocations
            ? null
            : Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: CustomButton(
                  buttonFunction: () => _registerUser(
                      _ageInput, _nameInput, _numberInput, _shopLocation),
                  buttonText: 'Register User',
                ),
              ),
        body: !_fetchedLocations
            ? SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: CircularProgressIndicator.adaptive(
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: FittedBox(
                            fit: BoxFit.contain,
                            child: const Text('Please Wait..')))
                  ],
                ),
              )
            : SafeArea(
                child: Column(
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
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: const Text(
                                    'Admin Privilege:',
                                    style: TextStyle(
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
                                        label: FittedBox(
                                            fit: BoxFit.contain,
                                            child:
                                                Text(_adminLabelList[index])),
                                        selected: _adminChipChoice == index,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            _adminChipChoice =
                                                selected ? index : -1;
                                          });
                                          _onAdminChanged(_adminChipChoice);
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
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: const Text(
                                    'Location:',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              Wrap(
                                children: List<Widget>.generate(
                                  _locations.isNotEmpty ? _locations.length : 0,
                                  (int index) {
                                    return Container(
                                      margin: EdgeInsets.all(5),
                                      child: ChoiceChip(
                                        label: FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(_locations[index])),
                                        selected: _locationChipChoice == index,
                                        onSelected: (bool selected) {
                                          setState(() {
                                            _locationChipChoice =
                                                selected ? index : -1;
                                          });
                                          _onLocationChanged(_locations[index],
                                              _locationChipChoice);
                                        },
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
