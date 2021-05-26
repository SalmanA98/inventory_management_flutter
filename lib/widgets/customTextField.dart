import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController textController;
  final String textHint;
  final TextInputType keyboardType;
  final int maximumLines;
  final int maximumLength;
  final Icon textIcon;
  final bool hideText;
  final bool isPwd;
  final Function() showPassword;
  final Icon pwdIcon;

  CustomTextField({
    @required this.textController,
    @required this.textHint,
    @required this.textIcon,
    this.keyboardType = TextInputType.text,
    this.maximumLines = 1,
    this.maximumLength = 25,
    this.hideText = false,
    this.isPwd = false,
    this.showPassword,
    this.pwdIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: textController,
      maxLength: maximumLength,
      maxLines: maximumLines,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: textHint,
        counterText: '',
        prefixIcon: textIcon,
        suffixIcon: isPwd
            ? IconButton(
                onPressed: () {
                  showPassword();
                },
                icon: pwdIcon)
            : null,
        filled: true,
        contentPadding: EdgeInsets.all(15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(width: 0, style: BorderStyle.none),
        ),
      ),
      keyboardType: keyboardType,
      obscureText: hideText,
    );
  }
}
