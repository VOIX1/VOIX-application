import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  int _currentStep = 1; // 1 = Email, 2 = Verify Code, 3 = Password Setup

  String? _generatedVerificationCode;
  bool _obscurePassword = true;
  bool _isLoading = false;

  // SENDER EMAIL CREDENTIALS (Replace with your actual sender details)
  final String _senderEmail = 'voix.app.test@gmail.com';
  final String _senderAppPassword = 'umgkozjqzhprhise';

  // Function to send real email using Mailer
  Future<bool> _sendEmailCode(String recipientEmail, String code) async {
    final smtpServer = gmail(_senderEmail, _senderAppPassword);

    final message = Message()
      ..from = Address(_senderEmail, 'VOIX Verification')
      ..recipients.add(recipientEmail)
      ..subject = 'VOIX Account Verification Code'
      ..text = 'Welcome to VOIX!\n\nYour 6-digit email verification code is: $code\n\nEnter this code in the app to complete your registration.';

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      debugPrint('Error sending email: $e');
      return false;
    }
  }

  // Step 1: Generate & send email code
  void _sendVerificationCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final String recipientEmail = _emailController.text.trim().toLowerCase();

      // Check if user already exists
      if (prefs.containsKey('user_$recipientEmail')) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An account with this email already exists.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Generate random 6-digit code
      final random = Random();
      final code = (100000 + random.nextInt(900000)).toString();

      // Send actual email
      final bool emailSent = await _sendEmailCode(recipientEmail, code);

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (emailSent) {
        setState(() {
          _generatedVerificationCode = code;
          _currentStep = 2; // Advance to code entry
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification code sent to $recipientEmail!'),
            backgroundColor: const Color(0xFF2E7D32),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send email. Please check your network and credentials.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Step 2: Verify code
  void _verifyCode() {
    if (_codeController.text.trim() == _generatedVerificationCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email verified! Please set your password.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );
      setState(() {
        _currentStep = 3; // Unlock password creation
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid verification code. Please try again.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // Step 3: Complete Registration
  void _completeRegistration() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final prefs = await SharedPreferences.getInstance();
      final String email = _emailController.text.trim().toLowerCase();

      // Store user account credentials
      await prefs.setString('user_$email', _passwordController.text);

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account registered successfully! Please sign in.'),
          backgroundColor: Color(0xFF2E7D32),
        ),
      );

      Navigator.of(context).pop(); // Return to Login Screen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF2E7D32),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _currentStep == 3
                          ? Icons.lock_outline_rounded
                          : (_currentStep == 2
                          ? Icons.mark_email_read_outlined
                          : Icons.mark_email_unread_outlined),
                      size: 48,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _currentStep == 1
                        ? 'Email Verification'
                        : (_currentStep == 2
                        ? 'Enter 6-Digit Code'
                        : 'Set Password'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _currentStep == 1
                        ? 'Enter your email to receive a 6-digit confirmation code'
                        : (_currentStep == 2
                        ? 'Check your inbox for the code sent to ${_emailController.text}'
                        : 'Create a secure password to complete registration'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // EMAIL INPUT
                  TextFormField(
                    controller: _emailController,
                    enabled: _currentStep == 1,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Please enter an email';
                      if (!value.contains('@') || !value.contains('.')) return 'Enter a valid email';
                      return null;
                    },
                  ),

                  // 6-DIGIT CODE INPUT
                  if (_currentStep >= 2) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _codeController,
                      enabled: _currentStep == 2,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        letterSpacing: 8,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        labelText: '6-Digit Verification Code',
                        prefixIcon: const Icon(Icons.pin_outlined),
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],

                  // PASSWORD INPUTS
                  if (_currentStep == 3) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please enter a password';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_reset_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _isLoading
                          ? null
                          : () {
                        if (_currentStep == 1) {
                          _sendVerificationCode();
                        } else if (_currentStep == 2) {
                          _verifyCode();
                        } else {
                          _completeRegistration();
                        }
                      },
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        _currentStep == 1
                            ? 'Send Verification Code'
                            : (_currentStep == 2
                            ? 'Verify Code'
                            : 'Complete Registration'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  if (_currentStep == 2) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _sendVerificationCode,
                      child: const Text(
                        'Resend Code',
                        style: TextStyle(color: Color(0xFF2E7D32)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}