import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tajawil_admin/screens/view_location.dart';
import '../models/category.dart';
import '../models/service.dart';
import '../services/firebase_service.dart';
import 'add_service_screen.dart';

class ServicesScreen extends StatefulWidget {
  @override
  _ServicesScreenState createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String? _selectedCategoryId;
  List<Service>? _filteredServices;
  List<Service>? _allServices;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    final firebaseService =
        Provider.of<FirebaseService>(context, listen: false);
    final services = await firebaseService.getServices();
    setState(() {
      _allServices = services;
      _filteredServices = services;
    });
  }

  void _filterServices(String? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      if (categoryId == null || categoryId.isEmpty) {
        _filteredServices = _allServices;
      } else {
        _filteredServices = _allServices!
            .where((service) => service.category.id == categoryId)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Services',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: IconButton(
              icon: Icon(Icons.add_circle_outline,
                  color: Theme.of(context).primaryColor),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddServiceScreen()),
                );
                _fetchServices(); // Refresh after adding
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchServices,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildCategoryFilter(),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              sliver: _buildServicesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return FutureBuilder<List<CategoryModel>>(
      future:
          Provider.of<FirebaseService>(context, listen: false).getCategory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text('No categories available');
        }

        return Container(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildCategoryChip(null, 'All'),
              ...snapshot.data!.map((category) {
                return _buildCategoryChip(category.id, category.name);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String? categoryId, String name) {
    final isSelected = _selectedCategoryId == categoryId;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        backgroundColor: Colors.white,
        selectedColor: Theme.of(context).primaryColor,
        onSelected: (bool selected) {
          _filterServices(selected ? categoryId : null);
        },
      ),
    );
  }

  Widget _buildServicesList() {
    if (_filteredServices == null) {
      return SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_filteredServices!.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No services found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final service = _filteredServices![index];
          return ModernServiceCard(
            service: service,
            onDelete: () async {
              await Provider.of<FirebaseService>(context, listen: false)
                  .deleteService(service.id);
              _fetchServices();
            },
            onViewRatings: () => _showRatings(context, service.id),
            onLocationSelected: (double lat, double long) {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationViewScreen(
                      location: LatLng(lat, long),
                      locationTitle: service.name,
                    ),
                  ));
            },
          );
        },
        childCount: _filteredServices!.length,
      ),
    );
  }

  void _showRatings(BuildContext context, String serviceId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Service Ratings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: Provider.of<FirebaseService>(context, listen: false)
                    .getServiceRatings(serviceId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.star_border, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No ratings yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      final rating = snapshot.data![index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.amber,
                          child: Text(
                            rating['rating'].toString(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          rating['comment'] ?? 'No comment',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Posted on ${DateTime.now().toString().split(' ')[0]}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ModernServiceCard extends StatelessWidget {
  final Service service;
  final VoidCallback onDelete;
  final VoidCallback onViewRatings;
  final Function(double, double) onLocationSelected;

  const ModernServiceCard({
    required this.service,
    required this.onDelete,
    required this.onViewRatings,
    required this.onLocationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Section
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: service.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: Icon(Icons.error),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text(
                          service.averageRating.toStringAsFixed(1),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        service.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[400]),
                      onPressed: () => _showDeleteDialog(context),
                    ),
                  ],
                ),
                SizedBox(height: 8),

                // Category Chip
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    service.category.name,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(height: 12),

                // Description
                Text(
                  service.description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16),

                // Location Info
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        service.address,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: Icon(Icons.star_outline),
                        label: Text('View Ratings'),
                        onPressed: onViewRatings,
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.map),
                        label: Text('View Location'),
                        onPressed: () => onLocationSelected(
                          service.latitude,
                          service.longitude,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Service'),
        content: Text('Are you sure you want to delete this service?'),
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
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
