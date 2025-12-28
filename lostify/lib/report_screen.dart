import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 
import 'map_screen.dart';
import 'report_data.dart';       
import 'notification_data.dart'; 

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  bool isLostItem = true;
  
  File? _selectedImage;
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  Future<void> _takePicture() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _selectedImage = File(photo.path);
      });
    }
  }

  Future<void> _openMap() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapScreen()),
    );
    if (result != null) {
      setState(() {
        _locationController.text = result;
      });
    }
  }

  void _submitReport() {
    if (_itemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter an Item Name")));
      return;
    }

    final newItem = ReportItem(
      title: _itemController.text,
      brand: _brandController.text,
      desc: _descController.text.isEmpty ? "No description provided" : _descController.text,
      location: _locationController.text.isEmpty ? "Unknown Location" : _locationController.text,
      status: isLostItem ? "Reported Lost" : "Reported Found",
      time: _timeController.text.isEmpty ? "Just now" : _timeController.text,
      image: _selectedImage,
    );

    setState(() {
      globalReports.insert(0, newItem);

      if (!isLostItem) {
        globalNotifications.insert(0, AppNotification(
          title: "New Found Item: ${newItem.title}",
          message: "Someone found a ${newItem.title} at ${newItem.location}. Is it yours?",
          time: "Just now",
          type: "found",
          itemData: newItem, 
        ));
      }

      _itemController.clear();
      _brandController.clear();
      _locationController.clear();
      _timeController.clear();
      _descController.clear();
      _selectedImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report Submitted Successfully!")));

    _checkForMatch(newItem.title, isLostItem);
  }

  void _checkForMatch(String newItemTitle, bool isItemLost) {
    ReportItem? matchingItem; 

    for (int i = 1; i < globalReports.length; i++) {
      final existingItem = globalReports[i];
      bool isOppositeStatus = (isItemLost && existingItem.status == "Reported Found") ||
                              (!isItemLost && existingItem.status == "Reported Lost");

      if (isOppositeStatus && existingItem.title.toLowerCase().contains(newItemTitle.toLowerCase())) {
        matchingItem = existingItem;
        break; 
      }
    }

    if (matchingItem != null) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {

          globalNotifications.insert(0, AppNotification(
            title: "Match Found!",
            message: "We found a match for '$newItemTitle'. Check the details now.",
            time: "Just now",
            type: "match",
            itemData: matchingItem, 
          ));
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(backgroundColor: Colors.green, content: Text("Match Found!")),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLostItem ? "Report Lost Item" : "Report Found Item", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(onTap: () => setState(() => isLostItem = true), child: _buildToggleButton("Lost Item", isLostItem)),
                const SizedBox(width: 15),
                GestureDetector(onTap: () => setState(() => isLostItem = false), child: _buildToggleButton("Found Item", !isLostItem)),
              ],
            ),
            const SizedBox(height: 30),

            _buildTextField("ITEM", "Item Name", _itemController),
            _buildTextField("Brand", "Item Brand", _brandController),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 100, child: Padding(padding: const EdgeInsets.only(top: 12.0), child: Text(isLostItem ? "Possible Place" : "Place Found", style: const TextStyle(fontWeight: FontWeight.bold)))),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
                      child: TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          hintText: "Tap pin to select ->",
                          hintStyle: const TextStyle(color: Colors.black26),
                          border: InputBorder.none,
                          suffixIcon: IconButton(icon: const Icon(Icons.location_on, color: Colors.redAccent), onPressed: _openMap),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            _buildTextField(isLostItem ? "Time Of Lost" : "Time Of Found", "Time", _timeController),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Row(
                children: [
                  const SizedBox(width: 100, child: Text("Item Picture", style: TextStyle(fontWeight: FontWeight.bold))),
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(5), color: Colors.grey.shade50),
                      child: _selectedImage != null
                          ? ClipRRect(borderRadius: BorderRadius.circular(4), child: Image.file(_selectedImage!, fit: BoxFit.cover))
                          : const Icon(Icons.add_photo_alternate_outlined, size: 30),
                    ),
                  ),
                ],
              ),
            ),

            _buildTextField("Description", "...", _descController, maxLines: 2),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5722), padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                onPressed: _submitReport,
                child: const Text("Submit", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
            const Divider(thickness: 1),
            const SizedBox(height: 10),

            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("ITEM", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Expanded(child: Padding(padding: EdgeInsets.only(left: 30.0), child: Text("DETAILS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)))),
                Text("STATUS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 15),

            globalReports.isEmpty 
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text("No items reported yet.", style: TextStyle(color: Colors.grey))),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: globalReports.length,
                  itemBuilder: (context, index) {
                    final item = globalReports[index];
                    return _buildHistoryItem(item);
                  },
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return Container(
      width: 130, padding: const EdgeInsets.symmetric(vertical: 10), alignment: Alignment.center,
      decoration: BoxDecoration(color: isSelected ? Colors.black : Colors.white, border: Border.all(color: Colors.black), borderRadius: BorderRadius.circular(25)),
      child: Text(text, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Padding(padding: const EdgeInsets.only(top: 12.0), child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)))),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.black12))),
              child: TextField(
                controller: controller, maxLines: maxLines,
                decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.black26), border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(ReportItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(8)),
            child: item.image != null
              ? ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(item.image!, fit: BoxFit.cover))
              : const Icon(Icons.image, color: Colors.grey),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)), if (item.brand.isNotEmpty) ...[const SizedBox(width: 5), Text("• ${item.brand}", style: const TextStyle(color: Colors.grey, fontSize: 12))]]),
                Text(item.desc, style: const TextStyle(fontSize: 12, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [const Icon(Icons.location_on, size: 10, color: Colors.grey), const SizedBox(width: 2), Expanded(child: Text(item.location, style: const TextStyle(fontSize: 10, color: Colors.blueGrey), overflow: TextOverflow.ellipsis)), const SizedBox(width: 5), Text(item.time, style: const TextStyle(fontSize: 10, color: Colors.blueGrey))]),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(item.status, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: item.status.contains("Lost") ? Colors.red : Colors.green)),
          ),
        ],
      ),
    );
  }
}