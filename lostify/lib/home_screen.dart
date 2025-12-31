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
    HomeTab(),
    SearchScreen(),
    ReportScreen(
    key: ValueKey(
      Supabase.instance.client.auth.currentUser?.id,
    ),
  ),
    NotificationScreen(), 
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_selectedIndex]),
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

  bool _isLoadingUser = true;
  bool _isLoadingReports = true;

  List<Map<String, dynamic>> _reports = [];  

  @override
  void initState() {
    super.initState();
    _fetchUser();
    _fetchReports(); 
  }

  // USER
  Future<void> _fetchUser() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("Not authenticated");

      final res = await supabase
          .from('users')
          .select('full_name, matric_number')
          .eq('user_id', user.id)
          .single();

      setState(() {
        _fullName = res['full_name'];
        _matricNumber = res['matric_number'];
        _isLoadingUser = false;
      });

    } catch (_) {
      setState(() {
        _fullName = 'User';
        _isLoadingUser = false;
      });
    }
  }

  // REPORTS
  Future<void> _fetchReports() async {
    try {
      final res = await supabase
          .from('reports')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false);

      setState(() {
        _reports = List<Map<String, dynamic>>.from(res);
        _isLoadingReports = false;
      });
    } catch (_) {
      setState(() => _isLoadingReports = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBar(context),
            const SizedBox(height: 10),
            _buildHeader(),
            const SizedBox(height: 20),
            const Text("Your Report Activity",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildReportList(),
          ],
        ),
      );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 40),
        const Text(
          "Lostify",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.smart_toy_outlined, color: Colors.blue),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            );
          },
        ),
      ],
    );
  }
     
  Widget _buildHeader() {
      return Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: !_isLoadingUser && _matricNumber != null
                ? NetworkImage(
                    'https://studentphotos.unimas.my/$_matricNumber.jpg')
                : null,
            child: _isLoadingUser || _matricNumber == null
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
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLoadingUser ? "Welcome…" : "Welcome $_fullName",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _reports.isEmpty
                        ? "No reports submitted yet."
                        : "${_reports.length} reports currently active.",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text("Stay safe!",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          )
        ],
      );
    }

  Widget _buildReportList() {
    if (_isLoadingReports) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_reports.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.history_toggle_off,
                size: 40,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 10),
              const Text(
                "No recent activity",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _reports.length,
      itemBuilder: (context, index) {
        final r = _reports[index];
        return _buildReportCard(r);
      },
    );
  }


  Widget _buildReportCard(Map<String, dynamic> report) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: report['image_url'] != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(report['image_url'], fit: BoxFit.cover),
              )
            : const Icon(Icons.image, color: Colors.grey),
        ),
        title: Text(report['title'],
          style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report['description'] ?? '',
              maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(
              report['report_type'] == 'lost'
                ? "Reported Lost"
                : "Reported Found",
              style: TextStyle(
                color: report['report_type'] == 'lost'
                  ? Colors.red
                  : Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}