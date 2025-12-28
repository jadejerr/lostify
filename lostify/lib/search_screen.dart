import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart'; 
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart'; 
import 'item_list_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _allBelongings = [
    {
      'title': 'Mobile Phone',
      'brand': 'Iphone 17',
      'color': 'Orange',
      'image': 'https://fdn2.gsmarena.com/vv/pics/apple/apple-iphone-14-3.jpg'
    },
    {
      'title': 'Wallet',
      'brand': 'Prada',
      'color': 'Brown',
      'image': 'https://i5.walmartimages.com/seo/Fashion-Women-Wallets-Female-PU-Leather-Wallet-Mini-Ladies-Purse-Zipper-Clutch-Bag-Money-Card-Holder-for-Women-Girl-Pink_1e7bf5be-bef1-4f14-807a-1101dfc6acf0.1486f2ec5b0988c92120f1a8f0fd7e5b.jpeg'
    },
    {
      'title': 'Umbrella',
      'brand': 'Unknown',
      'color': 'Blue',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR5mshM_1lVpfvI55UnnftETYY9qNYUrJz4YA&s'
    },
    {
      'title': 'Laptop',
      'brand': 'Dell',
      'color': 'Silver',
      'image': 'https://ds393qgzrxwzn.cloudfront.net/resize/m600x500/cat1/img/images/0/t6I8pBQ47Q.jpg'
    },
  ];

  List<Map<String, String>> _filteredBelongings = [];

  @override
  void initState() {
    super.initState();
    _filteredBelongings = _allBelongings; 
    _searchController.addListener(_runFilter); 
  }

  void _runFilter() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBelongings = _allBelongings.where((item) {
        return item['title']!.toLowerCase().contains(query) || 
               item['brand']!.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _performVisualSearch() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);

      if (photo == null) return; 

      final InputImage inputImage = InputImage.fromFilePath(photo.path);
      final ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.5);
      final ImageLabeler labeler = ImageLabeler(options: options);
      final List<ImageLabel> labels = await labeler.processImage(inputImage);
      labeler.close(); 

      if (labels.isNotEmpty) {
        String detectedItem = labels.first.label;
        
        setState(() {
          _searchController.text = detectedItem;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Detected: $detectedItem")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not identify item.")),
        );
      }
    } catch (e) {
      print("Error detected: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Camera Error: $e"), 
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
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
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  image: const DecorationImage(
                    image: NetworkImage('https://media.istockphoto.com/id/1582361888/photo/metallic-question-marks-illuminated-by-blue-and-pink-lights-on-blue-and-pink-background.jpg?s=612x612&w=0&k=20&c=LtkGr3xCQuZmMqhu3RIZFAzx6ILDyomk4-pwEiyxWms='), 
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Text(
                    "What you have lost today?",
                    style: GoogleFonts.dancingScript(
                      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87,
                    ),
                  ),
                ),
              ),

              _buildSectionHeader(context, "Matrics Card", () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const ItemListScreen(category: "Matrics Card")
                ));
              }),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildMatricItem("98789", 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTNzzUDHi3fJbB56s9a79YEP9nUOKxurmvR_w&s'),
                    _buildMatricItem("78777", 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRZe852kQf1eZR9LHKGiaPc_KH1HH61BCykRQ&s'),
                    _buildMatricItem("78765", 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAXRrVV2wf1UlE3e7Kx0i6cW2Qblc_fuJm_Q&s'),
                    _buildMatricItem("101123", 'https://registrar.utm.my/bpo/wp-content/uploads/sites/387/2022/01/STAF1-1.png'),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              _buildSectionHeader(context, "Personal Belongings", () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => const ItemListScreen(category: "Personal Belongings")
                ));
              }),
              const SizedBox(height: 15),
              
              _filteredBelongings.isEmpty 
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Center(child: Text("No items match your search")),
                )
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _filteredBelongings.length,
                  itemBuilder: (context, index) {
                    final item = _filteredBelongings[index];
                    return _buildBelongingItem(
                      item['title']!, 
                      item['color']!, 
                      item['brand']!, 
                      item['image']!
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Container(
            color: Colors.transparent, 
            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
            child: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildMatricItem(String id, String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 35,
              backgroundImage: NetworkImage(imageUrl),
              backgroundColor: Colors.grey.shade200,
            ),
          ),
          const SizedBox(height: 8),
          Text(id, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildBelongingItem(String title, String color, String brand, String imageUrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(brand, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(color, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}