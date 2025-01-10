import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category.dart';
import '../models/service.dart';
import '../services/firebase_service.dart';
import 'location_picker.dart';

class AddServiceScreen extends StatefulWidget {
  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedGovernorate;
  String? _selectedUserId;
  CategoryModel? _selectedCategoryId;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;

  final List<String> _syrianGovernorates = [
    'دمشق', 'ريف دمشق', 'حلب', 'حمص', 'حماة', 'اللاذقية',
    'طرطوس', 'درعا', 'السويداء', 'القنيطرة', 'دير الزور',
    'الحسكة', 'الرقة', 'إدلب',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          'إضافة خدمة جديدة',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Upload Section
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _imageFile!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'انقر لإضافة صورة',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Service Information Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'معلومات الخدمة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _nameController,
                          label: 'اسم الخدمة',
                          icon: Icons.business,
                          hint: 'أدخل اسم الخدمة',
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'وصف الخدمة',
                          icon: Icons.description,
                          hint: 'أدخل وصف الخدمة',
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // Location Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الموقع والعنوان',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: _addressController,
                          label: 'العنوان التفصيلي',
                          icon: Icons.location_on,
                          hint: 'أدخل العنوان التفصيلي',
                        ),
                        SizedBox(height: 16),
                        _buildDropdownField(
                          value: _selectedGovernorate,
                          items: _syrianGovernorates,
                          label: 'المحافظة',
                          hint: 'اختر المحافظة',
                          onChanged: (value) => setState(() =>
                          _selectedGovernorate = value),
                        ),
                        SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _selectLocation,
                          icon: Icon(Icons.map),
                          label: Text('تحديد الموقع على الخريطة'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        if (_latitude != null && _longitude != null)
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'الموقع: ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),

                // User and Category Section
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'التصنيف والمستخدم',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildUserDropdown(),
                        SizedBox(height: 16),
                        _buildCategoryDropdown(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      'إضافة الخدمة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) => value?.isEmpty ?? true ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget _buildDropdownField({
    required String? value,
    required List<String> items,
    required String label,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) => value == null ? 'هذا الحقل مطلوب' : null,
    );
  }

  Widget _buildUserDropdown() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FirebaseService().getUsers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return DropdownButtonFormField(
          value: _selectedUserId,
          items: snapshot.data!.map((user) {
            return DropdownMenuItem(
              value: user['id'],
              child: Text(user['name'] ?? 'غير معروف'),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedUserId = value as String),
          decoration: InputDecoration(
            labelText: 'المستخدم',
            hintText: 'اختر المستخدم',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) => value == null ? 'هذا الحقل مطلوب' : null,
        );
      },
    );
  }

  Widget _buildCategoryDropdown() {
    return FutureBuilder<List<CategoryModel>>(
      future: FirebaseService().getCategory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        return DropdownButtonFormField(
          value: _selectedCategoryId,
          items: snapshot.data!.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category.name),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedCategoryId = value),
          decoration: InputDecoration(
            labelText: 'التصنيف',
            hintText: 'اختر التصنيف',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (value) => value == null ? 'هذا الحقل مطلوب' : null,
        );
      },
    );
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
  }

  Future<void> _selectLocation() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationPickerScreen()),
    );

    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى ملء جميع الحقول المطلوبة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى اختيار صورة للخدمة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_latitude == null || _longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى تحديد موقع الخدمة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      final service = Service(
        id: '',
        name: _nameController.text,
        description: _descriptionController.text,
        address: _addressController.text,
        longitude: _longitude!,
        latitude: _latitude!,
        imageUrl: '',
        userId: _selectedUserId!,
        category: _selectedCategoryId!,
        governorates: _selectedGovernorate!,
      );

      await FirebaseService().addService(service, _imageFile!);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة الخدمة بنجاح'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back or clear form
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ أثناء إضافة الخدمة'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}

// Add this theme data to your MaterialApp for consistent styling
ThemeData appTheme() {
  return ThemeData(
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[50],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: true,
    ),
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.blue),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}