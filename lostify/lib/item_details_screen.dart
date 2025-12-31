import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'report_data.dart';

class ItemDetailsScreen extends StatefulWidget {
  final ReportItem item;

  const ItemDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  State<ItemDetailsScreen> createState() => _ItemDetailsScreenState();
}

class _ItemDetailsScreenState extends State<ItemDetailsScreen> {
  final supabase = Supabase.instance.client;

  bool _isSubmitting = false;
  bool _alreadyClaimed = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyClaimed();
  }

  // CHECK CLAIM STATUS
  Future<void> _checkIfAlreadyClaimed() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final res = await supabase
        .from('claims')
        .select('id')
        .eq('report_id', widget.item.id)
        .eq('requester_id', user.id)
        .maybeSingle();

    if (res != null) {
      setState(() => _alreadyClaimed = true);
    }
  }

  // REQUEST CLAIM
  Future<void> _requestClaim() async {
    setState(() => _isSubmitting = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("Not authenticated");

      await supabase.from('claims').insert({
        'report_id': widget.item.id,
        'requester_id': user.id,
        'status': 'pending',
      });

      setState(() => _alreadyClaimed = true);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Claim request submitted. Waiting for approval."),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit claim request")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLost = widget.item.reportType == 'lost';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Item Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
            // IMAGE
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(20),
              ),
              child: widget.item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        widget.item.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.image, size: 80, color: Colors.grey),
                    ),
            ),

            const SizedBox(height: 20),

            // LOST / FOUND BADGE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isLost
                    ? Colors.red.shade100
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isLost ? "LOST ITEM" : "FOUND ITEM",
                style: TextStyle(
                  color: isLost ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            // TITLE & BRAND
            Text(
              widget.item.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.item.brand != null && widget.item.brand!.isNotEmpty)
              Text(
                widget.item.brand!,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),

            const SizedBox(height: 25),
            const Divider(),
            const SizedBox(height: 25),

            // DETAILS
            _buildDetailRow(
              Icons.access_time,
              "Time",
              widget.item.timeDescription ?? "Not specified",
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              Icons.location_on,
              "Location",
              widget.item.location ?? "Not specified",
            ),
            const SizedBox(height: 20),
            _buildDetailRow(
              Icons.description,
              "Description",
              widget.item.description ?? "No description provided",
            ),

            const SizedBox(height: 30),

            // REQUEST CLAIM BUTTON
            if (!isLost)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _alreadyClaimed || _isSubmitting
                      ? null
                      : _requestClaim,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _alreadyClaimed
                      ? const Text(
                          "Claim Requested",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )
                      : _isSubmitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Request Claim Item",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                ),
              ),
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
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
