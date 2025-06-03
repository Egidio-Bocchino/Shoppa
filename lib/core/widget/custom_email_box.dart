import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomEmailBox extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final FormFieldValidator<String?>? validator;

  const CustomEmailBox({
    super.key,
    required this.controller,
    this.labelText = 'Email',
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.text,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        errorStyle: const TextStyle(height: 0),
        labelText: labelText,
        labelStyle: TextStyle(color: AppColors.cardTextCol),
        hintStyle: TextStyle(color: AppColors.cardTextCol.withValues()),

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

        prefixIcon: Icon(Icons.email, color: AppColors.cardTextCol),
      ),
      style: TextStyle(color: AppColors.cardTextCol),
      validator: validator,
    );
  }
}