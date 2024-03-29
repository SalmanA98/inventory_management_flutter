import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:progress_state_button/iconed_button.dart';
import 'package:progress_state_button/progress_button.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
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
  bool _hidePwd = true;
  Icon _toggleVisibilityIcon = Icon(Icons.visibility_off);
  ButtonState loginBtState = ButtonState.idle;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  isUserSignedIn() async {
    _auth.authStateChanges().listen((User user) async {
      if (mounted) {
        if (user != null) {
          print('User signed in');
          //Navigate to main
          Navigator.pushReplacementNamed(context, "/");
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.isUserSignedIn();
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
          setState(() {
            loginBtState = ButtonState.success;
          });
        });
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            borderSide:
                BorderSide(color: Theme.of(context).accentColor, width: 2),
            width: double.infinity,
            buttonsBorderRadius: BorderRadius.all(Radius.circular(2)),
            headerAnimationLoop: true,
            useRootNavigator: true,
            animType: AnimType.BOTTOMSLIDE,
            title: 'Error Logging In',
            desc: 'User ID not found! Check if the user ID is correct.',
            dismissOnBackKeyPress: true,
            btnOkText: 'Ok, Got It!',
            btnOkOnPress: () {},
          )..show();
          setState(() {
            loginBtState = ButtonState.fail;
          });
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              loginBtState = ButtonState.idle;
            });
          });
        } else if (e.code == 'wrong-password') {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            borderSide:
                BorderSide(color: Theme.of(context).accentColor, width: 2),
            width: double.infinity,
            buttonsBorderRadius: BorderRadius.all(Radius.circular(2)),
            headerAnimationLoop: true,
            useRootNavigator: true,
            animType: AnimType.BOTTOMSLIDE,
            title: 'Error Logging In',
            desc: 'Sorry, Wrong password! Try again.',
            dismissOnBackKeyPress: true,
            btnOkText: 'Ok, Got It!',
            btnOkOnPress: () {},
          )..show();
          setState(() {
            loginBtState = ButtonState.fail;
          });
          Future.delayed(Duration(seconds: 1), () {
            setState(() {
              loginBtState = ButtonState.idle;
            });
          });
        } else {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.ERROR,
            borderSide:
                BorderSide(color: Theme.of(context).accentColor, width: 2),
            width: double.infinity,
            buttonsBorderRadius: BorderRadius.all(Radius.circular(2)),
            headerAnimationLoop: true,
            useRootNavigator: true,
            animType: AnimType.BOTTOMSLIDE,
            title: 'Error Logging In',
            desc: e.toString(),
            dismissOnBackKeyPress: true,
            btnOkText: 'Ok, Got It!',
            btnOkOnPress: () {},
          )..show();
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
  void dispose() {
    _usernameInput.dispose();
    _pwdInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var _brightness = MediaQuery.of(context).platformBrightness;
    bool _darkModeOn = _brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () => SystemNavigator.pop(),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 100, left: 30),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: RichText(
                      text: TextSpan(
                          children: [
                        TextSpan(text: 'Welcome\n'),
                        TextSpan(text: 'Back'),
                        TextSpan(
                            children: [TextSpan(text: '!')],
                            style: TextStyle(
                                color: Theme.of(context).primaryColor))
                      ],
                          style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color:
                                  _darkModeOn ? Colors.white : Colors.black))),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => WidgetsBinding.instance.focusManager.primaryFocus
                      ?.unfocus(),
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
                                  isPwd: true,
                                  pwdIcon: _toggleVisibilityIcon,
                                  showPassword: _toggleVisibility,
                                  hideText: _hidePwd,
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
                                          color:
                                              Theme.of(context).primaryColor),
                                      ButtonState.loading: IconedButton(
                                          text: "Loading",
                                          color:
                                              Theme.of(context).primaryColor),
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
        ),
      ),
    );
  }
}
