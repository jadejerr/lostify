import 'package:flutter/material.dart';
import 'package:free_map/free_map.dart'; 
import 'package:geolocator/geolocator.dart'; 

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController(); 
  LatLng? _currentPos;

  Future<void> _getCurrentLocation() async {
    // Check permissions (Standard Geolocator logic)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition();
    
    setState(() {
      _currentPos = LatLng(position.latitude, position.longitude);
    });
    
    _mapController.move(_currentPos!, 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Location")),
      body: FmMap(
        mapController: _mapController,
        mapOptions: MapOptions(
          initialCenter: const LatLng(1.4649, 110.4264), // UNIMAS
          initialZoom: 15,
          onTap: (tapPosition, point) {
            Navigator.pop(context, "Lat: ${point.latitude}, Lng: ${point.longitude}");
          },
        ),
        markers: [
          if (_currentPos != null)
            Marker(
              point: _currentPos!,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: const Icon(Icons.gps_fixed),
      ),
    );
  }
}