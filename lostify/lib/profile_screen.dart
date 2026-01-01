import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'services/user_service.dart';
import 'activity_history_screen.dart'; 
import 'help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _loadUserRole();
  }

  Future<void> _fetchProfile() async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User not authenticated");
      }

      final response = await supabase
          .from('users')
          .select()
          .eq('user_id', user.id)
          .single();

      setState(() {
        _profile = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load profile")),
      );
    }
  }

  Future<void> _loadUserRole() async {
    final role = await UserService.getUserRole();
    setState(() {
      _userRole = role;
    });
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    await Future.delayed(const Duration(milliseconds: 300));
    Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final fullName = _profile?['full_name'] ?? '—';
    final email = _profile?['email'] ?? '—';
    final matric = _profile?['matric_number'] ?? '—';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // PROFILE HEADER
            CircleAvatar(
              radius: 50,
              backgroundImage: !_isLoading && matric != null
                ? _userRole == 'staff'
                    ? NetworkImage('https://upload.wikimedia.org/wikipedia/en/thumb/6/67/UNIMAS.svg/500px-UNIMAS.svg.png')
                    : NetworkImage('https://studentphotos.unimas.my/$matric.jpg')
                : null,
                child: _isLoading || matric == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
            ),
            const SizedBox(height: 15),

            Text(
              fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              email,
              style: const TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 30),

            // DIGITAL ID CARD
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0056B3), Color(0xFF310085)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Matric Number",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        matric,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Role",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _userRole == 'staff' ? 'Staff' : 'Student',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.qr_code_2,
                      size: 50,
                      color: Colors.black,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),

            // MENU OPTIONS
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuOption(
                    context, 
                    Icons.history, 
                    "My Activity History",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ActivityHistoryScreen()),
                      );
                    }
                  ),
                  _buildMenuOption(
                    context, 
                    Icons.help_outline, 
                    "Help & Support", 
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HelpSupportScreen()),
                      );
                    }
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // LOGOUT BUTTON
            TextButton(
              onPressed: _logout,
              child: const Text("Log Out", style: TextStyle(color: Colors.red, fontSize: 16)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuOption(BuildContext context, IconData icon, String title, {required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}