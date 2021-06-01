import 'dart:math';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import '../screens/homepage.dart';
import './customButton.dart';
import './customTextField.dart';
import '../models/database.dart';

class RegisterUser extends StatefulWidget {
  final String userName;
  final String userAge;
  final String userNumber;
  final String adminPriv;
  final String userLocation;
  RegisterUser(
      {this.userAge,
      this.adminPriv,
      this.userName,
      this.userNumber,
      this.userLocation});

  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final _pwdInput = TextEditingController();
  final _confirmPwdInput = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String _employeeID;
  bool _isCreating = false;
  bool _hidePwd = true;
  Icon _toggleVisibilityIcon = Icon(Icons.visibility_off);

  Future<void> _createUsername() async {
    String _userID;
    var rnd = new Random();
    var code = rnd.nextInt(9999) + 1000;
    _userID = ('EM' + widget.userLocation + code.toString()).toUpperCase();
    await databaseReference
        .child(widget.userLocation)
        .child('Employees')
        .once()
        .then((snapshot) {
      Map<dynamic, dynamic> users = snapshot.value;
      users.forEach((key, value) {
        if (key.toString().toUpperCase() == _userID) {
          code = rnd.nextInt(9999) + 1000;
          _userID = 'EM' + widget.userLocation + code.toString();
        }
      });
      setState(() {
        this._employeeID = _userID;
      });
    });
  }

  Future<void> _addNewUser() async {
    String pwd = _pwdInput.text;
    String confirmPwd = _confirmPwdInput.text;
    if (pwd.isNotEmpty && confirmPwd.isNotEmpty) {
      if (pwd == confirmPwd) {
        showDialog(
            context: context,
            builder: (_) => NetworkGiffyDialog(
                  image: Image.asset('assets/images/logo.png'),
                  title: Text('Confirm Details?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.w600)),
                  description: Text(
                    'This cannot be undone.\nAre you sure?',
                    textAlign: TextAlign.center,
                  ),
                  entryAnimation: EntryAnimation.BOTTOM_LEFT,
                  onOkButtonPressed: () {
                    Navigator.of(context, rootNavigator: true).pop(context);
                    firebaseAuth
                        .createUserWithEmailAndPassword(
                            email: _employeeID + '@hekayet3tr.com',
                            password: pwd)
                        .then((_) {
                      databaseReference
                          .child(widget.userLocation)
                          .child('Employees')
                          .child(_employeeID)
                          .update({
                        'Name': widget.userName,
                        'Age': widget.userAge,
                        'Number': widget.userNumber,
                        'Admin Privilege': widget.adminPriv
                      }).then((_) {
                        Fluttertoast.showToast(
                            msg: 'Created Successully',
                            gravity: ToastGravity.CENTER,
                            toastLength: Toast.LENGTH_SHORT,
                            timeInSecForIosWeb: 1);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => HomePage()));
                      });
                    }).catchError((e) {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                title: Text("Error"),
                                content: Text(e.message),
                                actions: [
                                  TextButton(
                                    child: Text("Ok"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ]);
                          });
                    });

                    setState(() {
                      _isCreating = true;
                    });
                  },
                  onCancelButtonPressed: () {
                    Navigator.of(context, rootNavigator: true).pop(context);
                  },
                ));
      } else {
        Fluttertoast.showToast(
            msg: 'Passwords do no match!',
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIosWeb: 1);
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Fields Cannot Be Empty!',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    }
  }

  void _toggleVisibility() {
    if (_hidePwd) {
      setState(() {
        _hidePwd = false;
        _toggleVisibilityIcon = Icon(Icons.visibility);
      });
    } else {
      setState(() {
        _hidePwd = true;
        _toggleVisibilityIcon = Icon(Icons.visibility_off);
      });
    }
  }

  @override
  void initState() {
    _createUsername();
    super.initState();
  }

  @override
  void dispose() {
    _pwdInput.dispose();
    _confirmPwdInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Card(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: _employeeID == null || _isCreating
              ? Column(children: [
                  Container(
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator.adaptive()),
                  Container(
                    padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: const Text(
                        'Please Wait',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ])
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 10, left: 10),
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: const Text(
                          'User Credentials',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.only(top: 10, left: 10, bottom: 10),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text(
                              'User ID: $_employeeID',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Container(
                          child: IconButton(
                              icon: Icon(Icons.refresh),
                              onPressed: _createUsername),
                        ),
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: CustomTextField(
                          textController: _pwdInput,
                          textHint: 'Password',
                          isPwd: true,
                          showPassword: _toggleVisibility,
                          pwdIcon: _toggleVisibilityIcon,
                          hideText: _hidePwd,
                          textIcon: Icon(Icons.security)),
                    ),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: CustomTextField(
                          textController: _confirmPwdInput,
                          textHint: 'Confim Password',
                          isPwd: true,
                          showPassword: _toggleVisibility,
                          pwdIcon: _toggleVisibilityIcon,
                          hideText: _hidePwd,
                          textIcon: Icon(Icons.security)),
                    ),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: CustomButton(
                        buttonFunction: _addNewUser,
                        buttonText: 'Upload User',
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
