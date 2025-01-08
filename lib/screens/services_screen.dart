import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/service.dart';
import '../services/firebase_service.dart';
import '../widget/service_card.dart';

class ServicesScreen extends StatefulWidget {
  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _addressController;
  String? _selectedUserId;
  CategoryModel? _selectedCategoryId;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _addressController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Services'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddServiceDialog(context),
          ),
        ],
      ),
      body: Consumer<FirebaseService>(
        builder: (context, service, _) {
          return FutureBuilder<List<Service>>(
            future: service.getServices(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No services found'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final service = snapshot.data![index];
                  return ServiceCard(
                    service: service,
                    onDelete: () async {
                      await context
                          .read<FirebaseService>()
                          .deleteService(service.id);
                    },
                    onViewRatings: () => _showRatings(context, service.id),
                    onLocationSelected: (double lat, double long) {
                      setState(() {
                        _latitude = lat;
                        _longitude = long;
                      });
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showAddServiceDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Service'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Required field' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Required field' : null,
                ),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(labelText: 'Address'),
                  validator: (value) =>
                  value?.isEmpty ?? true ? 'Required field' : null,
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: context.read<FirebaseService>().getUsers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return DropdownButtonFormField(
                      value: _selectedUserId,
                      hint: Text('Select User'),
                      items: snapshot.data!.map((user) {
                        return DropdownMenuItem(
                          value: user['id'],
                          child: Text(user['name'] ?? 'Unknown'),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedUserId = value as String),
                      validator: (value) =>
                      value == null ? 'Please select a user' : null,
                    );
                  },
                ),
                FutureBuilder<List<CategoryModel>>(
                  future: context.read<FirebaseService>().getCategory(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }
                    return DropdownButtonFormField(
                      value: _selectedCategoryId,
                      hint: Text('Select Category'),
                      items: snapshot.data!.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) =>
                          setState(() => _selectedCategoryId = value as CategoryModel),
                      validator: (value) =>
                      value == null ? 'Please select a Category' : null,
                    );
                  },
                ),
                ElevatedButton(
                  onPressed: () async {
                    final image = await ImagePicker()
                        .pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setState(() => _imageFile = File(image.path));
                    }
                  },
                  child: Text('Select Image'),
                ),
                ElevatedButton(
                  onPressed: _fetchCurrentLocation,
                  child: Text('Get Current Location'),
                ),
                if (_latitude != null && _longitude != null)
                  Text(
                      'Latitude: ${_latitude!.toStringAsFixed(5)}, Longitude: ${_longitude!.toStringAsFixed(5)}'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                final service = Service(
                  id: '',
                  name: _nameController.text,
                  description: _descriptionController.text,
                  address: _addressController.text,
                  longitude: _longitude ?? 0,
                  latitude: _latitude ?? 0,
                  imageUrl: '',
                  userId: _selectedUserId!,
                  category: _selectedCategoryId!,
                );

                if (_imageFile != null) {
                  await context
                      .read<FirebaseService>()
                      .addService(service, _imageFile!);
                  Navigator.pop(context);
                }
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });
  }

  void _showRatings(BuildContext context, String serviceId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Service Ratings'),
        content: FutureBuilder<List<Map<String, dynamic>>>(
          future: context.read<FirebaseService>().getServiceRatings(serviceId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: snapshot.data!.map((rating) {
                return ListTile(
                  leading: Icon(Icons.star, color: Colors.amber),
                  title: Text('Rating: ${rating['rating']}'),
                  subtitle: Text(rating['comment'] ?? ''),
                );
              }).toList(),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
