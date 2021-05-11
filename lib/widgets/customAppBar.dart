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
    var screenMaxHeight = MediaQuery.of(context).size.height;
    return Column(children: [
      SizedBox(height: screenMaxHeight * 0.10),
      if (needBackButton)
        Container(
          width: double.infinity,
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_outlined),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      if (needBackButton || !needBackButton)
        Container(
          height: screenMaxHeight * 0.08,
          child: Column(
            children: [
              Text(title,
                  style: GoogleFonts.openSans(
                    textStyle:
                        TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  )),
              Text(
                subtitle,
                style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                        color: Color(0xffa29aac),
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
    ]);
  }
}
