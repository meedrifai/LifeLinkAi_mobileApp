import 'dart:ui';
import 'package:flutter/material.dart';
import 'animated_text_field.dart';
import 'animated_button.dart';
import 'error_message.dart';
import 'loading_indicator.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocusNode;
  final FocusNode passwordFocusNode;
  final bool isEmailFocused;
  final bool isPasswordFocused;
  final bool isLoading;
  final String? errorMessage;
  final Animation<double> buttonAnimation;
  final VoidCallback onLogin;
  final VoidCallback onClearError;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.emailFocusNode,
    required this.passwordFocusNode,
    required this.isEmailFocused,
    required this.isPasswordFocused,
    required this.isLoading,
    required this.errorMessage,
    required this.buttonAnimation,
    required this.onLogin,
    required this.onClearError,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _buildContainerDecoration(),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 36),
            decoration: _buildGradientDecoration(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLoginTitle(),
                  const SizedBox(height: 40),
                  _buildEmailField(),
                  const SizedBox(height: 24),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildForgotPasswordLink(),
                  const SizedBox(height: 40),
                  _buildLoginButton(),
                  if (errorMessage != null) ...[
                    ErrorMessage(message: errorMessage!),
                  ],
                  const SizedBox(height: 32),
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
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
    );
  }

  BoxDecoration _buildGradientDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withOpacity(0.9),
          const Color(0xFFFFF1F3).withOpacity(0.9),
        ],
      ),
    );
  }

  Widget _buildLoginTitle() {
    return Center(
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
    );
  }

  Widget _buildEmailField() {
    return TweenAnimationBuilder<double>(
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
      child: AnimatedTextField(
        controller: emailController,
        focusNode: emailFocusNode,
        isFocused: isEmailFocused,
        label: 'Email',
        hint: 'Enter your email',
        icon: Icons.email_rounded,
        keyboardType: TextInputType.emailAddress,
        onChanged: (_) => onClearError(),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TweenAnimationBuilder<double>(
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
      child: AnimatedTextField(
        controller: passwordController,
        focusNode: passwordFocusNode,
        isFocused: isPasswordFocused,
        label: 'Password',
        hint: 'Enter your password',
        icon: Icons.lock_rounded,
        obscureText: true,
        onChanged: (_) => onClearError(),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return TweenAnimationBuilder<double>(
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
    );
  }

  Widget _buildLoginButton() {
    return TweenAnimationBuilder<double>(
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
      child: isLoading
          ? const Center(child: LoadingIndicator())
          : AnimatedButton(
              animation: buttonAnimation,
              onTap: onLogin,
            ),
    );
  }

  Widget _buildRegisterLink() {
    return TweenAnimationBuilder<double>(
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
    );
  }
}