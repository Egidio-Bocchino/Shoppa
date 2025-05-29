import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomPasswordBox extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final FormFieldValidator<String>? validator;

  const CustomPasswordBox({
    super.key,
    required this.controller,
    this.labelText = 'Password',
    required this.validator,
  });

  @override
  State<CustomPasswordBox> createState() => _CustomPasswordBoxState();
}

class _CustomPasswordBoxState extends State<CustomPasswordBox> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.text,
      obscureText: !_isPasswordVisible,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: TextStyle(color: AppColors.cardTextCol),
        hintStyle: TextStyle(color: AppColors.cardTextCol.withOpacity(0.7)),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.7), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: AppColors.primary.withOpacity(0.7), width: 1.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
        ),
        prefixIcon: Icon(Icons.lock, color: AppColors.cardTextCol),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: AppColors.cardTextCol,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
      ),
      style: TextStyle(color: AppColors.cardTextCol),
      validator: widget.validator,
    );
  }
}