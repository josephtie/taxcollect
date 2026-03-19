import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../config/config.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _useBiometric = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkBiometricAvailability();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
                Theme.of(context).primaryColor.withOpacity(0.6),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo and title
                  _buildHeader(),
                  
                  SizedBox(height: 60.h),
                  
                  // Login form
                  _buildLoginForm(),
                  
                  SizedBox(height: 30.h),
                  
                  // Biometric login
                  if (_useBiometric) _buildBiometricLogin(),
                  
                  SizedBox(height: 20.h),
                  
                  // Test credentials
                  _buildTestCredentials(),
                  
                  SizedBox(height: 40.h),
                  
                  // Offline status
                  _buildOfflineStatus(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App logo
        Container(
          width: 120.w,
          height: 120.h,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10.r,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Icon(
            Icons.account_balance,
            size: 60.sp,
            color: Theme.of(context).primaryColor,
          ),
        ),
        
        SizedBox(height: 24.h),
        
        // App title
        Text(
          AppConfig.appName,
          style: TextStyle(
            fontSize: 32.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        
        SizedBox(height: 8.h),
        
        Text(
          AppConfig.appDescription,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: EdgeInsets.all(24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20.r,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connexion',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Username field
            TextFormField(
              controller: _usernameController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Nom d\'utilisateur',
                hintText: 'Entrez votre nom d\'utilisateur',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppConfig.fieldRequired;
                }
                if (value.length < AppConfig.minUsernameLength) {
                  return AppConfig.usernameTooShort;
                }
                return null;
              },
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(
                  FocusNode(),
                );
              },
            ),
            
            SizedBox(height: 16.h),
            
            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                hintText: 'Entrez votre mot de passe',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppConfig.fieldRequired;
                }
                if (value.length < AppConfig.minPasswordLength) {
                  return AppConfig.passwordTooShort;
                }
                return null;
              },
              onFieldSubmitted: (_) => _login(),
            ),
            
            SizedBox(height: 24.h),
            
            // Login button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _login,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'SE CONNECTER',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricLogin() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Connexion Rapide',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          ElevatedButton.icon(
            onPressed: _biometricLogin,
            icon: const Icon(Icons.fingerprint),
            label: const Text('Authentification Biométrique'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Theme.of(context).primaryColor,
              minimumSize: Size(double.infinity, 48.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestCredentials() {
    return Container(
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Identifiants de Test',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          _buildCredentialItem('Agent', 'agent', 'agent123'),
          _buildCredentialItem('Superviseur', 'superviseur', 'superviseur123'),
          _buildCredentialItem('Administrateur', 'admin', 'admin123'),
        ],
      ),
    );
  }

  Widget _buildCredentialItem(String role, String username, String password) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              '$role: $username / $password',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade700,
                fontFamily: 'monospace',
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              _usernameController.text = username;
              _passwordController.text = password;
            },
            icon: Icon(
              Icons.content_copy,
              size: 16.sp,
              color: Colors.grey.shade600,
            ),
            tooltip: 'Copier les identifiants',
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineStatus() {
    return Consumer<ConnectivityService>(
      builder: (context, connectivityService, child) {
        if (connectivityService.isOnline) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi,
                  size: 16.sp,
                  color: Colors.green,
                ),
                SizedBox(width: 8.w),
                Text(
                  'En ligne',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.orange.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi_off,
                  size: 16.sp,
                  color: Colors.orange,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Hors ligne',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<void> _checkBiometricAvailability() async {
    try {
      final authService = context.read<AuthService>();
      final canUseBiometrics = await authService.authenticateWithBiometrics();
      
      if (mounted) {
        setState(() {
          _useBiometric = canUseBiometrics;
        });
      }
    } catch (e) {
      // Biometric not available, that's fine
    }
  }

  Future<void> _login() async {
    // Debug: Vérifier l'état du formulaire avant validation
    print('DEBUG - Form valid: ${_formKey.currentState?.validate()}');
    print('DEBUG - Username field: "${_usernameController.text.trim()}"');
    print('DEBUG - Password field: "${_passwordController.text}"');
    
    if (!_formKey.currentState!.validate()) {
      print('DEBUG - Form validation failed!');
      return;
    }

    // Debug logs pour voir les valeurs après validation
    print('DEBUG - Username validé: "${_usernameController.text.trim()}"');
    print('DEBUG - Password validé: "${_passwordController.text.isNotEmpty ? "***HAS_VALUE***" : "EMPTY"}"');

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final success = await authService.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        // Navigate to dashboard
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _biometricLogin() async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final success = await authService.authenticateWithBiometrics();

      if (success && mounted) {
        // Navigate to dashboard
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur biométrique: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
