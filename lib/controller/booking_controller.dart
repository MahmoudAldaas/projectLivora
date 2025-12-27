import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  final int apartmentId;

  BookingController(this.apartmentId);

  // Booking State
  final isBooking = false.obs;
  final isCancelling = false.obs;
  final isUpdating = false.obs;

  // Current Booking (mock)
  final Rx<Map<String, dynamic>?> currentBooking = Rx<Map<String, dynamic>?>(null);
  final hasBooking = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkExistingBooking();
  }

  // ================= Mock API =================
  Future<void> checkExistingBooking() async {
    await Future.delayed(const Duration(milliseconds: 500));
    bool exists = false; // يمكنك تغييره لتجربة وجود حجز
    if (exists) {
      currentBooking.value = {
        'id': 1,
        'start_date': DateTime.now().add(const Duration(days: 1)).toString().split(' ')[0],
        'end_date': DateTime.now().add(const Duration(days: 3)).toString().split(' ')[0],
        'notes': 'ملاحظات تجريبية',
      };
      hasBooking.value = true;
    } else {
      hasBooking.value = false;
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
    if (startDate.isBefore(DateTime.now())) {
      _showError('لا يمكن الحجز في تاريخ سابق'.tr);
      return;
    }

    isBooking.value = true;
    await Future.delayed(const Duration(seconds: 1));

    currentBooking.value = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'start_date': startDate.toString().split(' ')[0],
      'end_date': endDate.toString().split(' ')[0],
      'notes': notes,
    };
    hasBooking.value = true;
    _showSuccess('تم الحجز بنجاح'.tr);
    Get.back();
    isBooking.value = false;
  }

  Future<void> updateBooking({
    required int bookingId,
    DateTime? startDate,
    DateTime? endDate,
    String? notes,
  }) async {
    if (isUpdating.value) return;

    isUpdating.value = true;
    await Future.delayed(const Duration(seconds: 1));

    currentBooking.value = {
      'id': bookingId,
      'start_date': startDate!.toString().split(' ')[0],
      'end_date': endDate!.toString().split(' ')[0],
      'notes': notes,
    };
    _showSuccess('تم تحديث الحجز بنجاح'.tr);
    Get.back();
    isUpdating.value = false;
  }

  Future<void> cancelBooking(int bookingId) async {
    if (isCancelling.value) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('تأكيد الإلغاء'.tr),
        content: Text('هل أنت متأكد من إلغاء الحجز؟'.tr),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('لا'.tr)),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('نعم، إلغاء'.tr),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    isCancelling.value = true;
    await Future.delayed(const Duration(seconds: 1));

    currentBooking.value = null;
    hasBooking.value = false;
    _showSuccess('تم إلغاء الحجز'.tr);
    isCancelling.value = false;
  }

  // ================= Public Dialog Methods =================
  void showBookingDialog() {
    Get.dialog(BookingDialog(controller: this));
  }

  void showEditBookingDialog() {
    if (currentBooking.value == null) return;
    Get.dialog(EditBookingDialog(controller: this, booking: currentBooking.value!));
  }

  // ================= Helpers =================
  void _showSuccess(String message) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar('نجح'.tr, message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white));
  }

  void _showError(String message) {
    if (Get.isSnackbarOpen) return;
    Get.snackbar('خطأ'.tr, message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white));
  }
}

// ================= Public Booking Dialogs =================

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
                  initialDate: startDate ?? DateTime.now(),
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
                labelText: 'ملاحظات (اختياري)'.tr,
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
