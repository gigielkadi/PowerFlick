import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import './login_page.dart';

import '../../../../core/constants/k_sizes.dart';
import '../../../../core/presentation/widgets/pf_text_field.dart';
import '../../application/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import './verification_waiting_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _agreeToTerms = false;
  final _googleSignIn = GoogleSignIn();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    // Validate email
    final emailError = _emailController.text.isEmpty ? 'Email is required' :
      !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(_emailController.text) ?
      'Please enter a valid email address' : null;
    
    // Validate password
    final passwordError = _passwordController.text.isEmpty ? 'Password is required' :
      _passwordController.text.length < 6 ? 'Password must be at least 6 characters' : null;
    
    // Validate password confirmation
    final confirmPasswordError = _confirmPasswordController.text.isEmpty ? 'Please confirm your password' :
      _confirmPasswordController.text != _passwordController.text ? 'Passwords do not match' : null;

    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError)),
      );
      return;
    }

    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(passwordError)),
      );
      return;
    }

    if (confirmPasswordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(confirmPasswordError)),
      );
      return;
    }

    if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms & Conditions'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(signupNotifierProvider.notifier);
      await notifier.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      final state = ref.read(signupNotifierProvider);
      
      if (state.value?.status == AuthStatus.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => VerificationWaitingPage(email: _emailController.text.trim()),
            ),
          );
        }
      } else if (state.value?.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.value?.error}')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing up: ${error.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    try {
      setState(() => _isLoading = true);
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google sign-in was cancelled')),
          );
        }
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Sign in with Supabase using Google OAuth
      final AuthResponse response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to sign in with Google')),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing in with Google: ${error.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final signupState = ref.watch(signupNotifierProvider);
    final isLoading = signupState.value?.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 45,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: KSize.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create an account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: KSize.md),
              PFTextField(
                controller: _emailController,
                hint: 'Enter your email',
                icon: Icons.mail_outline,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email is required';
                  }
                  // RFC 5322 email validation regex
                  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: KSize.md),
              PFTextField(
                controller: _passwordController,
                hint: 'Enter your password',
                icon: Icons.lock_outline,
                obscure: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: KSize.md),
              PFTextField(
                controller: _confirmPasswordController,
                hint: 'Confirm your password',
                icon: Icons.lock_outline,
                obscure: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: KSize.sm),
              Row(
                children: [
                  Transform.scale(
                    scale: 0.8,
                    child: Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreeToTerms = value ?? false;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: BorderSide(
                        color: Colors.black.withOpacity(0.3),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'I agree with ',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: 'Terms & Conditions',
                            style: const TextStyle(
                              color: Color(0xFF4CD964),
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // TODO: Navigate to terms and conditions
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KSize.md),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: isLoading ? null : _handleSignUp,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4CD964),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: KSize.xs),
              const Center(
                child: Text(
                  'OR',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: KSize.xs),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleSignUp,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5E5EA),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    side: BorderSide.none,
                  ),
                  icon: const Icon(
                    Icons.g_mobiledata,
                    size: 20,
                    color: Colors.black87,
                  ),
                  label: const Text(
                    'Sign up with Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: KSize.xs),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement Apple sign up
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    side: BorderSide.none,
                  ),
                  icon: const Icon(
                    Icons.apple,
                    color: Colors.white,
                    size: 24,
                  ),
                  label: const Text(
                    'Sign up with Apple',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: KSize.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        color: Color(0xFF4CD964),
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KSize.sm),
            ],
          ),
        ),
      ),
    );
  }
} 