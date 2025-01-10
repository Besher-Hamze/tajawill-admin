import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/service.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onDelete;
  final VoidCallback onViewRatings;
  final Function(double, double) onLocationSelected;

  const ServiceCard({
    required this.service,
    required this.onDelete,
    required this.onViewRatings,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cached Image
          CachedNetworkImage(
            imageUrl: service.imageUrl,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Name
                Text(
                  service.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 8),

                // Service Description
                Text(service.description),
                SizedBox(height: 8),

                // Service Category
                Text("Category: ${service.category.name}"),
                SizedBox(height: 8),

                // Service Address
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16),
                    SizedBox(width: 4),
                    Expanded(child: Text(service.address)),
                  ],
                ),
                SizedBox(height: 8),

                // Latitude and Longitude with Edit Button
                Row(
                  children: [
                    Text("Latitude: ${service.latitude.toStringAsFixed(5)}"),
                    Spacer(),
                    Text("Longitude: ${service.longitude.toStringAsFixed(5)}"),
                    Spacer(),
                  ],
                ),
                SizedBox(height: 8),

                // Ratings and Actions
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                        '${service.averageRating.toStringAsFixed(1)} (${service.totalRates} ratings)'),
                    Spacer(),
                    TextButton(
                      onPressed: onViewRatings,
                      child: Text('View Ratings'),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Service'),
                          content: Text(
                              'Are you sure you want to delete this service?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                onDelete();
                                Navigator.pop(context);
                              },
                              child: Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
