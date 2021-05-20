import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import '../widgets/customTextField.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameInput = TextEditingController();
  final _pwdInput = TextEditingController();
  String username;
  String pwd;
  String location;
  ButtonState loginBtState = ButtonState.idle;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  isUserSignedIn() async {
    _auth.authStateChanges().listen((User user) async {
      if (user != null) {
        print('User signed in');
        //Navigate to main

        Navigator.pushReplacementNamed(context, "/");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.isUserSignedIn();
  }

  showError(String errormessage) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('ERROR'),
            content: Text(errormessage),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'))
            ],
          );
        });
  }

  _authenticateUser() async {
    username = _usernameInput.text;
    pwd = _pwdInput.text;
    if (username.isEmpty || pwd.isEmpty) {
      Fluttertoast.showToast(
          msg: 'Fields cannot be empty',
          gravity: ToastGravity.CENTER,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1);
    } else {
      setState(() {
        loginBtState = ButtonState.loading;
      });
      try {
        if (username.startsWith('a')) {
          location = username.substring(1, 2);
        } else {
          location = username.substring(2, 3);
        }
        await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: username + '@hekayet3tr.com',
                password: pwd.toLowerCase())
            .then((value) {
          // databaseReference
          //     .child(location)
          //     .child('Employees')
          //     .child(username)
          //     .once().then((user) {
          //       if(user == null){

          //       }
          //       else{

          //       }
          // });
          setState(() {
            loginBtState = ButtonState.success;
          });
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          Fluttertoast.showToast(
              msg: 'User not found',
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1);
          setState(() {
            loginBtState = ButtonState.fail;
          });
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              loginBtState = ButtonState.idle;
            });
          });
        } else if (e.code == 'wrong-password') {
          Fluttertoast.showToast(
              msg: 'Wrong password',
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1);
          setState(() {
            loginBtState = ButtonState.fail;
          });
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              loginBtState = ButtonState.idle;
            });
          });
        } else {
          Fluttertoast.showToast(
              msg: e.message.toString(),
              gravity: ToastGravity.CENTER,
              toastLength: Toast.LENGTH_SHORT,
              timeInSecForIosWeb: 1);
          setState(() {
            loginBtState = ButtonState.fail;
          });
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              loginBtState = ButtonState.idle;
            });
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameInput.dispose();
    _pwdInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(top: 100, left: 30),
            child: FittedBox(
              fit: BoxFit.contain,
              child: RichText(
                  text: TextSpan(children: [
                TextSpan(text: 'Welcome\n'),
                TextSpan(text: 'Back'),
                TextSpan(
                    children: [TextSpan(text: '!')],
                    style: TextStyle(color: Theme.of(context).primaryColor))
              ], style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold))),
            ),
          ),
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
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.only(top: 50),
                      width: 400,
                      child: Column(
                        children: [
                          CustomTextField(
                            textController: _usernameInput,
                            textIcon: Icon(Icons.account_circle_outlined),
                            textHint: 'Username',
                            maximumLength: 7,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          CustomTextField(
                              textController: _pwdInput,
                              keyboardType: TextInputType.visiblePassword,
                              hideText: true,
                              textIcon:
                                  Icon(Icons.admin_panel_settings_outlined),
                              textHint: 'Password'),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            child: ProgressButton.icon(
                                radius: 16.0,
                                height: 50.0,
                                textStyle: TextStyle(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor),
                                iconedButtons: {
                                  ButtonState.idle: IconedButton(
                                      text: 'login',
                                      icon: Icon(Icons.login_rounded,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor),
                                      color: Theme.of(context).primaryColor),
                                  ButtonState.loading: IconedButton(
                                      text: "Loading",
                                      color: Theme.of(context).primaryColor),
                                  ButtonState.fail: IconedButton(
                                      text: "Failed",
                                      icon: Icon(Icons.cancel,
                                          color: Colors.white),
                                      color: Colors.red.shade300),
                                  ButtonState.success: IconedButton(
                                      text: "Success",
                                      icon: Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                      ),
                                      color: Colors.green.shade400)
                                },
                                onPressed: () {
                                  _authenticateUser();
                                },
                                state: loginBtState),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
