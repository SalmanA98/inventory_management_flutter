import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/employee.dart';
import '../widgets/customButton.dart';
import '../widgets/customTextField.dart';
import '../models/paymentdetails.dart';
import '../widgets/customAppBar.dart';
import '../models/database.dart';

class EditEmployee extends StatefulWidget {
  final Employee _employee;
  const EditEmployee(this._employee);

  @override
  _EditEmployeeState createState() => _EditEmployeeState();
}

class _EditEmployeeState extends State<EditEmployee> {
  final List<PaymentDetails> _employeeDetails = [];
  final List<PaymentDetails> _editable = [];
  final _ageController = TextEditingController();
  final _numberController = TextEditingController();
  final _passwordController = TextEditingController();
  final List<String> _adminLabelList = const ['Admin', 'Not Admin'];
  int _adminChipChoice = -1;
  bool _editAdmin = false;
  bool _hasUpdated = false;
  bool _hasDeletedUser = false;
  bool _startProgress = false;

  void _loadDetails() {
    _employeeDetails
        .add(PaymentDetails(title: 'ID', value: widget._employee.id));
    _employeeDetails.add(
      PaymentDetails(title: 'Name', value: widget._employee.name),
    );
    _employeeDetails.add(
      PaymentDetails(
          title: 'Location',
          value: widget._employee.id.toString().substring(2, 3)),
    );
    _editable.add(
      PaymentDetails(title: 'Age', value: widget._employee.age),
    );

    _editable.add(
      PaymentDetails(title: 'Number', value: widget._employee.number),
    );
    _editable.add(
      PaymentDetails(
          title: 'Admin Privilege', value: widget._employee.adminPriv),
    );
  }

