import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lifelinkai/services/api_service.dart';
import 'package:lifelinkai/models/user.dart';
import 'dart:ui';

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
    
    // Setup heartbeat animation
    _heartbeatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Setup button animation
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _buttonAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );
    
    // Add focus listeners
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
        
        // Success animation before navigation
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: AnimatedBackground(),
          ),
          
          // Main Content
          SafeArea(
            child: Column(
              children: [
                // Logo & Header Area (30% of screen)
                Expanded(
                  flex: 3,
                  child: _buildHeader(),
                ),
                
                // Login Form Area (70% of screen)
                Expanded(
                  flex: 7,
                  child: _buildLoginForm(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Heartbeat Logo
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.08)
                .animate(_heartbeatController),
            child: Hero(
              tag: 'logo',
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.favorite,
                    color: Colors.red.shade700,
                    size: 60,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Animated text
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: const Text(
              'Welcome to LifeLinkAI',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(seconds: 1),
            curve: Curves.easeOutQuart,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: child,
              );
            },
            child: const Text(
              'Connecting Hearts, Saving Lives',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 36),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.9),
                  const Color(0xFFFFF1F3).withOpacity(0.9),
                ],
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Login text with underline animation
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, child) {
                        return Column(
                          children: [
                            const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB71C1C),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 40 * value,
                              height: 3,
                              decoration: BoxDecoration(
                                color: const Color(0xFFB71C1C),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // Animated email field
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutQuint,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(30 * (1 - value), 0),
                          child: child,
                        ),
                      );
                    },
                    child: _buildAnimatedTextField(
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      isFocused: _isEmailFocused,
                      label: 'Email',
                      hint: 'Enter your email',
                      icon: Icons.email_rounded,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Animated password field
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutQuint,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(30 * (1 - value), 0),
                          child: child,
                        ),
                      );
                    },
                    child: _buildAnimatedTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      isFocused: _isPasswordFocused,
                      label: 'Password',
                      hint: 'Enter your password',
                      icon: Icons.lock_rounded,
                      obscureText: true,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Forgot Password link
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: child,
                      );
                    },
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Forgot password functionality
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFB71C1C),
                          padding: EdgeInsets.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Login Button
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutQuint,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: _isLoading
                        ? const Center(
                            child: LoadingIndicator(),
                          )
                        : _buildAnimatedButton(),
                  ),
                  
                  // Error Message
                  if (_errorMessage != null)
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _errorMessage != null ? 1.0 : 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.shade200,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                  const SizedBox(height: 32),
                  
                  // Register link
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 600),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: child,
                      );
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Register functionality
                            },
                            child: const Text(
                              "Register",
                              style: TextStyle(
                                color: Color(0xFFB71C1C),
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
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
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
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
          labelStyle: TextStyle(
            color: const Color(0xFFB71C1C),
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
        ),
        cursorColor: const Color(0xFFB71C1C),
        onChanged: (value) {
          // Clear error when typing
          if (_errorMessage != null) {
            setState(() {
              _errorMessage = null;
            });
          }
        },
      ),
    );
  }

  Widget _buildAnimatedButton() {
    return ScaleTransition(
      scale: _buttonAnimation,
      child: GestureDetector(
        onTapDown: (_) => _buttonController.forward(),
        onTapUp: (_) => _buttonController.reverse(),
        onTapCancel: () => _buttonController.reverse(),
        onTap: _login,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB71C1C), Color(0xFFD32F2F)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB71C1C).withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'SIGN IN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom Loading Indicator
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFB71C1C).withOpacity(0.8),
            const Color(0xFFD32F2F).withOpacity(0.8),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB71C1C).withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Please wait...',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Animated Background
