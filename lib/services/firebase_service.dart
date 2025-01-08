import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../models/category.dart';
import '../models/service.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage =
  FirebaseStorage.instanceFor(bucket: "car-shop-2a53b.appspot.com");

  // Users
  Future<List<Map<String, dynamic>>> getUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
    notifyListeners();
  }

  // Services
  Future<List<Service>> getServices() async {
    final snapshot = await _firestore.collection('services').get();
    return snapshot.docs
        .map((doc) => Service.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addService(Service service, File imageFile) async {
    // Upload image

    final imageRef = _storage.ref().child('services/${DateTime.now()}.jpg');
    await imageRef.putFile(imageFile);
    final imageUrl = await imageRef.getDownloadURL();

    // Add service with image URL
    await _firestore.collection('services').add({
      ...service.toMap(),
      'imageUrl': imageUrl,
    });
    notifyListeners();
  }

  Future<void> deleteService(String serviceId) async {
    await _firestore.collection('services').doc(serviceId).delete();
    notifyListeners();
  }

  // Ratings
  Future<List<Map<String, dynamic>>> getServiceRatings(String serviceId) async {
    final snapshot = await _firestore
        .collection('services')
        .doc(serviceId)
        .collection('ratings')
        .get();
    return snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
  }

  // category
  Future<List<CategoryModel>> getCategory() async {
    final snapshot = await _firestore.collection('categories').get();
    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addCategory(CategoryModel service) async {
    var catRef= _firestore.collection('categories');
    service.id=catRef.id;
    await catRef.add(service.toMap());
    notifyListeners();
  }

  Future<void> deleteCategory(String categoryId) async {
    await _firestore.collection('categories').doc(categoryId).delete();
    notifyListeners();
  }
}
