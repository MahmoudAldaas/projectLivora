import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/api/api_service.dart';

class MyBookingsController extends GetxController {
  var isLoading = false.obs;
  var bookings = <Map<String, dynamic>>[].obs;
  var errorMessage = ''.obs;

  var isSubmittingReview = false.obs;
  var reviewMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyBookings();
  }

  Future<void> fetchMyBookings() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await ApiService.getMyBookings();

      if (response['error'] == false) {
        final List list = response['data'] ?? [];
        bookings.value = list
            .map((e) => {
                  ...Map<String, dynamic>.from(e),
                  'apartment_title': e['apartment']?['title'] ?? 'شقة بدون عنوان',
                })
            .toList();
      } else {
        errorMessage.value = response['message'] ?? 'فشل جلب الحجوزات';
      }
    } catch (e) {
      errorMessage.value = 'خطأ في الاتصال بالخادم';
      print('Error in fetchMyBookings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<Map<String, dynamic>> get activeBookings =>
      bookings.where((b) => b['status'] == 'approved').toList();

  List<Map<String, dynamic>> get pendingBookings =>
      bookings.where((b) => b['status'] == 'pending').toList();

  List<Map<String, dynamic>> get rejectedBookings =>
      bookings.where((b) => b['status'] == 'rejected').toList();

  List<Map<String, dynamic>> get cancelledBookings =>
      bookings.where((b) => b['status'] == 'cancelled').toList();

  Future<void> cancelBooking(int bookingId) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await ApiService.cancelBooking(bookingId: bookingId);
      Get.back();

      if (response['error'] == false) {
        Get.snackbar(
          'نجح',
          'تم إلغاء الحجز بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 3),
        );
        await fetchMyBookings();
      } else {
        Get.snackbar(
          'خطأ',
          response['message'] ?? 'فشل إلغاء الحجز',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        'خطأ',
        'حدث خطأ في الاتصال: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
      print(' Error in cancelBooking: $e');
    }
  }

  Future<void> updateBooking({
    required int bookingId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);

      if (end.isBefore(start) || end.isAtSameMomentAs(start)) {
        Get.snackbar(
          ' تحذير',
          'تاريخ النهاية يجب أن يكون بعد تاريخ البداية',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await ApiService.updateBooking(
        bookingId: bookingId,
        startDate: startDate,
        endDate: endDate,
      );

      Get.back();

      if (response['error'] == false) {
        Get.snackbar(
          'نجح',
          'تم تعديل الحجز بنجاح',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 3),
        );
        await fetchMyBookings();
      } else {
        String errorMsg = response['message'] ?? 'فشل تعديل الحجز';
        if (response['errors'] != null) {
          final errors = response['errors'] as Map<String, dynamic>;
          errorMsg = errors.values.first.toString();
        }
        Get.snackbar(
          'خطأ',
          errorMsg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        ' خطأ',
        'حدث خطأ في الاتصال: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
      );
      print(' Error in updateBooking: $e');
    }
  }

  void showEditDialog(Map<String, dynamic> booking) {
    if (booking['status'] != 'pending' && booking['status'] != 'approved') {
      Get.snackbar(
        'تحذير',
        'لا يمكن تعديل حجز ${getStatusText(booking['status'])}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    DateTime startDate = DateTime.parse(booking['start_date']);
    DateTime endDate = DateTime.parse(booking['end_date']);

    final startDateController = TextEditingController(
      text:
          '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}',
    );
    final endDateController = TextEditingController(
      text:
          '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}',
    );

    showDialog(
      context: Get.context!,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit_calendar, color: Get.theme.colorScheme.primary),
              const SizedBox(width: 8),
              const Text('تعديل الحجز'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('الشقة: ${booking['apartment_title']}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      startDateController.text =
                          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: startDateController,
                      decoration: InputDecoration(
                        labelText: 'تاريخ البداية',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      endDateController.text =
                          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: endDateController,
                      decoration: InputDecoration(
                        labelText: 'تاريخ النهاية',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                updateBooking(
                  bookingId: booking['id'],
                  startDate: startDateController.text,
                  endDate: endDateController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Get.theme.colorScheme.primary),
              child: const Text('حفظ التعديلات'),
            ),
          ],
        );
      },
    );
  }

  void confirmCancelBooking(Map<String, dynamic> booking) {
    if (booking['status'] == 'cancelled') {
      Get.snackbar(
        ' تحذير',
        'هذا الحجز ملغى بالفعل',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Get.theme.colorScheme.error),
            const SizedBox(width: 8),
            const Text('تأكيد الإلغاء'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('هل أنت متأكد من إلغاء حجز:'),
            const SizedBox(height: 8),
            Text(
              booking['apartment_title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('من ${booking['start_date']} إلى ${booking['end_date']}؟'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('لا')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              cancelBooking(booking['id']);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.colorScheme.error),
            child: const Text('نعم، إلغاء الحجز'),
          ),
        ],
      ),
    );
  }

  bool canReviewBooking(Map<String, dynamic> booking) {
    if (booking['status'] != 'approved') return false;
    final endDate = DateTime.parse(booking['end_date']);
    return endDate.isBefore(DateTime.now());
  }

  Future<void> submitBookingReview({
    required int bookingId,
    required int rating,
    String? review,
  }) async {
    try {
      isSubmittingReview.value = true;
      reviewMessage.value = '';

      final response = await ApiService.submitBookingReview(
        bookingId: bookingId,
        rating: rating,
        review: review,
      );

      if (response['error'] == false) {
        reviewMessage.value = response['message'] ?? 'تم إرسال التقييم بنجاح';
        Get.snackbar(
          'نجاح',
          reviewMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 3),
        );
        await fetchMyBookings();
      } else {
        reviewMessage.value = response['message'] ?? 'فشل إرسال التقييم';
        Get.snackbar(
          ' خطأ',
          reviewMessage.value,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
        );
      }
    } catch (e) {
      reviewMessage.value = 'حدث خطأ: $e';
      Get.snackbar(
        ' خطأ',
        reviewMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      print(' Error in submitBookingReview: $e');
    } finally {
      isSubmittingReview.value = false;
    }
  }

  void showReviewDialog(Map<String, dynamic> booking) {
    final reviewController = TextEditingController();
    showDialog(
      context: Get.context!,
      builder: (context) {
        int selectedRating = 5;
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('تقييم الحجز'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('اختر تقييمك من 1 إلى 5 نجوم:'),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      icon: Icon(
                        Icons.star,
                        color: starIndex <= selectedRating
                            ? Colors.orange
                            : Colors.grey[300],
                      ),
                      onPressed: () => setState(() => selectedRating = starIndex),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reviewController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'مراجعة (اختياري)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  submitBookingReview(
                    bookingId: booking['id'],
                    rating: selectedRating,
                    review: reviewController.text,
                  );
                },
                child: Obx(() => isSubmittingReview.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('إرسال التقييم')),
              ),
            ],
          ),
        );
      },
    );
  }

  String getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'معلق';
      case 'approved':
        return 'مقبول';
      case 'rejected':
        return 'مرفوض';
      case 'cancelled':
        return 'ملغى';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.info;
    }
  }
}
