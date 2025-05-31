import 'package:flutter/material.dart';
import 'package:lifelinkai/services/api_service.dart';
import 'package:lifelinkai/models/user.dart';
import 'package:lifelinkai/widgets/login_form.dart';
import 'package:lifelinkai/widgets/animated_background.dart';
import 'package:lifelinkai/widgets/login_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  
  late AnimationController _heartbeatController;
  late AnimationController _buttonController;
  late Animation<double> _buttonAnimation;
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFocusListeners();
  }

  void _initializeAnimations() {
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
  }

  void _setupFocusListeners() {
    _emailFocusNode.addListener(() {
      setState(() {
        _isEmailFocused = _emailFocusNode.hasFocus;
      });
    });
    
    _passwordFocusNode.addListener(() {
      setState(() {
        _isPasswordFocused = _passwordFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _buttonController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    _buttonController.forward().then((_) => _buttonController.reverse());
    
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter both email and password';
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final User? user = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (user != null) {
        if (user.nomHospital.isEmpty) {
          setState(() {
            _errorMessage = 'User data is incomplete. Please contact support.';
          });
          return;
        }
        
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/donationsPage',
            arguments: user,
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Connection error. Please check your internet.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBackground(),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 3,
                  child: LoginHeader(
                    heartbeatController: _heartbeatController,
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: LoginForm(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    emailFocusNode: _emailFocusNode,
                    passwordFocusNode: _passwordFocusNode,
                    isEmailFocused: _isEmailFocused,
                    isPasswordFocused: _isPasswordFocused,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    buttonAnimation: _buttonAnimation,
                    onLogin: _login,
                    onClearError: _clearError,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}