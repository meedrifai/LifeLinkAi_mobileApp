import 'package:flutter/material.dart';
import 'package:lifelinkai/services/api_service.dart';
import 'package:lifelinkai/widgets/custom_button.dart';
import 'package:lifelinkai/widgets/custom_text_field.dart';
import 'package:lifelinkai/models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('Attempting login with email: ${_emailController.text}');
      final User? user = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        print('Login successful. User data: ${user.toString()}');
        
        // Add a check to ensure user data is not empty
        if (user.nomHospital.isEmpty) {
          setState(() {
            _errorMessage = 'User data is incomplete. Please contact support.';
          });
          return;
        }
        
        Navigator.pushReplacementNamed(
          context,
          '/donationsPage',
          arguments: user,
        );
      } else {
        print('Login failed: user is null');
        setState(() {
          _errorMessage = 'Invalid email or password.';
        });
      }
    } catch (e) {
      print('Login error: $e');
      setState(() {
        _errorMessage = 'An error occurred. Please try again later. ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.35,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 16),
                    Text(
                      'Welcome to LifeLinkAI!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE6EC),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 36,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Your Email',
                          keyboardType: TextInputType.emailAddress,
                          icon: Icons.email,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter an email';
                            }
                            if (!RegExp(
                              r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
                            ).hasMatch(value)) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Password',
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          icon: Icons.lock,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else
                          CustomButton(onPressed: _login, text: 'Sign in'),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}