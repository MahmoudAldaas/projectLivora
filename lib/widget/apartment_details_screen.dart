import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/models/apartment.dart';
import 'package:livora/controller/apartment_details_controller.dart';
import '../controller/booking_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widget/edit_apartment_scren.dart';

class ApartmentDetailsScreen extends StatelessWidget {
  final Apartment apartment;

  const ApartmentDetailsScreen({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final controller = Get.put(
      ApartmentDetailsController(apartment.id ?? 0),
      tag: apartment.id.toString(),
    );

    final bookingController = Get.put(
      BookingController(apartment.id ?? 0),
      tag: 'booking_${apartment.id}',
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        iconTheme: theme.iconTheme,
        title: Text('Apartment Details'.tr, style: theme.textTheme.titleLarge),
        actions: [
          Obx(() {
            if (controller.canEditApartment) {
              return IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'تعديل الشقة'.tr,
                onPressed: () => _navigateToEditScreen(controller),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.apartment.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.apartment.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: controller.refreshApartmentDetails,
                  icon: const Icon(Icons.refresh),
                  label: Text('إعادة المحاولة'.tr),
                ),
              ],
            ),
          );
        }

        final apt = controller.apartment.value ?? apartment;

        return RefreshIndicator(
          onRefresh: controller.refreshApartmentDetails,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMainImage(apt),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apt.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Icon(
                            Icons.attach_money,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                          Text(
                            apt.price,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 32),

                      _buildInfoSection(apt, theme),

                      const Divider(height: 32),

                      if (apt.description != null &&
                          apt.description!.isNotEmpty) ...[
                        Text(
                          'الوصف'.tr,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          apt.description!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      if (apt.images != null && apt.images!.isNotEmpty) ...[
                        Text(
                          'صور اضافية'.tr,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildImageGallery(apt.images!),
                        const SizedBox(height: 24),
                      ],

                      _buildOwnerInfo(apt, theme),

                      const SizedBox(height: 24),

                      Obx(() {
                        if (controller.canEditApartment) {
                          return Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _navigateToEditScreen(controller),
                                  icon: const Icon(Icons.edit),
                                  label: Text(
                                    'تعديل معلومات الشقة'.tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    side: BorderSide(
                                      color: theme.colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      }),

                      FutureBuilder<String>(
                        future: _getUserRole(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data == 'owner') {
                            return const SizedBox.shrink();
                          }

                          return Obx(
                            () =>
                                _buildBookingSection(bookingController, theme),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<String> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role') ?? '';
  }

  Future<void> _navigateToEditScreen(
    ApartmentDetailsController controller,
  ) async {
    final result = await Get.to(
      () => EditApartmentScreen(
        apartment: controller.apartment.value ?? apartment,
      ),
    );

    if (result == true) {
      await controller.refreshApartmentDetails();
    }
  }


  Widget _buildBookingSection(BookingController controller, ThemeData theme) {
    if (controller.hasBooking.value &&
        controller.currentBooking.value != null) {
      final booking = controller.currentBooking.value!;
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'لديك حجز نشط'.tr,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'من: ${controller.formatApiDateToArabic(booking['start_date'])}',
                ),
                Text(
                  'إلى: ${controller.formatApiDateToArabic(booking['end_date'])}',
                ),
                if (booking['notes'] != null && booking['notes'].isNotEmpty)
                  Text('ملاحظات: ${booking['notes']}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: controller.showEditBookingDialog,
                  icon: const Icon(Icons.edit),
                  label: Text('تعديل الحجز'.tr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(
                  () => ElevatedButton.icon(
                    onPressed: controller.isCancelling.value
                        ? null
                        : () => controller.cancelBooking(booking['id']),
                    icon: controller.isCancelling.value
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.close),
                    label: Text('إلغاء الحجز'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: controller.showBookingDialog,
          icon: const Icon(Icons.calendar_today),
          label: Text(
            'احجز الآن'.tr,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }


  Widget _buildMainImage(Apartment apt) {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[300],
      child: apt.mainImage != null && apt.mainImage!.isNotEmpty
          ? Image.network(
              apt.mainImage!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.apartment, size: 80, color: Colors.grey),
            )
          : const Icon(Icons.apartment, size: 80, color: Colors.grey),
    );
  }

  Widget _buildInfoSection(Apartment apt, ThemeData theme) {
    return Column(
      children: [
        if (apt.city != null || apt.governorate != null)
          _buildInfoRow(
            Icons.location_on,
            'الموقع'.tr,
            '${apt.city ?? ''} ${apt.governorate ?? ''}',
            theme,
          ),
        if (apt.numberRooms != null)
          _buildInfoRow(
            Icons.bed,
            'عدد الغرف'.tr,
            '${apt.numberRooms} غرفة',
            theme,
          ),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              images[i],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOwnerInfo(Apartment apt, ThemeData theme) {
    if (apt.ownerName == null || apt.ownerName!.isEmpty) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.person, color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المالك'.tr, style: theme.textTheme.bodySmall),
                Text(
                  apt.ownerName!,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.phone, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
