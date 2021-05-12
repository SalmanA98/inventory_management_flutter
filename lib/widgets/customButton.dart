import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Function() buttonFunction;
  final String buttonText;

  CustomButton({@required this.buttonFunction, this.buttonText = 'Button'});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: buttonFunction,
        style: ElevatedButton.styleFrom(
          primary: Theme.of(context).primaryColor,
          onPrimary: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(18),
            ),
          ),
        ),
        child: Text(buttonText),
      ),
    );
  }
}
