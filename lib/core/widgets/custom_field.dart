import 'package:flutter/material.dart';

class CustomField extends StatelessWidget {
  final String hinttext;
  final TextEditingController? controller;
  final bool isobscureText; // this is for password characters hiding
  final bool readOnly;
  final VoidCallback? onTap;
  const CustomField({
    super.key,
    required this.hinttext,
    required this.controller,
    this.isobscureText = false,
    this.readOnly = false,
    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      readOnly: readOnly,
      decoration: InputDecoration(hintText: hinttext),
      controller: controller,
      obscureText: isobscureText,
      //validator:(input_string){} , for calling validator method using the form methods below is implementations
      validator: (inputstate) {
        if (inputstate == null || inputstate.trim().isEmpty) {
          //trim to remove all spaces so user cant fool us
          return '$hinttext is missing!';
        } else {
          return null;
        }
      },
    );
  }
}
