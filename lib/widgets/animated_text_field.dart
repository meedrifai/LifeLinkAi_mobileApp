import 'package:flutter/material.dart';

class AnimatedTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isFocused;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final TextInputType keyboardType;
  final Function(String)? onChanged;

  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isFocused,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: _buildDecoration(),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: _buildInputDecoration(),
        cursorColor: const Color(0xFFB71C1C),
        onChanged: onChanged,
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    return BoxDecoration(
      color: isFocused ? Colors.white : Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      boxShadow: isFocused
          ? [
              BoxShadow(
                color: const Color(0xFFB71C1C).withOpacity(0.2),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 20,
      ),
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 15,
      ),
      labelText: isFocused ? label : null,
      labelStyle: const TextStyle(
        color: Color(0xFFB71C1C),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      prefixIcon: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(left: 16, right: 8),
        child: Icon(
          icon,
          color: isFocused ? const Color(0xFFB71C1C) : Colors.grey.shade500,
          size: 22,
        ),
      ),
      border: InputBorder.none,
    );
  }
}