import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
/*   const CustomTextFormField({
    super.key,
    this.textEditingController,
    required this.hintText,
    this.suffixIcon,
    this.onChanged,
  });
  final TextEditingController? textEditingController;
  final String hintText;
  final Widget? suffixIcon;
  final Function(String)? onChanged; */

  final String hintText;
  final TextEditingController? textEditingController;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final String? errorText;
  final bool? obscureText;

  const CustomTextFormField({
    super.key,
    required this.hintText,
    this.textEditingController,
    this.keyboardType,
    this.validator,
    this.errorText,
    this.obscureText,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      keyboardType: keyboardType,
      enableSuggestions: false,
      autocorrect: false,
      validator: validator,
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
        filled: true,
        hintText: hintText,
        errorText: errorText,
        border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))),
      ),
    );
  }
}
