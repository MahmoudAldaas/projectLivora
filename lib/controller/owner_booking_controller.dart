import 'package:livora/core/api/api_service.dart';
import 'package:livora/models/owner_booking.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class OwnerBookingController extends GetxController {
  var isLoading = false.obs;
  var bookings = <OwnerBooking>[].obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    fetchPendingBookings();
    super.onInit();
  }

  Future<void> fetchPendingBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      print('جلب طلبات الحجز...');
      
      final result = await ApiService.getOwnerPendingBookings();

      if (result['error'] == true) {
        errorMessage.value = result['message'] ?? 'فشل تحميل الطلبات';
        print('خطأ: ${errorMessage.value}');
        isLoading.value = false;
        return;
      }

      final data = result['data'];
      
      if (data is List) {
        bookings.value = data.map((e) => OwnerBooking.fromJson(e)).toList();
        print('تم جلب ${bookings.length} طلب');
      } else if (data is Map && data['data'] is List) {
        final list = data['data'] as List;
        bookings.value = list.map((e) => OwnerBooking.fromJson(e)).toList();
        print(' تم جلب ${bookings.length} طلب');
      } else if (data is Map && data['bookings'] is List) {
        final list = data['bookings'] as List;
        bookings.value = list.map((e) => OwnerBooking.fromJson(e)).toList();
        print(' تم جلب ${bookings.length} طلب');
      } else {
        bookings.value = [];
        print(' لا يوجد طلبات');
      }

    } catch (e) {
      errorMessage.value = 'حدث خطأ: $e';
      print('خطأ في fetchPendingBookings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approve(int bookingId) async {
    try {
      print(' قبول الحجز #$bookingId');
      
      final res = await ApiService.approveBooking(bookingId: bookingId);
      
      if (res['error'] != true) {
        Get.snackbar(
          'نجح',
          res['message'] ?? 'تم قبول الحجز بنجاح',
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        bookings.removeWhere((b) => b.id == bookingId);
        
        print('تم قبول الحجز وإزالته من القائمة');
      } else {
        Get.snackbar(
          'خطأ',
          res['message'] ?? 'فشل قبول الحجز',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('خطأ في approve: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء قبول الحجز',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> reject(int bookingId) async {
    try {
      print('رفض الحجز #$bookingId');
      
      final res = await ApiService.rejectBooking(bookingId: bookingId);
      
      if (res['error'] != true) {
        Get.snackbar(
          'تم',
          res['message'] ?? 'تم رفض الحجز',
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        bookings.removeWhere((b) => b.id == bookingId);
        
        print('تم رفض الحجز وإزالته من القائمة');
      } else {
        Get.snackbar(
          'خطأ',
          res['message'] ?? 'فشل رفض الحجز',
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print(' خطأ في reject: $e');
      Get.snackbar(
        'خطأ',
        'حدث خطأ أثناء رفض الحجز',
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refresh() async {
    await fetchPendingBookings();
  }
}