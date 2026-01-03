import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:livora/core/api/api_service.dart';
import 'package:livora/models/apartment.dart';

class HomeController extends GetxController {
  final userName = ''.obs;
  final role = ''.obs;
  final isowner = false.obs;
  final userId = 0.obs;
  
  final apartments = <Apartment>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await ApiService.loadAuthToken();
    await _loadUserData();
    await loadApartments();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      role.value = prefs.getString('user_role') ?? 'renter';
      userName.value = prefs.getString('user_name') ?? '';
      userId.value = prefs.getInt('user_id') ?? 0;
      
      isowner.value = role.value == 'owner';

      print(' تم تحميل بيانات المستخدم:');
      print('   User ID: ${userId.value}');
      print('   Role: ${role.value}');
      print('   Is Owner: ${isowner.value}');
      print('   Name: ${userName.value}');
      
    } catch (e) {
      print(' خطأ في تحميل بيانات المستخدم: $e');
      isowner.value = false;
    }
  }

  Future<void> loadApartments() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await ApiService.getApartments();
      apartments.value = result;
      
      print('تم تحميل ${result.length} شقة');
      
    } catch (e) {
      errorMessage.value = e.toString();
      print(' خطأ في تحميل الشقق: $e');
      _showErrorSnackbar('فشل في تحميل الشقق'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshApartments() async {
    await loadApartments();
  }

  Future<void> deleteApartment(int apartmentId, int index) async {
    if (apartmentId <= 0 || index < 0 || index >= apartments.length) {
      _showErrorSnackbar('بيانات غير صالحة'.tr);
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تأكيد الحذف'.tr),
        content: Text('هل أنت متأكد من حذف هذه الشقة؟'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('إلغاء'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('حذف'.tr),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final deletedApartment = apartments[index];
    
    apartments.removeAt(index);

    try {
      print('محاولة حذف الشقة #$apartmentId');
      
      final result = await ApiService.deleteApartment(apartmentId);

      if (result['error'] == false) {
        print(' تم حذف الشقة بنجاح');
        _showSuccessSnackbar('تم حذف الشقة بنجاح'.tr);
      } else {
        print(' فشل الحذف: ${result['message']}');
        
        apartments.insert(index, deletedApartment);
        
        if (result['status_code'] == 403 || result['status_code'] == 401) {
          _showErrorSnackbar('لا يمكنك حذف هذه الشقة - أنت لست المالك'.tr);
        } else {
          _showErrorSnackbar(result['message'] ?? 'فشل في حذف الشقة'.tr);
        }
      }
    } catch (e) {
      print(' خطأ أثناء الحذف: $e');
      
      apartments.insert(index, deletedApartment);
      
      _showErrorSnackbar('حدث خطأ أثناء الحذف'.tr);
    }
  }

  Future<void> updateApartment({
    required int apartmentId,
    required String title,
    String? description,
    required double price,
  }) async {
    try {
      print(' محاولة تعديل الشقة #$apartmentId');
      
      final result = await ApiService.updateApartment(
        id: apartmentId,
        title: title,
        description: description,
        price: price,
      );

      if (result['error'] == false) {
        print('تم تعديل الشقة بنجاح');
        _showSuccessSnackbar('تم تعديل الشقة بنجاح'.tr);
        
        await loadApartments();
      } else {
        print(' فشل التعديل: ${result['message']}');
        
        if (result['status_code'] == 403 || result['status_code'] == 401) {
          _showErrorSnackbar('لا يمكنك تعديل هذه الشقة - أنت لست المالك'.tr);
        } else {
          _showErrorSnackbar(result['message'] ?? 'فشل في تعديل الشقة'.tr);
        }
      }
    } catch (e) {
      print('خطأ أثناء التعديل: $e');
      _showErrorSnackbar('حدث خطأ أثناء التعديل'.tr);
    }
  }

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