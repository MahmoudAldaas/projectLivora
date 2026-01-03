import 'dart:convert';
import 'package:get/get.dart';
import'package:flutter/material.dart  ';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livora/models/apartment.dart';

class FavoritesController extends GetxController {
  final favorites = <Apartment>[].obs;
  
  final favoriteIds = <int>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getString('favorites');
      
      if (favoritesJson != null && favoritesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(favoritesJson);
        favorites.value = decoded.map((e) => Apartment.fromJson(e)).toList();
        
        favoriteIds.value = favorites.map((apt) => apt.id ?? 0).toList();
        
        print('تم تحميل ${favorites.length} شقة من المفضلة');
      } else {
        print('لا توجد مفضلات محفوظة');
      }
    } catch (e) {
      print('خطأ في تحميل المفضلة: $e');
    }
  }

  Future<void> saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = jsonEncode(
        favorites.map((apt) => apt.toJson()).toList(),
      );
      
      await prefs.setString('favorites', favoritesJson);
      print(' تم حفظ ${favorites.length} شقة في المفضلة');
    } catch (e) {
      print('خطأ في حفظ المفضلة: $e');
    }
  }

  bool isFavorite(int apartmentId) {
    return favoriteIds.contains(apartmentId);
  }

  Future<void> toggleFavorite(Apartment apartment) async {
    if (apartment.id == null) {
      print('الشقة بدون ID');
      return;
    }

    if (isFavorite(apartment.id!)) {
      await removeFromFavorites(apartment.id!);
    } else {
      await addToFavorites(apartment);
    }
  }

  Future<void> addToFavorites(Apartment apartment) async {
    if (apartment.id == null) {
      print(' الشقة بدون ID');
      return;
    }

    if (isFavorite(apartment.id!)) {
      print(' الشقة موجودة بالفعل في المفضلة');
      return;
    }

    favorites.add(apartment);
    favoriteIds.add(apartment.id!);
    
    await saveFavorites();
    
    Get.snackbar(
      'تمت الإضافة',
      'تمت إضافة ${apartment.title} للمفضلة',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.9),
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.favorite, color: Colors.white),
    );
    
    print(' تمت إضافة ${apartment.title} للمفضلة');
  }

  Future<void> removeFromFavorites(int apartmentId) async {
    final apartment = favorites.firstWhere(
      (apt) => apt.id == apartmentId,
      orElse: () => Apartment(title: '', price: ''),
    );
    
    favorites.removeWhere((apt) => apt.id == apartmentId);
    favoriteIds.remove(apartmentId);
    
    await saveFavorites();
    
    Get.snackbar(
      'تمت الإزالة',
      'تمت إزالة ${apartment.title} من المفضلة',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.9),
      colorText: Get.theme.colorScheme.onError,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.heart_broken, color: Colors.white),
    );
    
    print(' تمت إزالة الشقة #$apartmentId من المفضلة');
  }

  Future<void> clearAllFavorites() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(' تأكيد المسح'),
        content: const Text('هل أنت متأكد من مسح جميع المفضلات؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('مسح الكل'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      favorites.clear();
      favoriteIds.clear();
      await saveFavorites();
      
      Get.snackbar(
        'تم المسح',
        'تم مسح جميع المفضلات',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        duration: const Duration(seconds: 2),
      );
      
      print(' تم مسح جميع المفضلات');
    }
  }
}