import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/core/api/api_service.dart';
import 'package:intl/intl.dart'; 

class BookingController extends GetxController {
  final int apartmentId;

  BookingController(this.apartmentId);

  final isBooking = false.obs;
  final isCancelling = false.obs;
  final isUpdating = false.obs;
  final isLoading = false.obs;

  final Rx<Map<String, dynamic>?> currentBooking = Rx<Map<String, dynamic>?>(null);
  final hasBooking = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCurrentBooking();
  }

  
  Future<void> fetchCurrentBooking() async {
    try {
      isLoading.value = true;

      final response = await ApiService.getBookingForApartment(
        apartmentId: apartmentId,
      );

      print('Response: $response');

      if (response['error'] == false) {
        if (response['data'] != null) {
          currentBooking.value = response['data'];
          hasBooking.value = true;
          print(' يوجد حجز نشط: ${currentBooking.value}');
        } else {
          currentBooking.value = null;
          hasBooking.value = false;
          print('ℹ لا يوجد حجز نشط');
        }
      } else {
        currentBooking.value = null;
        hasBooking.value = false;
      }
    } catch (e) {
      print(' خطأ في جلب الحجز: $e');
      hasBooking.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createBooking({
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    if (isBooking.value) return;

    if (startDate.isAfter(endDate)) {
      _showError('تاريخ البداية يجب أن يكون قبل تاريخ النهاية'.tr);
      return;
    }
    if (startDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      _showError('لا يمكن الحجز في تاريخ سابق'.tr);
      return;
    }

    try {
      isBooking.value = true;

      final response = await ApiService.createBooking(
        apartmentId: apartmentId,
        startDate: _formatDate(startDate),
        endDate: _formatDate(endDate),
      );

      print('Create Booking Response: $response');

      if (response['error'] == false) {
        currentBooking.value = response['data'];
        hasBooking.value = true;
        _showSuccess('تم الحجز بنجاح! في انتظار موافقة المالك'.tr);
        Get.back();
      } else {
        _showError(response['message'] ?? 'فشل إنشاء الحجز'.tr);
      }
    } catch (e) {
      print('خطأ في إنشاء الحجز: $e');
      _showError('حدث خطأ أثناء الحجز'.tr);
    } finally {
      isBooking.value = false;
    }
  }

  Future<void> updateBooking({
    required int bookingId,
    required DateTime startDate,
    required DateTime endDate,
    String? notes,
  }) async {
    if (isUpdating.value) return;

    if (startDate.isAfter(endDate)) {
      _showError('تاريخ البداية يجب أن يكون قبل تاريخ النهاية'.tr);
      return;
    }

    try {
      isUpdating.value = true;

      final response = await ApiService.updateBooking(
        bookingId: bookingId,
        startDate: _formatDate(startDate),
        endDate: _formatDate(endDate),
      );

      print('📥 Update Booking Response: $response');

      if (response['error'] == false) {
        currentBooking.value = response['data'];
        _showSuccess('تم تحديث الحجز بنجاح'.tr);
        Get.back();
      } else {
        _showError(response['message'] ?? 'فشل تحديث الحجز'.tr);
      }
    } catch (e) {
      print(' خطأ في تحديث الحجز: $e');
      _showError('حدث خطأ أثناء التحديث'.tr);
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    if (isCancelling.value) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تأكيد الإلغاء'.tr),
        content: Text('هل أنت متأكد من إلغاء الحجز؟'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('لا'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('نعم، إلغاء'.tr),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      isCancelling.value = true;

      final response = await ApiService.cancelBooking(bookingId: bookingId);

      print(' Cancel Booking Response: $response');

      if (response['error'] == false) {
        currentBooking.value = null;
        hasBooking.value = false;
        _showSuccess('تم إلغاء الحجز بنجاح'.tr);
      } else {
        _showError(response['message'] ?? 'فشل إلغاء الحجز'.tr);
      }
    } catch (e) {
      print(' خطأ في إلغاء الحجز: $e');
      _showError('حدث خطأ أثناء الإلغاء'.tr);
    } finally {
      isCancelling.value = false;
    }
  }

  void showBookingDialog() {
    Get.dialog(BookingDialog(controller: this));
  }

  void showEditBookingDialog() {
    if (currentBooking.value == null) return;
    Get.dialog(EditBookingDialog(controller: this, booking: currentBooking.value!));
  }


  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String formatApiDateToArabic(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'غير محدد';

    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('yyyy/MM/dd', 'ar');
      return formatter.format(date);
    } catch (e) {
      return dateString;
    }
  }

  String getBookingStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'approved':
        return 'مؤكد';
      case 'rejected':
        return 'مرفوض';
      case 'cancelled':
        return 'ملغي';
      default:
        return status ?? 'غير معروف';
    }
  }

  Color getBookingStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  void _showSuccess(String message) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      'نجح'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  void _showError(String message) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      'خطأ'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }
}


class BookingDialog extends StatefulWidget {
  final BookingController controller;
  const BookingDialog({required this.controller, super.key});

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  DateTime? startDate;
  DateTime? endDate;
  final notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('حجز الشقة'.tr),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(startDate == null
                  ? 'اختر تاريخ البداية'.tr
                  : 'من: ${startDate!.toString().split(' ')[0]}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => startDate = date);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: Text(endDate == null
                  ? 'اختر تاريخ النهاية'.tr
                  : 'إلى: ${endDate!.toString().split(' ')[0]}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: startDate ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: startDate ?? DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => endDate = date);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'ملاحظات'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('إلغاء'.tr)),
        Obx(() => ElevatedButton(
              onPressed: widget.controller.isBooking.value || startDate == null || endDate == null
                  ? null
                  : () {
                      widget.controller.createBooking(
                        startDate: startDate!,
                        endDate: endDate!,
                        notes: notesController.text,
                      );
                    },
              child: widget.controller.isBooking.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('تأكيد الحجز'.tr),
            )),
      ],
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}


class EditBookingDialog extends StatefulWidget {
  final BookingController controller;
  final Map<String, dynamic> booking;

  const EditBookingDialog({required this.controller, required this.booking, super.key});

  @override
  State<EditBookingDialog> createState() => _EditBookingDialogState();
}

class _EditBookingDialogState extends State<EditBookingDialog> {
  late DateTime startDate;
  late DateTime endDate;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    startDate = DateTime.parse(widget.booking['start_date']);
    endDate = DateTime.parse(widget.booking['end_date']);
    notesController = TextEditingController(text: widget.booking['notes'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تعديل الحجز'.tr),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text('من: ${startDate.toString().split(' ')[0]}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: startDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => startDate = date);
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: Text('إلى: ${endDate.toString().split(' ')[0]}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: endDate,
                  firstDate: startDate,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) setState(() => endDate = date);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: 'ملاحظات'.tr,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('إلغاء'.tr)),
        Obx(() => ElevatedButton(
              onPressed: widget.controller.isUpdating.value
                  ? null
                  : () {
                      widget.controller.updateBooking(
                        bookingId: widget.booking['id'],
                        startDate: startDate,
                        endDate: endDate,
                        notes: notesController.text,
                      );
                    },
              child: widget.controller.isUpdating.value
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('حفظ التعديلات'.tr),
            )),
      ],
    );
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }
}