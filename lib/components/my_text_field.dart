import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget{
  final TextEditingController controller;
  final String hintText;
  final bool oscureText;
  final TextInputType type;
  final FormFieldValidator? validator;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.oscureText, required this.type, this.validator});

  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        validator: validator,
        keyboardType: type,
        controller: controller,
        obscureText: oscureText,
        decoration: InputDecoration(
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent)
          ),
          focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent)
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54)
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black54)
          ),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38),

        ),
      ),
    );
  }
  
}