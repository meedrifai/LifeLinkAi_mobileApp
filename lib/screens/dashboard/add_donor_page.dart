import 'package:flutter/material.dart';
import 'package:lifelinkai/models/user.dart';
import 'package:lifelinkai/services/api_service.dart';
import 'package:lifelinkai/widgets/bottom_nav_bar.dart';
import 'package:lifelinkai/widgets/donor_form.dart';
import 'package:lifelinkai/widgets/custom_app_bar.dart';
import 'package:lifelinkai/widgets/notification_toast.dart';
import 'package:lifelinkai/utils/constants.dart';

class AddDonorPage extends StatefulWidget {
  final User user;

  const AddDonorPage({super.key, required this.user});

  @override
  _AddDonorPageState createState() => _AddDonorPageState();
}

class _AddDonorPageState extends State<AddDonorPage> {
  final _formKey = GlobalKey<FormState>();
  final int _currentNavIndex = 1;
  bool _isLoading = false;
  String? _notificationMessage;
  bool _isSuccess = true;

  // Form controllers
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedBloodType = "A+";

  @override
  void dispose() {
    _cinController.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleNavigation(int index) {
    if (index == _currentNavIndex) return;
    
    switch (index) {
      case 0:
        Navigator.pushNamed(
          context,
          '/donationsPage',
          arguments: widget.user,
        );
        break;
      case 1:
        // Already on this page
        break;
      case 2:
        Navigator.pushNamed(
          context,
          '/whoWillDonatePage',
          arguments: widget.user,
        );
        break;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> donorData = {
        'cin': _cinController.text,
        'fullname': _fullnameController.text,
        'email': _emailController.text,
        'num_tel': _phoneController.text,
        'blood_type': _selectedBloodType,
        'hospital_id': widget.user.id,
      };

      await ApiService.addOrUpdateDonor(donorData);

      _clearForm();
      _showNotification("Donneur ajouté avec succès", true);
    } catch (e) {
      _showNotification("Erreur lors de l'ajout du donneur", false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    _cinController.clear();
    _fullnameController.clear();
    _emailController.clear();
    _phoneController.clear();
    setState(() {
      _selectedBloodType = "A+";
    });
  }

  void _showNotification(String message, bool success) {
    setState(() {
      _notificationMessage = message;
      _isSuccess = success;
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _notificationMessage = null;
        });
      }
    });
  }

  void _onBloodTypeChanged(String newValue) {
    setState(() {
      _selectedBloodType = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            CustomAppBar(
              hospitalName: widget.user.nomHospital,
              title: "Add New Donor",
              icon: Icons.person_add,
            ),
            
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: DonorForm(
                  formKey: _formKey,
                  cinController: _cinController,
                  fullnameController: _fullnameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  selectedBloodType: _selectedBloodType,
                  isLoading: _isLoading,
                  onBloodTypeChanged: _onBloodTypeChanged,
                  onSubmit: _submitForm,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _notificationMessage != null 
          ? NotificationToast(
              message: _notificationMessage!,
              isSuccess: _isSuccess,
            ) 
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavigation,
      ),
    );
  }
}