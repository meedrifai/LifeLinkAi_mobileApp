import 'package:flutter/material.dart';

class DonorSearchBar extends StatelessWidget {
  final Function(String) onChanged;

  const DonorSearchBar({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextField(
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search by CIN...',
          hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 20),
          filled: true,
          fillColor: Colors.grey[200],  // was Colors.white24
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          isDense: true,
        ),
        style: const TextStyle(color: Colors.black87, fontSize: 14),
      ),
    );
  }
}
