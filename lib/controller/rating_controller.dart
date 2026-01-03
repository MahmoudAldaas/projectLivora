import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class RatingController extends GetxController {
  final storage = GetStorage();

  var isSubmitting = false.obs;

  void showRatingDialog(Map<String, dynamic> booking) {

    final existingRating = _getExistingRating(booking['apartment_id']);
    
    double rating = existingRating?['rating']?.toDouble() ?? 0.0;
    final commentController = TextEditingController(
      text: existingRating?['comment'] ?? ''
    );

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                existingRating != null ? 'تعديل التقييم' : 'قيّم الشقة',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.apartment, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking['apartment_title'] ?? 'شقة',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'التقييم',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              StatefulBuilder(
                builder: (context, setState) => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      iconSize: 40,
                      onPressed: () {
                        setState(() {
                          rating = (index + 1).toDouble();
                        });
                      },
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),

              const Text(
                'تعليقك (اختياري)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  hintText: 'شاركنا رأيك عن الشقة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.comment),
                ),
                maxLines: 4,
                maxLength: 500,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child:  Text('إلغاء'.tr),
          ),
          Obx(() => ElevatedButton.icon(
            onPressed: isSubmitting.value
                ? null
                : () => _submitRating(
                    booking,
                    rating,
                    commentController.text,
                    existingRating != null,
                  ),
            icon: isSubmitting.value
                ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(existingRating != null ? 'تحديث' : 'إرسال'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
          )),
        ],
      ),
    );
  }

  Future<void> _submitRating(
    Map<String, dynamic> booking,
    double rating,
    String comment,
    bool isUpdate,
  ) async {
    if (rating == 0) {
      Get.snackbar(
        'تنبيه',
        'يرجى اختيار تقييم من النجوم',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      await Future.delayed(const Duration(milliseconds: 800));

      final ratingData = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'apartment_id': booking['apartment_id'],
        'booking_id': booking['id'],
        'rating': rating,
        'comment': comment.trim(),
        'created_at': DateTime.now().toIso8601String(),
      };

      final savedRatings = storage.read<List>('apartment_ratings') ?? [];
      
      if (isUpdate) {
        final index = savedRatings.indexWhere(
          (r) => r['apartment_id'] == booking['apartment_id']
        );
        if (index != -1) {
          savedRatings[index] = ratingData;
        }
      } else {
        savedRatings.add(ratingData);
      }

      await storage.write('apartment_ratings', savedRatings);

      Get.back();

      Get.snackbar(
        'نجاح',
        isUpdate ? 'تم تحديث التقييم بنجاح' : 'شكراً لتقييمك!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      _markBookingAsRated(booking['id']);

    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل إرسال التقييم',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void _markBookingAsRated(int bookingId) {
    final savedBookings = storage.read<List>('my_bookings') ?? [];
    final index = savedBookings.indexWhere((b) => b['id'] == bookingId);
    
    if (index != -1) {
      savedBookings[index]['is_rated'] = true;
      storage.write('my_bookings', savedBookings);
    }
  }

  Map<String, dynamic>? _getExistingRating(int apartmentId) {
    final savedRatings = storage.read<List>('apartment_ratings') ?? [];
    
    try {
      return Map<String, dynamic>.from(
        savedRatings.firstWhere(
          (r) => r['apartment_id'] == apartmentId,
        )
      );
    } catch (e) {
      return null;
    }
  }

  List<Map<String, dynamic>> getApartmentRatings(int apartmentId) {
    final savedRatings = storage.read<List>('apartment_ratings') ?? [];
    
    return savedRatings
        .where((r) => r['apartment_id'] == apartmentId)
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
  }

  double getAverageRating(int apartmentId) {
    final ratings = getApartmentRatings(apartmentId);
    if (ratings.isEmpty) return 0.0;

    final sum = ratings.fold<double>(
      0.0,
      (sum, r) => sum + (r['rating'] ?? 0.0),
    );

    return sum / ratings.length;
  }

  Future<void> deleteRating(int apartmentId) async {
    try {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('حذف التقييم'),
          content: const Text('هل تريد حذف تقييمك لهذه الشقة؟'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final savedRatings = storage.read<List>('apartment_ratings') ?? [];
      savedRatings.removeWhere((r) => r['apartment_id'] == apartmentId);
      await storage.write('apartment_ratings', savedRatings);

      Get.snackbar(
        'نجاح',
        'تم حذف التقييم',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حذف التقييم',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}