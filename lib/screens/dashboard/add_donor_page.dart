import 'package:flutter/material.dart';
import 'package:lifelinkai/models/user.dart';
import 'package:lifelinkai/services/api_service.dart';
import 'package:lifelinkai/widgets/bottom_nav_bar.dart';

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

  // Formulaire
  final TextEditingController _cinController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String _selectedBloodType = "A+";

  // Types de sang disponibles
  final List<String> _bloodTypes = ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"];

  // Couleurs par type de sang
  final Map<String, Color> _bloodTypeColors = {
    "A+": Colors.red.shade600,
    "A-": Colors.red.shade300,
    "B+": Colors.blue.shade600,
    "B-": Colors.blue.shade300,
    "AB+": Colors.purple.shade600,
    "AB-": Colors.purple.shade300,
    "O+": Colors.green.shade600,
    "O-": Colors.green.shade300,
  };

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
        Navigator.pushReplacementNamed(
          context,
          '/donationsPage',
          arguments: widget.user,
        );
        break;
      case 1:
        // Déjà sur cette page
        break;
      case 2:
        Navigator.pushReplacementNamed(
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
      // Préparez les données du donneur
      final Map<String, dynamic> donorData = {
        'cin': _cinController.text,
        'fullname': _fullnameController.text,
        'email': _emailController.text,
        'num_tel': _phoneController.text,
        'blood_type': _selectedBloodType,
        'hospital_id': widget.user.id,
      };

      // Appel à l'API
      await ApiService.addOrUpdateDonor(donorData);

      // Réinitialiser le formulaire
      _cinController.clear();
      _fullnameController.clear();
      _emailController.clear();
      _phoneController.clear();
      setState(() {
        _selectedBloodType = "A+";
      });

      _showNotification("Donneur ajouté avec succès", true);
    } catch (e) {
      _showNotification("Erreur lors de l'ajout du donneur", false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showNotification(String message, bool success) {
    setState(() {
      _notificationMessage = message;
      _isSuccess = success;
    });

    // Masquer la notification après 5 secondes
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _notificationMessage = null;
        });
      }
    });
  }

  Widget _buildNotificationToast() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isSuccess ? Colors.green.shade700 : Colors.red.shade700,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isSuccess ? Icons.check_circle : Icons.error_outline,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _notificationMessage ?? "",
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              expandedHeight: 120,
              backgroundColor: Colors.transparent,
              elevation: 0,
              floating: true,
              pinned: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.water_drop, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.user.nomHospital,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Add New Donor',
                          style: TextStyle(
                            color: Color(0xFFFECACA),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            // Formulaire
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Form(
                  key: _formKey,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Donor Informations',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // CIN
                          TextFormField(
                            controller: _cinController,
                            decoration: InputDecoration(
                              labelText: 'CIN',
                              prefixIcon: const Icon(Icons.credit_card),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please Enter your CIN';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Nom complet
                          TextFormField(
                            controller: _fullnameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'You must enter the full name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Email
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
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
                          const SizedBox(height: 16),
                          
                          // Téléphone
                          TextFormField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone',
                              prefixIcon: const Icon(Icons.phone),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter your Phone Number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Type de sang
                          DropdownButtonFormField<String>(
                            value: _selectedBloodType,
                            decoration: InputDecoration(
                              labelText: 'Blood Type',
                              prefixIcon: const Icon(Icons.water_drop),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: _bloodTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: _bloodTypeColors[type],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(type),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedBloodType = newValue;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Bouton Soumettre
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color(0xFFDC2626),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Add the Donor',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _notificationMessage != null ? _buildNotificationToast() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavigation,
      ),
    );
  }
}