import 'package:flutter/material.dart';

import 'report_screen.dart';
import 'manage_item_screen.dart';

class StaffReportTabsScreen extends StatelessWidget {
  const StaffReportTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Staff Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Report Item'),
              Tab(text: 'Manage Claim'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // REPORT ITEM
            ReportScreen(
              showBack: false,
            ),

            // MANAGE CLAIMS
            ManageItemScreen(),
          ],
        ),
      ),
    );
  }
}
