import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final Set<Marker> _markers = {};
  LatLng? _selectedLocation;
  LatLng? _currentLocation;

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        await Geolocator.openLocationSettings();
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      if (_mapController != null) {
        _mapController!.moveCamera(
          CameraUpdate.newLatLng(_currentLocation!),
        );
      }
    } catch (e) {
      print('Error fetching location: $e');
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: location,
          infoWindow: const InfoWindow(title: 'موقع الخدمة'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر موقع الخدمة'),
      ),
      body: Stack(
        children: [
          if (_currentLocation != null)
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation!,
                zoom: 14.0,
              ),
              markers: _markers,
              onTap: _onMapTapped,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            )
          else
            const Center(child: CircularProgressIndicator()),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _selectedLocation != null
                  ? () {
                Navigator.pop(context, _selectedLocation); // Return location
              }
                  : null,
              child: const Text(
                'تأكيد الموقع',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
