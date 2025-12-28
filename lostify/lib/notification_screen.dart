import 'package:flutter/material.dart';
import 'notification_data.dart';
import 'item_details_screen.dart'; 

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedFilter = "Found item"; 

  List<AppNotification> get _filteredNotifications {
    if (_selectedFilter == "Found item") {
      return globalNotifications.where((n) => n.type == "found").toList();
    } else if (_selectedFilter == "Match item") {
      return globalNotifications.where((n) => n.type == "match").toList();
    } else if (_selectedFilter == "Claim item") {
      return globalNotifications.where((n) => n.type == "claim").toList();
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Notification", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // 1. FILTER BUTTONS
          SingleChildScrollView(
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
          ),
          const SizedBox(height: 20),

          // 2. THE FILTERED LIST
          Expanded(
            child: _filteredNotifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 60, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text("No ${_selectedFilter.toLowerCase()}s yet", style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredNotifications.length,
                    itemBuilder: (context, index) {
                      final notif = _filteredNotifications[index];
                      return _buildNotificationItem(notif);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title) {
    bool isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          title,
          style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(AppNotification notif) {
    return GestureDetector(
      // --- THE CLICK ACTION ---
      onTap: () {
        if (notif.itemData != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ItemDetailsScreen(item: notif.itemData!),
            ),
          );
        } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Details not available")));
        }
      },
      
      child: Container(
        color: Colors.transparent, 
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: notif.type == "match" ? Colors.green : Colors.blue,
              child: Icon(
                notif.type == "match" ? Icons.check_circle : Icons.search, 
                color: Colors.white
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text("Lostify System", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), 
                      const SizedBox(width: 8),
                      Text(notif.time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notif.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(notif.message, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}