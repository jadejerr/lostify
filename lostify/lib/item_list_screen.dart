import 'package:flutter/material.dart';

class ItemListScreen extends StatelessWidget {
  final String category; 

  const ItemListScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    bool isMatric = category == "Matrics Card";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(category, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isMatric ? 3 : 2, 
            childAspectRatio: isMatric ? 0.8 : 0.7, 
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: 8, 
          itemBuilder: (context, index) {
            if (isMatric) {
              return _buildMatricGridItem(index);
            } else {
              return _buildBelongingGridItem(index);
            }
          },
        ),
      ),
    );
  }

  Widget _buildMatricGridItem(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${index + 10}'),
          ),
        ),
        const SizedBox(height: 8),
        Text("973${index}2", style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildBelongingGridItem(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: const DecorationImage(
                image: NetworkImage('https://m.media-amazon.com/images/I/81d8-kC8mCL._AC_UY1000_.jpg'), 
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text("Brand Name", style: TextStyle(color: Colors.grey, fontSize: 12)),
        const Text("Lost Item", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Text("Color", style: TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}