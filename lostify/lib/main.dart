import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import 'home_screen.dart';
import 'signup_screen.dart'; 
import 'forgot_password_screen.dart'; 
import 'reset_password_screen.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xtuazsuytftznwarvnoi.supabase.co',
    anonKey: 'sb_publishable_MWNR99pu1E9C08dCMsG_cw_a2hs7Zub',
  );

  runApp(const LostifyApp());
}

class LostifyApp extends StatefulWidget {
  const LostifyApp({super.key});

  @override
  State<LostifyApp> createState() => _LostifyAppState();
}

class _LostifyAppState extends State<LostifyApp> {
  final supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();

    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;

      if (event == AuthChangeEvent.passwordRecovery) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          navigatorKey.currentState
              ?.pushNamedAndRemoveUntil(
            '/reset-password',
            (route) => false,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Lostify',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
      },
    );
  }
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _matricController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isObscured = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  Future<void> _login() async {
    final supabase = Supabase.instance.client;

    final matric = _matricController.text.trim();
    final password = _passwordController.text.trim();

    if (matric.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter matric number and password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String email;

      try {
        final res = await supabase
            .from('users')
            .select('email')
            .eq('matric_number', matric)
            .single();

        email = res['email'];
      } catch (_) {
        if (matric.toLowerCase() == 'staff') {
          email = 'staff@siswa.unimas.my';
        } else {
          throw Exception('User not found');
        }
      }

      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid matric number or password")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1541339907198-e08756dedf3f?ixlib=rb-1.2.1&auto=format&fit=crop&w=1350&q=80'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: const Icon(Icons.school, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  
                  const Text(
                    "Welcome Back",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Text(
                    "Sign in to continue to Lostify",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  // MATRIC NUMBER
                  TextField(
                    controller: _matricController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Matric Number",
                      hintStyle: const TextStyle(color: Colors.white60),
                      prefixIcon: const Icon(Icons.person_outline, color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // PASSWORD
                  TextField(
                    controller: _passwordController,
                    obscureText: _isObscured,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.white60),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured
                            ? Icons.visibility_off
                            : Icons.visibility,
                          color: Colors.white70
                        ),
                        onPressed: () =>
                          setState(() => _isObscured = !_isObscured),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // REMEMBER ME & FORGOT PASSWORD
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Theme(
                            data: ThemeData(unselectedWidgetColor: Colors.white),
                            child: Checkbox(
                              value: _rememberMe,
                              checkColor: Colors.blue,
                              activeColor: Colors.white,
                              onChanged: (bool? value) => setState(() => _rememberMe = value!),
                            ),
                          ),
                          const Text("Remember Me", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      
                      // LINKED BUTTON FOR FORGOT PASSWORD
                      TextButton(
                        onPressed: () {
                          // Navigate to Forgot Password Screen
                          Navigator.pushNamed(context, '/forgot_password');
                        },
                        child: const Text("Forgot Password?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 30),

                  // LOGIN BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                        ? const CircularProgressIndicator(
                          color: Colors.white)
                        : const Text(
                            "LOGIN",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // LINKED BUTTON FOR SIGN UP
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ",
                        style: TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: () {
                          // Navigate to Sign Up Screen
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: const Text(
                          "Sign Up", 
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}