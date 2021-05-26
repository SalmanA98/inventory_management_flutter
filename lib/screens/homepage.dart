import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory_management/models/database.dart';
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

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("Login");
      } else {
        this.getUser();

        setState(() {
          _isLoggedIn = true;
        });
      }
    });
  }

  Future<void> getUser() async {
    User firebaseUser = _auth.currentUser;
    firebaseUser?.reload();
    firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      setState(() {
        if (firebaseUser.email.startsWith('e')) {
          this._username = firebaseUser.email.substring(0, 7).toUpperCase();
        } else {
          this._username = firebaseUser.email.substring(0, 6).toUpperCase();
        }
      });
      this.checkAdmin();
    }
  }

  Future<void> checkAdmin() async {
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
  Widget build(BuildContext context) {
    var screenMaxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: !_checkComplete || !_isLoggedIn
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
                children: <Widget>[
                  SizedBox(
                    height: screenMaxHeight * 0.08,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 16, right: 16),
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
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              ),
                            ),
                            SizedBox(
                              height: screenMaxHeight * 0.01,
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
    );
  }
}
