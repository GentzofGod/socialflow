import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/theme_toggle_button.dart';
import '../data/auth_repository.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _errorMessage = null;
          _successMessage = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthAction() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }

    final repo = ref.read(authRepositoryProvider);
    if (!repo.isConfigured) {
      setState(() => _errorMessage =
          'Supabase is not configured yet. Please check your .env credentials.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      if (_tabController.index == 0) {
        // Sign In
        if (password.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Password cannot be empty.';
          });
          return;
        }
        await repo.signInWithPassword(email: email, password: password);
        if (mounted) context.go('/');
      } else if (_tabController.index == 1) {
        // Sign Up
        if (password.length < 6) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Password must be at least 6 characters long.';
          });
          return;
        }
        final res = await repo.signUp(
          email: email,
          password: password,
          fullName: name.isNotEmpty ? name : null,
        );
        if (res?.session != null) {
          if (mounted) context.go('/');
        } else {
          setState(() {
            _successMessage =
                'Verification email sent! Check your inbox to confirm your account.';
          });
        }
      } else {
        // Magic Link
        await repo.signInWithOtp(email: email);
        setState(() {
          _successMessage =
              'Magic Link sent to $email! Click the link in your email to sign in.';
        });
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'An error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SocialFlow AI'),
        actions: const [
          ThemeToggleButton(),
          SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo & Heading
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppColors.brandGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.bolt_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'SocialFlow AI',
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AI-Powered Social Media Management',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Tabs
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceSecondary
                            : AppColors.lightSurfaceSecondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorSize: TabBarIndicatorSize.tab,
                        indicator: BoxDecoration(
                          color: isDark
                              ? AppColors.primaryBlueDark
                              : AppColors.primaryBlue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        dividerColor: Colors.transparent,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        tabs: const [
                          Tab(text: 'Sign In'),
                          Tab(text: 'Sign Up'),
                          Tab(text: 'Magic Link'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error & Success Banners
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.error,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (_successMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline_rounded,
                              color: AppColors.success,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _successMessage!,
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Full Name (Only on Sign Up)
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, child) {
                        if (_tabController.index != 1) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Full Name',
                              style: textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                hintText: 'Jane Doe',
                                prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),

                    // Email Field
                    Text(
                      'Email Address',
                      style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'you@company.com',
                        prefixIcon: Icon(Icons.mail_outline_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field (Hidden for Magic Link)
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, child) {
                        if (_tabController.index == 2) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscurePassword = !_obscurePassword);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      },
                    ),

                    // Submit Button
                    AnimatedBuilder(
                      animation: _tabController,
                      builder: (context, child) {
                        String btnLabel = 'Sign In';
                        if (_tabController.index == 1) btnLabel = 'Create Account';
                        if (_tabController.index == 2) btnLabel = 'Send Magic Link';

                        return ElevatedButton(
                          onPressed: _isLoading ? null : _handleAuthAction,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(btnLabel),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR',
                            style: textTheme.labelSmall?.copyWith(
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Facebook OAuth Button
                    OutlinedButton.icon(
                      onPressed: _isLoading ? null : () async {
                        final repo = ref.read(authRepositoryProvider);
                        if (!repo.isConfigured) {
                          setState(() => _errorMessage =
                              'Supabase is not configured yet. Please check your .env credentials.');
                          return;
                        }
                        setState(() {
                          _isLoading = true;
                          _errorMessage = null;
                        });
                        try {
                          await repo.signInWithFacebook();
                        } catch (e) {
                          if (mounted) {
                            setState(() => _errorMessage = 'Facebook Sign In error: $e');
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: const Color(0xFF1877F2).withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.facebook_rounded,
                        color: Color(0xFF1877F2),
                        size: 22,
                      ),
                      label: const Text(
                        'Continue with Facebook',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
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
      ),
    );
  }
}
