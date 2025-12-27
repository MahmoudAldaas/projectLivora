import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/core/api/api_service.dart';
import 'package:livora/models/apartment.dart';

class HomeController extends GetxController {
  //  Data
  RxString userName = ''.obs;
  RxString role = ''.obs;
  RxBool isOwner = false.obs;
  
  // Info Apartment 
  RxList<Apartment> apartments = <Apartment>[].obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadApartments();
  }

  //  Fetch Apartment
  Future<void> loadApartments() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final result = await ApiService.getApartments();
      apartments.value = result;
      
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'خطأ',
        'فشل في تحميل الشقق',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // reload 
  Future<void> refreshApartments() async {
    await loadApartments();
  }

  // ✨ دالة الحذف الجديدة
  Future<void> deleteApartment(int apartmentId, int index) async {
    try {
      // عرض loading
      Get.dialog(
        Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final result = await ApiService.deleteApartment(apartmentId);

      // إخفاء loading
      Get.back();

      if (result['error'] == false) {
        // حذف من القائمة
        apartments.removeAt(index);
        
        Get.snackbar(
          'نجح'.tr,
          'تم حذف الشقة بنجاح'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'خطأ'.tr,
          result['message'] ?? 'فشل في حذف الشقة'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // إخفاء loading
      Get.snackbar(
        'خطأ'.tr,
        'حدث خطأ أثناء الحذف'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}