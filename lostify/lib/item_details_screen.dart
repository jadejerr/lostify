import 'package:flutter/material.dart';
import 'report_data.dart'; 

class ItemDetailsScreen extends StatelessWidget {
  final ReportItem item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Item Details", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: item.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(item.image!, fit: BoxFit.cover),
                    )
                  : const Center(child: Icon(Icons.image, size: 80, color: Colors.grey)),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: item.status.contains("Lost") ? Colors.red.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.status,
                style: TextStyle(
                  color: item.status.contains("Lost") ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),

            Text(item.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            if (item.brand.isNotEmpty)
              Text(item.brand, style: const TextStyle(fontSize: 18, color: Colors.grey)),
            
            const SizedBox(height: 25),
            const Divider(),
            const SizedBox(height: 25),

            _buildDetailRow(Icons.access_time, "Time", item.time),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.location_on, "Location", item.location),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.description, "Description", item.desc),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}