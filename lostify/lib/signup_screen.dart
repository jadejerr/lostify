import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _matricController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isObscured = true;
  bool _isLoading = false;

  // ---------------- REGISTER ----------------

  Future<void> _register() async {
    final supabase = Supabase.instance.client;

    final fullName = _fullNameController.text.trim();
    final matric = _matricController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (fullName.isEmpty ||
        matric.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Create auth user
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName, // metadata
        },
      );

      final user = authResponse.user;
      if (user == null) {
        throw Exception("Registration failed. Try again.");
      }

      // 2️⃣ Insert login mapping (matric → email)
      await supabase.from('users').insert({
        'user_id': user.id,
        'matric_number': matric,
        'email': email,
        'full_name': fullName, // ← REQUIRED
      });

      // 3️⃣ Insert profile (FULL NAME LIVES HERE)
      await supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'matric_number': matric,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account created successfully. Please log in."),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("SIGNUP ERROR: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: $e")),
      );
    }
    finally {
      setState(() => _isLoading = false);
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // BACKGROUND
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1541339907198-e08756dedf3f',
                ),
                fit: BoxFit.cover,
                colorFilter:
                    ColorFilter.mode(Colors.black54, BlendMode.darken),
              ),
            ),
          ),

          // BACK BUTTON
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          // FORM
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  const Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Join the Lostify Community",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 40),

                  _buildTextField(
                    controller: _fullNameController,
                    icon: Icons.person,
                    hint: "Full Name",
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(
                    controller: _matricController,
                    icon: Icons.badge,
                    hint: "Matric Number",
                  ),
                  const SizedBox(height: 15),

                  _buildTextField(
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    hint: "Student Email",
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: _passwordController,
                    obscureText: _isObscured,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Password",
                      hintStyle: const TextStyle(color: Colors.white60),
                      prefixIcon:
                          const Icon(Icons.lock_outline, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscured
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.white70,
                        ),
                        onPressed: () =>
                            setState(() => _isObscured = !_isObscured),
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _isLoading ? null : _register,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- SHARED INPUT ----------------

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
