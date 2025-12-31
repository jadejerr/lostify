import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'item_details_screen.dart';
import 'report_data.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _filteredReports = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
    _searchController.addListener(_runFilter);
  }

  // ---------------- FETCH REPORTS ----------------

  Future<void> _fetchReports() async {
    try {
      final res = await supabase
          .from('public_reports')
          .select()
          .eq('status', 'active')
          .order('created_at', ascending: false);

      setState(() {
        _reports = List<Map<String, dynamic>>.from(res);
        _filteredReports = _reports;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('SEARCH FETCH ERROR: $e');
      setState(() => _isLoading = false);
    }
  }

  // ---------------- SEARCH ----------------

  void _runFilter() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredReports = _reports.where((item) {
        return item['title'].toString().toLowerCase().contains(query) ||
            (item['brand'] ?? '')
                .toString()
                .toLowerCase()
                .contains(query);
      }).toList();
    });
  }

  // ---------------- VISUAL SEARCH ----------------

  Future<void> _performVisualSearch() async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo == null) return;

    final inputImage = InputImage.fromFilePath(photo.path);
    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.5),
    );

    final labels = await labeler.processImage(inputImage);
    labeler.close();

    if (labels.isNotEmpty) {
      setState(() {
        _searchController.text = labels.first.label;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Detected: ${labels.first.label}")),
      );
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildBanner(),
              const SizedBox(height: 20),
              _buildResults(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- SEARCH BAR ----------------

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: Colors.grey),
          hintText: "Search items...",
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: const Icon(Icons.center_focus_weak, color: Colors.blue),
            onPressed: _performVisualSearch,
          ),
        ),
      ),
    );
  }

  // ---------------- BANNER ----------------

  Widget _buildBanner() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Center(
          child: Text(
            "What have you lost today?",
            style: GoogleFonts.deliciousHandrawn(
              fontSize: 24,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------- RESULTS ----------------

  Widget _buildResults() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredReports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text("No items match your search")),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.7,
      ),
      itemCount: _filteredReports.length,
      itemBuilder: (context, index) {
        final item = _filteredReports[index];
        final reportItem = ReportItem.fromMap(item);

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ItemDetailsScreen(item: reportItem),
              ),
            );
          },
          child: _buildBelongingItem(
            reportItem.title,
            reportItem.brand ?? 'Unknown',
            reportItem.imageUrl,
          ),
        );
      },
    );
  }

  // ---------------- GRID ITEM ----------------

  Widget _buildBelongingItem(
    String title,
    String brand,
    String? imageUrl,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey.shade200,
              image: imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl == null
                ? const Center(
                    child: Icon(
                      Icons.image,
                      size: 40,
                      color: Colors.grey,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          brand,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    );
  }
}
