import 'package:flutter/material.dart';
import 'package:fyp_driver/utils/constants.dart';

class FormTextField extends StatelessWidget {
  const FormTextField(
      {super.key,
      required this.hintText,
      this.keyboardType = TextInputType.text,
      this.validator,
      this.controller});

  final String hintText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: validator,
      controller: controller,
      enableSuggestions: false,
      autocorrect: false,
      style: const TextStyle(
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
        decorationThickness: 0.0,
      ),
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: kHintTextStyle,
      ),
    );
  }
}