class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF9A0007),
                Color(0xFFB71C1C),
                Color(0xFFD32F2F),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        
        // Animated particles overlay
        PlasmaRenderer(
          type: PlasmaType.infinity,
          particles: 7,
          color: const Color(0xFFFFCDD2),
          blur: 0.4,
          size: 1.0,
          speed: 1.6,
          offset: 0,
          blendMode: BlendMode.plus,
          variation1: 0,
          variation2: 0,
          variation3: 0,
        ),
        
        // Subtle pattern overlay
        Opacity(
          opacity: 0.05,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/pattern.png'),
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Plasma Animation
enum PlasmaType { infinity, bubbles, circle }

class PlasmaRenderer extends StatefulWidget {
  final PlasmaType type;
  final int particles;
  final Color color;
  final double blur;
  final double size;
  final double speed;
  final double offset;
  final BlendMode blendMode;
  final double variation1;
  final double variation2;
  final double variation3;

  const PlasmaRenderer({
    super.key,
    this.type = PlasmaType.infinity,
    this.particles = 10,
    this.color = Colors.white,
    this.blur = 0.75,
    this.size = 1.0,
    this.speed = 1.0,
    this.offset = 0.0,
    this.blendMode = BlendMode.srcOver,
    this.variation1 = 0.0,
    this.variation2 = 0.0,
    this.variation3 = 0.0,
  });

  @override
  _PlasmaRendererState createState() => _PlasmaRendererState();
}

class _PlasmaRendererState extends State<PlasmaRenderer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: PlasmaPainter(
            value: _controller.value,
            type: widget.type,
            particles: widget.particles,
            color: widget.color,
            blur: widget.blur,
            size: widget.size,
            speed: widget.speed,
            offset: widget.offset,
            blendMode: widget.blendMode,
            variation1: widget.variation1,
            variation2: widget.variation2,
            variation3: widget.variation3,
          ),
          child: Container(),
        );
      },
    );
  }
}

class PlasmaPainter extends CustomPainter {
  final double value;
  final PlasmaType type;
  final int particles;
  final Color color;
  final double blur;
  final double size;
  final double speed;
  final double offset;
  final BlendMode blendMode;
  final double variation1;
  final double variation2;
  final double variation3;

  PlasmaPainter({
    required this.value,
    this.type = PlasmaType.infinity,
    this.particles = 10,
    this.color = Colors.white,
    this.blur = 0.75,
    this.size = 1.0,
    this.speed = 1.0,
    this.offset = 0.0,
    this.blendMode = BlendMode.srcOver,
    this.variation1 = 0.0,
    this.variation2 = 0.0,
    this.variation3 = 0.0,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill
      ..blendMode = blendMode;

    final blurSigma = blur * 100;
    if (blurSigma > 0) {
      paint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    }

    final particleSize = size * 50;
    final maxDimension = canvasSize.width > canvasSize.height ? canvasSize.width : canvasSize.height;
    final time = value * speed;
    
    for (int i = 0; i < particles; i++) {
      final progress = (i / particles) + time + offset;
      final modProgress = progress % 1.0;
      
      double x, y;
      double particleSizeFactor = 1.0;
      
      switch (type) {
        case PlasmaType.infinity:
          // Infinity path motion
          final angle = modProgress * 2 * 3.14159;
          final cosAngle = cos(angle);
          final sinAngle = sin(angle * 2);
          x = canvasSize.width * 0.5 + cosAngle * canvasSize.width * 0.3;
          y = canvasSize.height * 0.5 + sinAngle * canvasSize.height * 0.2;
          particleSizeFactor = 0.5 + 0.5 * sin(angle * 3 + variation1);
          break;
          
        case PlasmaType.bubbles:
          // Random bubbling motion
          final seedX = i * 1000.0;
          final seedY = i * 2000.0;
          final radiusSeed = i * 3000.0;
          final radius = canvasSize.width * 0.3;
          
          x = canvasSize.width * 0.5 + sin(seedX + time * 3) * radius;
          y = canvasSize.height * 0.5 + cos(seedY + time * 2) * radius;
          particleSizeFactor = 0.5 + 0.5 * sin(radiusSeed + time * 4);
          break;
          
        case PlasmaType.circle:
          // Circular motion
          final angle = modProgress * 2 * 3.14159;
          x = canvasSize.width * 0.5 + cos(angle) * canvasSize.width * 0.4;
          y = canvasSize.height * 0.5 + sin(angle) * canvasSize.height * 0.4;
          break;
      }
      
      final finalSize = particleSize * particleSizeFactor;
      canvas.drawCircle(Offset(x, y), finalSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PlasmaPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}