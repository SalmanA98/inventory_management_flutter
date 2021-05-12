import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/customButton.dart';
import '../widgets/customTextField.dart';
import '../widgets/customAppBar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameInput = TextEditingController();
  final _pwdInput = TextEditingController();
  String username;
  String pwd;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
            title: Text('ERROR'),
            content: Text(errormessage),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'))
            ],
          );
        });
  }

  _authenticateUser() async {
    username = _usernameInput.text;
    pwd = _pwdInput.text;
    if (username.isEmpty || pwd.isEmpty) {
      return;
    }
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: username + '@hekayet3tr.com', password: pwd);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showError('No user found for that email!');
      } else if (e.code == 'wrong-password') {
        showError('Wrong password provided for that user.');
      } else {
        showError(e.message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenMaxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          CustomAppBar(
            title: 'Hekayet Etr',
            subtitle: 'Login to continue',
            needBackButton: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 100,
                  ),
                  Container(
                      margin: EdgeInsets.all(10),
                      height: 150,
                      width: double.infinity,
                      alignment: Alignment.centerLeft,
                      child: Image.asset('assets/images/logo.png')),
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
                            textIcon: Icon(Icons.admin_panel_settings_outlined),
                            textHint: 'Password'),
                        SizedBox(
                          height: 20,
                        ),
                        CustomButton(
                          buttonFunction: _authenticateUser,
                          buttonText: 'Login',
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
