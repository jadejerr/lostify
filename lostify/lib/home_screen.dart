import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'report_screen.dart';
import 'search_screen.dart';
import 'notification_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'report_data.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
    const HomeTab(),
    const SearchScreen(),
    const ReportScreen(),
    const NotificationScreen(), 
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _screens.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), label: 'Report'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_none), label: 'Notify'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final supabase = Supabase.instance.client;

  String? _fullName;
  String? _matricNumber;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("Not authenticated");

      final response = await supabase
          .from('users')
          .select('full_name, matric_number')
          .eq('user_id', user.id)
          .single();

      setState(() {
        _fullName = response['full_name'] as String;
        _matricNumber = response['matric_number'] as String;
        _isLoading = false;
      });

    } catch (_) {
      setState(() {
        _fullName = 'User';
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40), 
                const Text("Lostify", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.smart_toy_outlined, color: Colors.blue),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatScreen()),
                    );
                  },
                )
              ],
            ),
            
            const SizedBox(height: 10),

            Row(
              children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: !_isLoading && _matricNumber != null
                    ? NetworkImage(
                        'https://studentphotos.unimas.my/$_matricNumber.jpg',
                      )
                    : null,
                child: _isLoading || _matricNumber == null
                    ? const Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.grey.shade100, blurRadius: 5)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isLoading ? "Welcome…" : "Welcome $_fullName",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          globalReports.isEmpty 
                            ? "No reports submitted yet." 
                            : "${globalReports.length} reports currently active.",
                          style: const TextStyle(fontWeight: FontWeight.bold)
                        ),
                        const Text("Stay safe!", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            
            const Text("Your Report Activity", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            globalReports.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(Icons.history_toggle_off, size: 40, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      const Text("No recent activity", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: globalReports.length,
                itemBuilder: (context, index) {
                  final item = globalReports[index];
                  return _buildReportCard(item);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(ReportItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: item.image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(item.image!, fit: BoxFit.cover),
              )
            : const Icon(Icons.image, color: Colors.grey),
        ),
        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.desc, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              item.status, 
              style: TextStyle(
                color: item.status.contains("Lost") ? Colors.red : Colors.green, 
                fontWeight: FontWeight.bold,
                fontSize: 12,
              )
            ),
          ],
        ),
      ),
    );
  }
}