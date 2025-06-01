import 'package:flutter/material.dart';
import 'package:lifelinkai/widgets/custom_text_field.dart';
import 'package:lifelinkai/widgets/blood_type_dropdown.dart';
import 'package:lifelinkai/widgets/custom_button.dart';
import 'package:lifelinkai/utils/constants.dart';

class DonorForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController cinController;
  final TextEditingController fullnameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final String selectedBloodType;
  final bool isLoading;
  final Function(String) onBloodTypeChanged;
  final VoidCallback onSubmit;

  const DonorForm({
    super.key,
    required this.formKey,
    required this.cinController,
    required this.fullnameController,
    required this.emailController,
    required this.phoneController,
    required this.selectedBloodType,
    required this.isLoading,
    required this.onBloodTypeChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormHeader(),
              const SizedBox(height: 24),
              
              CustomTextField(
                controller: cinController,
                labelText: 'CIN',
                prefixIcon: Icons.credit_card_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter your CIN';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: fullnameController,
                labelText: 'Full Name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'You must enter the full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: emailController,
                labelText: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please Enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please Enter a valid Email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              CustomTextField(
                controller: phoneController,
                labelText: 'Phone',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your Phone Number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              
              BloodTypeDropdown(
                selectedBloodType: selectedBloodType,
                onChanged: onBloodTypeChanged,
              ),
              const SizedBox(height: 32),
              
              CustomButton(
                text: 'Add the Donor',
                onPressed: isLoading ? null : onSubmit,
                isLoading: isLoading,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.person_add_alt_1,
            color: AppColors.primaryColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Donor Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Fill in the details below',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}