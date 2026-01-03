import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/controller/favorites_controller.dart';
import 'package:livora/controller/booking_controller.dart';
import 'package:livora/widget/apartment_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavoritesController());

    return Scaffold(
      appBar: AppBar(
        title: Text('المفضلة'.tr),
        actions: [
          Obx(() {
            if (controller.favorites.isNotEmpty) {
              return IconButton(
                icon: const Icon(Icons.delete_sweep),
                tooltip: 'مسح الكل'.tr,
                onPressed: controller.clearAllFavorites,
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        if (controller.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 100, color: Colors.grey[300]),
                const SizedBox(height: 24),
                Text(
                  'لا توجد شقق مفضلة',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ابدأ بإضافة شقق إلى المفضلة',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.favorites.length,
          itemBuilder: (context, index) {
            final apartment = controller.favorites[index];

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Get.to(() => ApartmentDetailsScreen(apartment: apartment));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 200,
                            child:
                                apartment.mainImage != null &&
                                    apartment.mainImage!.isNotEmpty
                                ? Image.network(
                                    apartment.mainImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.apartment,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.apartment,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                          ),
                        ),

                        Positioned(
                          top: 8,
                          right: 8,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  controller.removeFromFavorites(apartment.id!),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            apartment.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${apartment.city ?? ''}, ${apartment.governorate ?? ''}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${apartment.price} \$',
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showBookingDialog(apartment);
                                },
                                icon: const Icon(
                                  Icons.calendar_today,
                                  size: 18,
                                ),
                                label: const Text('احجز الآن'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  void _showBookingDialog(apartment) {
    final bookingController = Get.put(
      BookingController(apartment.id ?? 0),
      tag: 'booking_fav_${apartment.id}',
    );

    bookingController.fetchCurrentBooking();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (bookingController.hasBooking.value) {
        Get.snackbar(
          'تنبيه',
          'لديك حجز نشط بالفعل على هذه الشقة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        bookingController.showBookingDialog();
      }
    });
  }
}
