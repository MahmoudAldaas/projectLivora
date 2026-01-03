import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/controller/owner_booking_controller.dart';

class OwnerBookingScreen extends StatelessWidget {
  OwnerBookingScreen({super.key});

  final OwnerBookingController controller = Get.put(OwnerBookingController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('طلبات الحجز'.tr),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refresh,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: colors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: controller.refresh,
                    icon: const Icon(Icons.refresh),
                    label: Text('إعادة المحاولة'.tr),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا يوجد طلبات حجز حالياً',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'سيظهر هنا الطلبات الجديدة',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.bookings.length,
            itemBuilder: (context, index) {
              final booking = controller.bookings[index];
              return _buildBookingCard(booking, theme, colors);
            },
          ),
        );
      }),
    );
  }

  Widget _buildBookingCard(
    dynamic booking,
    ThemeData theme,
    ColorScheme colors,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.withOpacity(0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'طلب قيد الانتظار',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '#${booking.id}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            _buildInfoRow(
              Icons.apartment,
              'الشقة',
              booking.apartmentTitle,
              theme,
            ),

            const SizedBox(height: 12),

            _buildInfoRow(
              Icons.person,
              'المستأجر',
              booking.userName,
              theme,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildInfoRow(
                    Icons.calendar_today,
                    'من',
                    booking.startDate,
                    theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoRow(
                    Icons.event,
                    'إلى',
                    booking.endDate,
                    theme,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showApproveDialog(booking.id),
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('قبول'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(booking.id),
                    icon: const Icon(Icons.close, size: 20),
                    label: const Text('رفض'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void _showApproveDialog(int bookingId) {
    Get.dialog(
      AlertDialog(
        title: const Text('قبول الحجز'),
        content: const Text('هل أنت متأكد من قبول هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.approve(bookingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('قبول'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(int bookingId) {
    Get.dialog(
      AlertDialog(
        title: const Text('رفض الحجز'),
        content: const Text('هل أنت متأكد من رفض هذا الطلب؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.reject(bookingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('رفض'),
          ),
        ],
      ),
    );
  }
}