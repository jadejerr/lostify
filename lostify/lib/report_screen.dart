import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

import 'map_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final supabase = Supabase.instance.client;

  bool isLostItem = true;
  bool _isSubmitting = false;
  bool _isLoadingReports = true;

  List<Map<String, dynamic>> _myReports = [];
  File? _selectedImage;

  final _itemController = TextEditingController();
  final _brandController = TextEditingController();
  final _locationController = TextEditingController();
  final _timeController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchMyReports();
  }

  // IMAGE PICKER
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(source: source);
    if (xfile == null) return;

    setState(() {
      _selectedImage = File(xfile.path);
    });
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // UPLOAD IMAGE
  Future<String?> _uploadImage(File image) async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final ext = path.extension(image.path);
    final fileName =
        '${user.id}/${DateTime.now().millisecondsSinceEpoch}$ext';

    await supabase.storage.from('report-images').upload(
          fileName,
          image,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from('report-images').getPublicUrl(fileName);
  }

  // MAP
  Future<void> _openMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapScreen()),
    );
    if (result != null) {
      _locationController.text = result;
    }
  }

  // FETCH USER REPORT ACTIVITY
  Future<void> _fetchMyReports() async {
    try {
      final res = await supabase
          .from('reports')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _myReports = List<Map<String, dynamic>>.from(res);
        _isLoadingReports = false;
      });
    } catch (e) {
      debugPrint('FETCH ERROR: $e');
      setState(() => _isLoadingReports = false);
    }
  }

  // SUBMIT REPORT (LOST/FOUND)
  Future<void> _submitReport() async {
    if (_itemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter an Item Name")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("Not authenticated");

      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      await supabase.from('reports').insert({
        'user_id': user.id,
        'report_type': isLostItem ? 'lost' : 'found',
        'title': _itemController.text.trim(),
        'brand': _brandController.text.trim().isEmpty
            ? null
            : _brandController.text.trim(),
        'description': _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        'location': _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        'time_description': _timeController.text.trim().isEmpty
            ? null
            : _timeController.text.trim(),
        'image_url': imageUrl,
        'status': 'active',
      });

      _clearForm();
      await _fetchMyReports();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report submitted successfully")),
      );
    } catch (e) {
      debugPrint('SUBMIT ERROR: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to submit report")),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _clearForm() {
    _itemController.clear();
    _brandController.clear();
    _locationController.clear();
    _timeController.clear();
    _descController.clear();
    setState(() => _selectedImage = null);
  }

 // EDIT REPORT
  void _editReport(Map<String, dynamic> report) {
    _itemController.text = report['title'] ?? '';
    _brandController.text = report['brand'] ?? '';
    _locationController.text = report['location'] ?? '';
    _timeController.text = report['time_description'] ?? '';
    _descController.text = report['description'] ?? '';
    isLostItem = report['report_type'] == 'lost';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Edit Report", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildTextField("Item", "", _itemController),
              _buildTextField("Brand", "", _brandController),
              _buildTextField("Description", "", _descController),
              _buildTextField("Time", "", _timeController),
              _buildLocationField(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await supabase.from('reports').update({
                    'title': _itemController.text.trim(),
                    'brand': _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
                    'description': _descController.text.trim().isEmpty ? null : _descController.text.trim(),
                    'time_description': _timeController.text.trim().isEmpty ? null : _timeController.text.trim(),
                    'location': _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
                    'report_type': isLostItem ? 'lost' : 'found',
                  }).eq('id', report['id']);

                  Navigator.pop(context);
                  _clearForm();
                  await _fetchMyReports();
                },
                child: const Text("Save Changes"),
              )
            ],
          ),
        ),
      ),
    );
  }

  // DELETE REPORT
  void _deleteReport(String reportId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Report"),
        content: const Text("Are you sure you want to delete this report?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await supabase.from('reports').delete().eq('id', reportId);
              Navigator.pop(context);
              await _fetchMyReports();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLostItem ? "Report Lost Item" : "Report Found Item",
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildToggle(),
            const SizedBox(height: 30),
            _buildTextField("ITEM", "Item Name", _itemController),
            _buildTextField("Brand", "Item Brand", _brandController),
            _buildLocationField(),
            _buildTextField(
              isLostItem ? "Time Of Lost" : "Time Of Found",
              "Time",
              _timeController,
            ),
            _buildImagePicker(),
            _buildTextField("Description", "...", _descController, maxLines: 2),
            const SizedBox(height: 20),
            _buildSubmitButton(),
            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 10),
            const Text("My Reports", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildMyReportsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildMyReportsList() {
    if (_isLoadingReports) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myReports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text("No reports are made yet.")),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _myReports.length,
      itemBuilder: (_, i) {
        final r = _myReports[i];

        return Card(
          child: ListTile(
            leading: r['image_url'] != null
                ? Image.network(
                    r['image_url'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.image),
            title: Text(r['title']),
            subtitle: Text(
              r['report_type'] == 'lost'
                  ? "Reported Lost"
                  : "Reported Found",
              style: TextStyle(
                color: r['report_type'] == 'lost'
                    ? Colors.red
                    : Colors.green,
              ),
            ),
            trailing: PopupMenuButton(
              onSelected: (value) {
                if (value == 'edit') _editReport(r);
                if (value == 'delete') _deleteReport(r['id']);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text("Edit")),
                PopupMenuItem(value: 'delete', child: Text("Delete")),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _toggleButton("Lost Item", isLostItem, () {
          setState(() => isLostItem = true);
        }),
        const SizedBox(width: 15),
        _toggleButton("Found Item", !isLostItem, () {
          setState(() => isLostItem = false);
        }),
      ],
    );
  }

  Widget _toggleButton(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? Colors.black : Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(hintText: hint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              isLostItem ? "Possible Place" : "Place Found",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _locationController,
              decoration: InputDecoration(
                hintText: "Tap pin to select",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.location_on, color: Colors.red),
                  onPressed: _openMap,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Row(
        children: [
          const SizedBox(width: 100, child: Text("Item Picture", style: TextStyle(fontWeight: FontWeight.bold))),
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : const Icon(Icons.add_photo_alternate_outlined),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitReport,
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Submit"),
      ),
    );
  }
}
