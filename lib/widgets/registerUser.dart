import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory_management/widgets/customButton.dart';
import 'package:inventory_management/widgets/customTextField.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../models/database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegisterUser extends StatefulWidget {
  final String userName;
  final String userAge;
  final String userNumber;
  final String adminPriv;
  RegisterUser({this.userAge, this.adminPriv, this.userName, this.userNumber});

  @override
  _RegisterUserState createState() => _RegisterUserState();
}

class _RegisterUserState extends State<RegisterUser> {
  final _pwdInput = TextEditingController();
  final _confirmPwdInput = TextEditingController();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String _employeeID;

  final String shopLocation = 'D';

  Future<void> _createUsername() async {
    String _userID;
    var rnd = new Random();
    var code = rnd.nextInt(9999) + 1000;
    _userID = ('EM' + shopLocation + code.toString()).toUpperCase();
    await databaseReference
        .child('D')
        .child('Employees')
        .once()
        .then((snapshot) {
      print(snapshot.value);
      Map<dynamic, dynamic> users = snapshot.value;
      users.forEach((key, value) {
        if (key.toString().toUpperCase() == _userID) {
          code = rnd.nextInt(9999) + 1000;
          _userID = 'EM' + shopLocation + code.toString();
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
        firebaseAuth
            .createUserWithEmailAndPassword(
                email: _employeeID + '@hekayet3tr.com', password: pwd)
            .then((_) {
          databaseReference
              .child('D')
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
            Navigator.pushReplacementNamed(context, '/');
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

  @override
  void initState() {
    _createUsername();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pwdInput.dispose();
    _confirmPwdInput.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: SingleChildScrollView(
        child: Card(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: _employeeID == null
              ? Column(children: [
                  Container(
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: CircularProgressIndicator.adaptive()),
                  Container(
                    padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
                    child: FittedBox(
                      child: Text(
                        'Please Wait',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ])
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(top: 10, left: 10),
                      child: FittedBox(
                        child: Text(
                          'User Credentials',
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
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
                            child: Text(
                              'User ID: $_employeeID',
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
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
                          hideText: true,
                          textIcon: Icon(Icons.security)),
                    ),
                    Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: CustomTextField(
                          textController: _confirmPwdInput,
                          textHint: 'Confim Password',
                          hideText: true,
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
