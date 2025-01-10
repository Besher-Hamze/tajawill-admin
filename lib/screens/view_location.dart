import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationViewScreen extends StatefulWidget {
  final LatLng location; // Location to view
  final String? locationTitle; // Optional title for the marker

  const LocationViewScreen({
    super.key,
    required this.location,
    this.locationTitle,
  });

  @override
  State<LocationViewScreen> createState() => _LocationViewScreenState();
}

class _LocationViewScreenState extends State<LocationViewScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMarker();
  }

  void _initializeMarker() {
    _markers.add(
      Marker(
        markerId: const MarkerId('view_location'),
        position: widget.location,
        infoWindow: InfoWindow(title: widget.locationTitle ?? 'Selected Location'),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationTitle ?? 'View Location'),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.location,
          zoom: 14.0, // Adjust the zoom level as needed
        ),
        markers: _markers,
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
      ),
    );
  }
}
