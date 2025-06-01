import 'package:flutter/material.dart';
import 'package:lifelinkai/utils/constants.dart';

class BloodTypeDropdown extends StatefulWidget {
  final String selectedBloodType;
  final Function(String) onChanged;

  const BloodTypeDropdown({
    super.key,
    required this.selectedBloodType,
    required this.onChanged,
  });

  @override
  State<BloodTypeDropdown> createState() => _BloodTypeDropdownState();
}

class _BloodTypeDropdownState extends State<BloodTypeDropdown> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isFocused
              ? [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: DropdownButtonFormField<String>(
          value: widget.selectedBloodType,
          decoration: InputDecoration(
            labelText: 'Blood Type',
            labelStyle: TextStyle(
              color: _isFocused ? AppColors.primaryColor : AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isFocused 
                    ? AppColors.primaryColor.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.water_drop_outlined,
                color: _isFocused ? AppColors.primaryColor : AppColors.textSecondary,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: _isFocused 
                ? AppColors.primaryColor.withOpacity(0.05)
                : Colors.grey.withOpacity(0.05),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: AppConstants.bloodTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppConstants.bloodTypeColors[type],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.bloodTypeColors[type]!.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    type,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              widget.onChanged(newValue);
            }
          },
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _isFocused ? AppColors.primaryColor : AppColors.textSecondary,
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          elevation: 8,
        ),
      ),
    );
  }
}