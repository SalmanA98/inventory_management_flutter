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
        primarySwatch: Colors.indigo,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      routes: <String, WidgetBuilder>{
        "Login": (BuildContext context) => LoginPage(),
      },
    );
  }
}
