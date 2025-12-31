import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'item_details_screen.dart';
import 'report_data.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final supabase = Supabase.instance.client;

  String _selectedFilter = "Found item";

  bool _isLoadingFound = true;
  bool _isLoadingMatch = false;
  bool _isLoadingClaims = true;

  List<Map<String, dynamic>> _activeFoundItems = [];
  List<Map<String, dynamic>> _matchedItems = [];
  List<Map<String, dynamic>> _myClaims = [];

  @override
  void initState() {
    super.initState();
    _fetchActiveFoundItems().then((_) => _buildMatchedItems());
    _fetchMyClaims();
  }

  // FETCH FOUND ITEMS
  Future<void> _fetchActiveFoundItems() async {
    try {
      final res = await supabase
          .from('public_reports')
          .select()
          .eq('status', 'active')
          .eq('report_type', 'found')
          .order('created_at', ascending: false);

      setState(() {
        _activeFoundItems = List<Map<String, dynamic>>.from(res);
        _isLoadingFound = false;
      });
    } catch (e) {
      debugPrint('FOUND FETCH ERROR: $e');
      setState(() => _isLoadingFound = false);
    }
  }

  // FETCH LOST ITEMS
  Future<List<Map<String, dynamic>>> _fetchMyLostItems() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final res = await supabase
        .from('reports')
        .select()
        .eq('user_id', user.id)
        .eq('report_type', 'lost')
        .eq('status', 'active');

    return List<Map<String, dynamic>>.from(res);
  }

  // MATCHED ITEMS
  Future<void> _buildMatchedItems() async {
    try {
      final myLostItems = await _fetchMyLostItems();
      final foundItems = _activeFoundItems;

      final List<Map<String, dynamic>> matches = [];

      for (final lost in myLostItems) {
        final lostText =
            '${lost['title']} ${lost['brand'] ?? ''}'.toLowerCase();
        final lostWords = lostText.split(RegExp(r'\s+'));

        for (final found in foundItems) {
          final foundText =
              '${found['title']} ${found['brand'] ?? ''}'.toLowerCase();
          final foundWords = foundText.split(RegExp(r'\s+'));

          final hasMatch = lostWords.any(
            (w) => w.length > 2 && foundWords.contains(w),
          );

          if (hasMatch) {
            matches.add(found);
          }
        }
      }

      // REMOVE DUPLICATES
      final uniqueMatches = {
        for (var e in matches) e['id']: e
      }.values.toList();

      setState(() {
        _matchedItems = uniqueMatches;
        _isLoadingMatch = false;
      });
    } catch (e) {
      debugPrint('MATCH ERROR: $e');
      setState(() => _isLoadingMatch = false);
    }
  }

  // FETCH CLAIMS
  Future<void> _fetchMyClaims() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final res = await supabase
          .from('claims')
          .select('status, reports(*)')
          .eq('claimer_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _myClaims = List<Map<String, dynamic>>.from(res);
        _isLoadingClaims = false;
      });
    } catch (e) {
      debugPrint('CLAIM FETCH ERROR: $e');
      setState(() => _isLoadingClaims = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Notification",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          _buildFilters(),
          const SizedBox(height: 20),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  // FILTER BUTTONS
  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildFilterButton("Found item"),
          const SizedBox(width: 10),
          _buildFilterButton("Match item"),
          const SizedBox(width: 10),
          _buildFilterButton("Claim item"),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title) {
    final isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // NOTIFICATION TABS (FOUND, MATCH, CLAIM)
  Widget _buildContent() {
    switch (_selectedFilter) {
      case "Found item":
        return _buildFoundItemList();
      case "Match item":
        return _buildMatchItemList();
      case "Claim item":
        return _buildClaimList();
      default:
        return _buildEmptyState("notifications");
    }
  }

  // FOUND ITEM
  Widget _buildFoundItemList() {
    if (_isLoadingFound) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeFoundItems.isEmpty) {
      return _buildEmptyState("found items");
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _activeFoundItems.length,
      itemBuilder: (_, index) {
        final item = _activeFoundItems[index];
        final reportItem = ReportItem.fromMap(item);

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          child: ListTile(
            leading: item['image_url'] != null
                ? Image.network(item['image_url'], width: 50, fit: BoxFit.cover)
                : const Icon(Icons.image),
            title: Text(item['title']),
            subtitle: Text(item['brand'] ?? 'Unknown'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemDetailsScreen(item: reportItem),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // MATCH ITEM
  Widget _buildMatchItemList() {
    if (_isLoadingMatch) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_matchedItems.isEmpty) {
      return _buildEmptyState("matching items");
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "These are the potential matches to your lost items",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _matchedItems.length,
            itemBuilder: (_, index) {
              final item = _matchedItems[index];
              final reportItem = ReportItem.fromMap(item);

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                child: ListTile(
                  leading: item['image_url'] != null
                      ? Image.network(item['image_url'],
                          width: 50, fit: BoxFit.cover)
                      : const Icon(Icons.image),
                  title: Text(item['title']),
                  subtitle: Text(item['brand'] ?? 'Unknown'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ItemDetailsScreen(item: reportItem),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // CLAIM ITEM
  Widget _buildClaimList() {
    if (_isLoadingClaims) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myClaims.isEmpty) {
      return _buildEmptyState("claim requests");
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _myClaims.length,
      itemBuilder: (_, index) {
        final claim = _myClaims[index];
        final report = claim['reports'];
        if (report == null) return const SizedBox();

        final reportItem =
            ReportItem.fromMap(Map<String, dynamic>.from(report));
        final status = claim['status'];

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          child: ListTile(
            leading: report['image_url'] != null
                ? Image.network(report['image_url'], width: 50, fit: BoxFit.cover)
                : const Icon(Icons.image),
            title: Text(report['title']),
            subtitle: Text(
              'Status: ${status.toUpperCase()}',
              style: TextStyle(
                color: status == 'approved'
                    ? Colors.green
                    : status == 'rejected'
                        ? Colors.red
                        : Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ItemDetailsScreen(item: reportItem),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // HANDLE EMPTY STATE
  Widget _buildEmptyState(String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none,
              size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 10),
          Text("No $label yet", style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
