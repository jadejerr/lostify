import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ManageItemScreen extends StatefulWidget {
  const ManageItemScreen({super.key});

  @override
  State<ManageItemScreen> createState() => _ManageItemScreenState();
}

class _ManageItemScreenState extends State<ManageItemScreen> {
  final supabase = Supabase.instance.client;

  bool _isLoading = true;
  List<Map<String, dynamic>> _claims = [];

  @override
  void initState() {
    super.initState();
    _fetchClaims();
  }

  // FETCH CLAIMS
  Future<void> _fetchClaims() async {
    try {
      final res = await supabase
          .from('claims')
          .select('''
            id,
            status,
            created_at,
            public_reports (
              id,
              title,
              image_url
            ),
            profiles!claims_requester_id_fkey (
              id,
              full_name,
              matric_number
            )
          ''')
          .order('created_at', ascending: false);

      debugPrint('RAW CLAIMS RESULT: $res');

      setState(() {
        _claims = List<Map<String, dynamic>>.from(res);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('MANAGE CLAIM FETCH ERROR: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Claims',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _claims.isEmpty
              ? const Center(child: Text('No claims found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _claims.length,
                  itemBuilder: (context, index) {
                    final claim = _claims[index];
                    final report = claim['public_reports'];
                    final profile = claim['profiles'];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: report?['image_url'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.network(
                                  report['image_url'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.inventory),
                        title: Text(
                          report?['title'] ?? 'Unknown item',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Claimed by ${profile?['full_name'] ?? 'Unknown'}\n'
                          'Status: ${claim['status']}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        isThreeLine: true,
                        trailing: _buildStatusBadge(claim['status']),
                      ),
                    );
                  },
                ),
    );
  }

  // STATUS BADGE
  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'approved':
        color = Colors.green;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return Text(
      status.toUpperCase(),
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }
}
