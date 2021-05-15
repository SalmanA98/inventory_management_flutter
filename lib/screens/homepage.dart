import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/griddashboard.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User _user;
  var _username;
  bool _isloggedin = false;
  var _isAdmin;
  bool _checkComplete = false;

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("Login");
      }
      setState(() {
        _checkComplete = true;
      });
    });
  }

  getUser() async {
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
        this._user = firebaseUser;

        this._isloggedin = true;
        this._isAdmin = firebaseUser.email.substring(0, 1);
      });
    }
  }

  signOut() async {
    _auth.signOut();
    Fluttertoast.showToast(msg: 'Signed out!', toastLength: Toast.LENGTH_SHORT);
  }

  @override
  void initState() {
    this.checkAuthentification();
    this.getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var screenMaxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: !_checkComplete
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
                    child: Text('Please Wait'))
              ],
            )
          : Column(
              children: <Widget>[
                SizedBox(
                  height: screenMaxHeight * 0.12,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("Hekayet Etr",
                              style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    fontSize: 30, fontWeight: FontWeight.bold),
                              )),
                          SizedBox(
                            height: screenMaxHeight * 0.01,
                          ),
                          Text(
                            'Welcome $_username!',
                            style: GoogleFonts.openSans(
                                textStyle: TextStyle(
                                    color: Color(0xffa29aac),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600)),
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
                GridDashboard(_isAdmin)
              ],
            ),
    );
  }
}
