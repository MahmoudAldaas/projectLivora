import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livora/core/api/api_service.dart';
import 'package:livora/models/apartment.dart';

class HomeController extends GetxController {
  // User Data
  final userName = ''.obs;
  final role = ''.obs;
  final isowner = false.obs;
  
  // Apartment Info
  final apartments = <Apartment>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();  // 👈 جيب بيانات المستخدم
    loadApartments();
  }

  /// 🔥 Load user data from SharedPreferences (نفس طريقة LoginController)
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // قراءة البيانات بنفس المفاتيح اللي حفظها LoginController
      role.value = prefs.getString('user_role') ?? 'renter';
      userName.value = prefs.getString('user_name') ?? '';
      
      // 🔥 تحديد إذا كان owner
      isowner.value = role.value == 'owner';

      print('✅ تم تحميل بيانات المستخدم:');
      print('   Role: ${role.value}');
      print('   Is Owner: ${isowner.value}');
      print('   Name: ${userName.value}');
      
    } catch (e) {
      print('❌ خطأ في تحميل بيانات المستخدم: $e');
      isowner.value = false;
    }
  }

  /// Fetch apartments from API
  Future<void> loadApartments() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await ApiService.getApartments();
      apartments.value = result;
      
    } catch (e) {
      errorMessage.value = e.toString();
      _showErrorSnackbar('فشل في تحميل الشقق'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh apartments list
  Future<void> refreshApartments() async {
    await loadApartments();
  }

  /// Delete apartment with optimistic UI update
  Future<void> deleteApartment(int apartmentId, int index) async {
    if (apartmentId <= 0 || index < 0 || index >= apartments.length) {
      _showErrorSnackbar('بيانات غير صالحة'.tr);
      return;
    }

    // Store apartment for potential rollback
    final deletedApartment = apartments[index];
    
    // Optimistic UI update - remove immediately
    apartments.removeAt(index);

    try {
      final result = await ApiService.deleteApartment(apartmentId);

      if (result['error'] == false) {
        _showSuccessSnackbar('تم حذف الشقة بنجاح'.tr);
      } else {
        // Rollback on failure
        apartments.insert(index, deletedApartment);
        _showErrorSnackbar(result['message'] ?? 'فشل في حذف الشقة'.tr);
      }
    } catch (e) {
      // Rollback on error
      apartments.insert(index, deletedApartment);
      _showErrorSnackbar('حدث خطأ أثناء الحذف'.tr);
    }
  }

  /// Show success snackbar
  void _showSuccessSnackbar(String message) {
    if (Get.isSnackbarOpen) return;
    
    Get.snackbar(
      'نجح'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  /// Show error snackbar
  void _showErrorSnackbar(String message) {
    if (Get.isSnackbarOpen) return;
    
    Get.snackbar(
      'خطأ'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  @override
  void onClose() {
    super.onClose();
  }
}