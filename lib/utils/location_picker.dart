import 'package:flutter/material.dart';

class LocationPicker extends StatefulWidget {
  final Function(double latitude, double longitude) onLocationPicked;

  const LocationPicker({required this.onLocationPicked});

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: _latController,
          decoration: InputDecoration(labelText: 'Latitude'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter latitude';
            }
            final lat = double.tryParse(value);
            if (lat == null || lat < -90 || lat > 90) {
              return 'Invalid latitude';
            }
            return null;
          },
        ),
        TextFormField(
          controller: _lngController,
          decoration: InputDecoration(labelText: 'Longitude'),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter longitude';
            }
            final lng = double.tryParse(value);
            if (lng == null || lng < -180 || lng > 180) {
              return 'Invalid longitude';
            }
            return null;
          },
        ),
        ElevatedButton(
          onPressed: () {
            final lat = double.tryParse(_latController.text);
            final lng = double.tryParse(_lngController.text);
            if (lat != null && lng != null) {
              widget.onLocationPicked(lat, lng);
            }
          },
          child: Text('Confirm Location'),
        ),
      ],
    );
  }
}
