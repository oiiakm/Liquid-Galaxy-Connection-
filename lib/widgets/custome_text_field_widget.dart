import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextFieldWidget extends StatelessWidget {
  final String labelText;
  final String hintText;
  final String initialValue;
  final Function(String) onChanged;
  final bool readOnly;
  final bool obsecureText;

  const CustomTextFieldWidget({
    Key? key,
    required this.labelText,
    required this.hintText,
    required this.initialValue,
    required this.onChanged,
    this.readOnly = false,
    this.obsecureText=false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = Get.width;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: screenWidth / 3.5,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        obscureText: obsecureText,
        readOnly: readOnly,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(
            color: Colors.cyan,
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        ),
        initialValue: initialValue,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }
}
