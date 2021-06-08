import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/homepage.dart';
import './screens/login.dart';

void main() async {
  //Setting orientation to protrait only
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();

  runApp(MaterialApp(
    //Splash screen animation
    home: AnimatedSplashScreen(
        duration: 700,
        centered: true,
        splashTransition: SplashTransition.fadeTransition,
        splashIconSize: 200,
        splash: Image.asset(
          'assets/images/logo.png',
        ),
        nextScreen: MyApp()),
    title: 'Hekayet Etr',
    theme: ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.indigo,
    ),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.indigo,
    ),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.orange[800],
        accentColor: Colors.teal[700],
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.grey[200],
        fontFamily: 'OpenSans',
        shadowColor: Colors.black,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.orange[200],
        accentColor: Colors.teal[200],
        errorColor: Color.fromRGBO(207, 102, 121, 1),
        scaffoldBackgroundColor: Colors.black,
        cardColor: Color.fromRGBO(20, 20, 20, 1),
        fontFamily: 'OpenSans',
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: <String, WidgetBuilder>{
        "Login": (BuildContext context) => LoginPage(),
      },
    );
  }
}
