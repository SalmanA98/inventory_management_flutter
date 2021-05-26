import 'package:flutter/material.dart';

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
    return Container(
      margin: EdgeInsets.only(bottom: 20),
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
                fit: BoxFit.contain,
                child: Text(
                  title,
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              FittedBox(
                fit: BoxFit.contain,
                child: Text(subtitle,
                    style: TextStyle(
                        color: Color(0xffa29aac),
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
