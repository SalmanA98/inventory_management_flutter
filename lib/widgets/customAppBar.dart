import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool needBackButton;

  CustomAppBar(
      {@required this.title,
      @required this.subtitle,
      this.needBackButton = true});

  @override
  Widget build(BuildContext context) {
    var screenHeight = MediaQuery.of(context).size.height;
    return Container(
      margin: EdgeInsets.only(top: screenHeight * 0.07),
      child: Column(children: [
        if (needBackButton)
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_outlined),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        Container(
          child: Column(
            children: [
              FittedBox(
                child: Text(title,
                    style: GoogleFonts.openSans(
                      textStyle:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    )),
              ),
              FittedBox(
                child: Text(
                  subtitle,
                  style: GoogleFonts.openSans(
                      textStyle: TextStyle(
                          color: Color(0xffa29aac),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
