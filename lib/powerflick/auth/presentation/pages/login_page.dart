import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // Removed due to dependency conflicts
import './signup_page.dart';

import '../../../../core/constants/k_sizes.dart';
import '../../../../core/presentation/widgets/pf_text_field.dart';
import '../../application/providers.dart';

/// Login page for the app
class LoginPage extends ConsumerStatefulWidget {
  /// Creates a [LoginPage]
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // final _googleSignIn = GoogleSignIn(); // Commented out due to dependency conflicts
  bool _isLoading = false;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final notifier = ref.read(loginNotifierProvider.notifier);
        await notifier.signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );

        final state = ref.read(loginNotifierProvider);
        
        if (state.value?.status == AuthStatus.success) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/control-panel');
          }
        } else if (state.value?.error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.value?.error ?? 'An error occurred'),
                action: state.value?.error?.contains('create an account') == true
                    ? SnackBarAction(
                        label: 'Sign Up',
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/signup');
                        },
                      )
                    : null,
              ),
            );
          }
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error signing in: ${error.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: KSize.xl),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: KSize.xl),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: KSize.xxl),
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: KSize.sm),
                PFTextField(
                  controller: _emailController,
                  hint: 'Enter your email',
                  icon: Icons.mail_outline,
                ),
                const SizedBox(height: KSize.xl),
                const Text(
                  'Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: KSize.sm),
                PFTextField(
                  controller: _passwordController,
                  hint: 'Enter your password',
                  icon: Icons.lock_outline,
                  obscure: true,
                ),
                const SizedBox(height: KSize.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.9,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            side: BorderSide(
                              color: Colors.black.withOpacity(0.3),
                            ),
                          ),
                        ),
                        Text(
                          'Remember me',
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KSize.xl),
                Center(
                  child: Image.asset(
                    'assets/illustrations/smart_home.png',
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: KSize.xl),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _handleSignIn,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4CD964),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: KSize.xl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupPage()),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: Color(0xFF4CD964),
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KSize.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 