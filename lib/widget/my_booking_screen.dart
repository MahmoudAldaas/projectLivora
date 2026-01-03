import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/controller/my_booking_controller.dart';

class MyBookingsScreen extends StatelessWidget {
  MyBookingsScreen({super.key});
  final MyBookingsController controller = Get.put(MyBookingsController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حجوزاتي'),
          centerTitle: true,
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'الكل'),
              Tab(text: 'قيد الانتظار'),
              Tab(text: 'موافق عليها'),
              Tab(text: 'مرفوضة'),
              Tab(text: 'ملغية'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.errorMessage.isNotEmpty) {
            return Center(child: Text(controller.errorMessage.value));
          }

          return TabBarView(
            children: [
              _buildList(controller.bookings),
              _buildList(controller.pendingBookings),
              _buildList(controller.activeBookings),
              _buildList(controller.rejectedBookings),
              _buildList(controller.cancelledBookings),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildList(List<Map<String, dynamic>> list) {
    if (list.isEmpty) return const Center(child: Text('لا توجد حجوزات'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return _BookingCard(booking: list[index]);
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MyBookingsController>();
    final status = booking['status'];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking['apartment_title'],
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: controller.getStatusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: controller.getStatusColor(status),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(controller.getStatusIcon(status),
                          size: 14, color: controller.getStatusColor(status)),
                      const SizedBox(width: 4),
                      Text(
                        controller.getStatusText(status),
                        style: TextStyle(
                          color: controller.getStatusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                const Icon(Icons.date_range, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${booking['start_date']}  →  ${booking['end_date']}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                if (status == 'pending')
                  OutlinedButton.icon(
                    onPressed: () => controller.showEditDialog(booking),
                    icon: const Icon(Icons.edit),
                    label: const Text('تعديل'),
                  ),
                if (status == 'pending') const SizedBox(width: 8),
                if (status == 'pending' || status == 'approved')
                  OutlinedButton.icon(
                    onPressed: () => controller.confirmCancelBooking(booking),
                    icon: const Icon(Icons.close),
                    label: const Text('إلغاء'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  ),
                if (controller.canReviewBooking(booking))
                  OutlinedButton.icon(
                    onPressed: () => controller.showReviewDialog(booking),
                    icon: const Icon(Icons.star),
                    label: const Text('تقييم'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.orange),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
