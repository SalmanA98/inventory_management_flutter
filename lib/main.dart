import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inventory_management/screens/homepage.dart';
import './screens/login.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  //Setting orientation to protrait only
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  await Firebase.initializeApp();

  runApp(MaterialApp(
    //Splash screen animation
    home: AnimatedSplashScreen(
        duration: 1000,
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
    // Color.fromRGBO(18, 18, 18,1.0),
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Color.fromRGBO(69, 54, 88, 1),
        accentColor: Colors.teal[200],
        scaffoldBackgroundColor: Colors.white,
        cardColor: Colors.grey[200],
      ),
      darkTheme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Color.fromRGBO(69, 54, 88, 1),
          accentColor: Colors.teal[200],
          errorColor: Color.fromRGBO(207, 102, 121, 1),
          scaffoldBackgroundColor: Colors.black,
          cardColor: Color.fromRGBO(30, 30, 30, 1)),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: <String, WidgetBuilder>{
        "Login": (BuildContext context) => LoginPage(),
      },
    );
  }
}
