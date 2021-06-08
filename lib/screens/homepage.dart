import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory_management/models/database.dart';
import 'package:inventory_management/widgets/customButton.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../widgets/griddashboard.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var _username;
  bool _adminPriv;
  bool _checkComplete = false;
  bool _isLoggedIn = false;
  bool _userDataExists = false;
  int _countdown = 10;
  Timer _timer;

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (mounted) {
        if (user == null) {
          Navigator.of(context).pushReplacementNamed("Login");
        } else {
          this.getUser();
          setState(() {
            _isLoggedIn = true;
          });
        }
      }
    });
  }

  Future<void> getUser() async {
    User firebaseUser = _auth.currentUser;
    firebaseUser?.reload();
    firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      if (firebaseUser.email.startsWith('e')) {
        setState(() {
          this._username = firebaseUser.email.substring(0, 7).toUpperCase();
        });
      } else {
        setState(() {
          this._username = firebaseUser.email.substring(0, 6).toUpperCase();
        });
      }

      this.checkAdmin();
    }
  }

  void _startTimer() async {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        setState(() {
          _timer.cancel();
        });
        signOut();
      }
    });
  }

  Future<void> checkAdmin() async {
    databaseReference
        .child(_username.substring(2, 3))
        .child('Employees')
        .child(_username)
        .once()
        .then((user) {
      if (mounted) {
        if (user.value == null) {
          setState(() {
            _checkComplete = true;
          });
          _startTimer();
        } else {
          setState(() {
            _userDataExists = true;
          });
          if (_username.toString().toLowerCase().startsWith('a')) {
            setState(() {
              _adminPriv = true;
              _checkComplete = true;
            });
          } else {
            databaseReference
                .child(_username.substring(2, 3))
                .child('Employees')
                .child(_username)
                .once()
                .then((snapshot) {
              if (snapshot.value != null) {
                Map<dynamic, dynamic> values = snapshot.value;
                values.forEach((key, value) {
                  if (key.toString().toLowerCase() == 'admin privilege') {
                    if (value.toString().toLowerCase() == 'yes') {
                      setState(() {
                        _adminPriv = true;
                        _checkComplete = true;
                      });
                    } else {
                      setState(() {
                        _adminPriv = false;
                        _checkComplete = true;
                      });
                    }
                  }
                });
              }
            });
          }
        }
      }
    });
  }

  signOut() async {
    _auth.signOut();
    Fluttertoast.showToast(msg: 'Signed out!', toastLength: Toast.LENGTH_SHORT);
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenMaxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: !_checkComplete || !_isLoggedIn
          ? WillPopScope(
              onWillPop: () => SystemNavigator.pop(),
              child: SafeArea(
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
              ),
            )
          : !_userDataExists
              ? WillPopScope(
                  onWillPop: () {
                    signOut();
                    return SystemNavigator.pop();
                  },
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: CircularProgressIndicator.adaptive(
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            child: FittedBox(
                                fit: BoxFit.contain,
                                child: Text(
                                    'This user does not exist in the database\nLogging you out in: $_countdown'))),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 10),
                          child: CustomButton(
                            buttonFunction: signOut,
                            buttonText: 'Logout Now',
                          ),
                        )
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: WillPopScope(
                    // ignore: missing_return
                    onWillPop: () {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.WARNING,
                        borderSide: BorderSide(
                            color: Theme.of(context).accentColor, width: 2),
                        width: double.infinity,
                        buttonsBorderRadius:
                            BorderRadius.all(Radius.circular(2)),
                        headerAnimationLoop: true,
                        useRootNavigator: true,
                        animType: AnimType.BOTTOMSLIDE,
                        title: 'Are you sure?',
                        desc: 'Are you sure you want to exit the app?',
                        dismissOnBackKeyPress: true,
                        btnOkText: 'Exit',
                        btnOkOnPress: () {
                          SystemNavigator.pop();
                        },
                        btnCancelText: 'Cancel',
                        btnCancelOnPress: () {},
                      )..show();
                    },
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.only(left: 16, right: 16, top: 70),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  FittedBox(
                                    fit: BoxFit.contain,
                                    child: const Text(
                                      "Hekayet Etr",
                                      style: TextStyle(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  FittedBox(
                                    fit: BoxFit.contain,
                                    child: Text(
                                      'Welcome $_username!',
                                      style: TextStyle(
                                          color: Color(0xffa29aac),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                alignment: Alignment.topCenter,
                                icon: Icon(
                                  Icons.exit_to_app,
                                  //  color: Colors.white,
                                  size: 30,
                                ),
                                onPressed: () => signOut(),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: screenMaxHeight * 0.05,
                        ),
                        GridDashboard(
                          isAdmin: _adminPriv,
                          username: _username,
                        )
                      ],
                    ),
                  ),
                ),
    );
  }
}