  void _enterDetailsBox(String message, TextEditingController controller,
      String hint, bool isAge) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: FittedBox(
                fit: BoxFit.contain, child: const Text('Enter Details')),
            content: CustomTextField(
                textController: controller,
                textHint: hint,
                maximumLength: isAge ? 2 : 10,
                keyboardType: TextInputType.number,
                textIcon: Icon(Icons.edit)),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      if (controller.text.isNotEmpty) {
                        if (isAge) {
                          _editable[0].value = controller.text;
                        } else if (!isAge) {
                          _editable[1].value = controller.text;
                        }
                        _hasUpdated = true;
                      } else {
                        Fluttertoast.showToast(
                            msg: 'Fields cannot be empty',
                            gravity: ToastGravity.CENTER,
                            toastLength: Toast.LENGTH_SHORT,
                            timeInSecForIosWeb: 1);
                      }
                    });
                  },
                  child: FittedBox(
                      fit: BoxFit.contain, child: const Text('Save Changes')))
            ],
          );
        });
  }

  void _onAdminChanged(int value) {
    switch (value) {
      case -1:
        Fluttertoast.showToast(msg: 'Choose an option!');
        break;
      case 0:
        setState(() {
          _editable[2].value = 'Yes';
          _hasUpdated = true;
        });

        break;
      case 1:
        setState(() {
          _editable[2].value = 'No';
          _hasUpdated = true;
        });
        break;
    }
  }

  void _editAttribute(String attribute) {
    if (attribute?.toLowerCase() == 'age') {
      _enterDetailsBox('Enter the Age', _ageController, 'Updated Age', true);
    } else if (attribute?.toLowerCase() == 'admin privilege') {
      setState(() {
        _editAdmin = true;
      });
    } else if (attribute?.toLowerCase() == 'number') {
      _enterDetailsBox(
          'Enter the Number', _numberController, 'Updated Number', false);
    }
  }

  Future<void> _deleteUser(String username) async {
    showDialog(
        context: context,
        builder: (_) => NetworkGiffyDialog(
              image: Image.asset('assets/images/logo.png'),
              title: Text('Confirm Delete?',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
              description: Text(
                'This cannot be undone.\nAre you sure you want to remove user: ${_employeeDetails[0].value}?',
                textAlign: TextAlign.center,
              ),
              entryAnimation: EntryAnimation.BOTTOM_LEFT,
              onOkButtonPressed: () {
                Navigator.of(context, rootNavigator: true).pop(context);
                setState(() {
                  _startProgress = true;
                });
                databaseReference
                    .child(_employeeDetails[2].value)
                    .child('Employees')
                    .child(_employeeDetails[0].value)
                    .remove()
                    .then((_) {
                  Fluttertoast.showToast(
                      msg: 'Deleted user succesfully!',
                      gravity: ToastGravity.CENTER,
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 1);
                  setState(() {
                    _startProgress = false;
                    _hasDeletedUser = true;
                  });
                }).catchError((onError) {
                  Fluttertoast.showToast(
                      msg: onError.toString(),
                      gravity: ToastGravity.CENTER,
                      toastLength: Toast.LENGTH_SHORT,
                      timeInSecForIosWeb: 1);
                  setState(() {
                    _startProgress = false;
                  });
                });
              },
              onCancelButtonPressed: () {
                Navigator.of(context, rootNavigator: true).pop(context);
              },
            ));
  }

  Future<void> _applyChanges() async {
    if (_hasUpdated) {
      setState(() {
        _startProgress = true;
      });
      showDialog(
          context: context,
          builder: (_) => NetworkGiffyDialog(
                image: Image.asset('assets/images/logo.png'),
                title: Text('Confirm Changes?',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600)),
                description: Text(
                  'This cannot be undone.\nAre you sure?',
                  textAlign: TextAlign.center,
                ),
                entryAnimation: EntryAnimation.BOTTOM_LEFT,
                onOkButtonPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(context);
                  databaseReference
                      .child(_employeeDetails[2].value)
                      .child('Employees')
                      .child(_employeeDetails[0].value)
                      .update({
                    'Admin Privilege': _editable[2].value,
                    'Age': _editable[0].value,
                    'Number': _editable[1].value,
                  }).then((_) {
                    Fluttertoast.showToast(
                        msg: 'Updated successfully!',
                        gravity: ToastGravity.CENTER,
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 1);
                    setState(() {
                      _hasUpdated = false;
                      _startProgress = false;
                    });
                  }).catchError((error) {
                    Fluttertoast.showToast(
                        msg: error.toString(),
                        gravity: ToastGravity.CENTER,
                        toastLength: Toast.LENGTH_SHORT,
                        timeInSecForIosWeb: 1);
                    setState(() {
                      _startProgress = false;
                    });
                  });
                },
                onCancelButtonPressed: () {
                  Navigator.of(context, rootNavigator: true).pop(context);
                },
              ));
    } else {
      Fluttertoast.showToast(
          msg: 'No changes were made!',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomAppBar(
                title: 'Edit User', subtitle: 'Update/Remove the user chosen'),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                },
                child: SingleChildScrollView(
                  child: _startProgress
                      ? Padding(
                          padding: const EdgeInsets.all(50.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: CircularProgressIndicator.adaptive(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
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
                      : Column(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 10),
                              width: double.infinity,
                              child: Card(
                                elevation: 3,
                                child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: ListTile(
                                      leading: Icon(Icons.info_outline),
                                      subtitle: const Text(
                                          'To change the Location, Name or ID, delete the user and create a new one'),
                                    )),
                              ),
                            ),
                            Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.only(top: 15),
                                alignment: Alignment.centerLeft,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: const Text(
                                    'Employee Details',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )),
                            ..._employeeDetails.map((element) {
                              return Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.contain,
                                            child: Text(
                                              element.title,
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text(element.value)),
                                        ],
                                      ),
                                      Divider(
                                        color: Theme.of(context).primaryColor,
                                      )
                                    ],
                                  ));
                            }),
                            ..._editable.map((element) {
                              return Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                margin:
                                                    EdgeInsets.only(right: 15),
                                                child: FittedBox(
                                                  fit: BoxFit.contain,
                                                  child: Text(
                                                    element.title,
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ),
                                              InkWell(
                                                  onTap: () => _editAttribute(
                                                      element.title),
                                                  child: Icon(Icons.edit)),
                                            ],
                                          ),
                                          FittedBox(
                                              fit: BoxFit.contain,
                                              child: Text(element.value)),
                                        ],
                                      ),
                                      Divider(
                                        color: Theme.of(context).primaryColor,
                                      )
                                    ],
                                  ));
                            }),
                            if (_editAdmin)
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
                            if (_editAdmin)
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
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: CustomButton(
                                  buttonFunction: () {
                                    _applyChanges();
                                  },
                                  buttonText: 'Apply Changes',
                                )),
                            if (!_hasDeletedUser)
                              Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  child: CustomButton(
                                    buttonFunction: () =>
                                        _deleteUser(_employeeDetails[0].value),
                                    buttonText: 'Delete User',
                                  )),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
