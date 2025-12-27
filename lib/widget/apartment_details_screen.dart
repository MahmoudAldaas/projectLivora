import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/models/apartment.dart';
import 'package:livora/controller/apartment_details_controller.dart';

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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        iconTheme: theme.iconTheme,
        title: Text(
          'Apartment Details'.tr,
          style: theme.textTheme.titleLarge,
        ),
      ),
      body: Obx(() {
        /// تحميل
        if (controller.isLoading.value &&
            controller.apartment.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        /// خطأ
        if (controller.errorMessage.value.isNotEmpty &&
            controller.apartment.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 60, color: theme.colorScheme.error),
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
                      /// العنوان
                      Text(
                        apt.title,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 12),

                      /// السعر
                      Row(
                        children: [
                          Icon(Icons.attach_money,
                              color: theme.colorScheme.primary, size: 28),
                          Text(
                            apt.price,
                            style:
                                theme.textTheme.headlineMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const Divider(height: 32),

                      /// معلومات
                      _buildInfoSection(apt, theme),

                      const Divider(height: 32),

                      /// الوصف
                      if (apt.description != null &&
                          apt.description!.isNotEmpty) ...[
                        Text(
                          'الوصف'.tr,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          apt.description!,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(height: 1.5),
                        ),
                        const SizedBox(height: 24),
                      ],

                      /// صور إضافية
                      if (apt.images != null && apt.images!.isNotEmpty) ...[
                        Text(
                          'صور اضافية'.tr,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildImageGallery(apt.images!),
                        const SizedBox(height: 24),
                      ],

                      /// معلومات المالك
                      _buildOwnerInfo(apt, theme),

                      const SizedBox(height: 24),

                      /// زر الحجز
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            'احجز الان'.tr,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
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

  // ===================== Widgets =====================

  Widget _buildMainImage(Apartment apt) {
    return Container(
      height: 300,
      width: double.infinity,
      color: Colors.grey[300],
      child: apt.mainImage != null && apt.mainImage!.isNotEmpty
          ? Image.network(
              apt.mainImage!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.apartment,
                size: 80,
                color: Colors.grey,
              ),
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
      IconData icon, String label, String value, ThemeData theme) {
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
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
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
            backgroundColor:
                theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(Icons.person,
                color: theme.colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('المالك'.tr, style: theme.textTheme.bodySmall),
                Text(
                  apt.ownerName!,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.phone,
                color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }
}
