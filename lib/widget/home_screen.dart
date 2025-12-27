import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:livora/controller/home_controller.dart';
import 'package:livora/widget/apartment_details_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home".tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshApartments(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text('حدث خطأ في التحميل'.tr),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.loadApartments,
                  child: Text('إعادة المحاولة'.tr),
                ),
              ],
            ),
          );
        }

        if (controller.apartments.isEmpty) {
          return Center(
            child: Text('لا توجد شقق متاحة'.tr),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshApartments,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.apartments.length,
            itemBuilder: (context, index) {
              final apartment = controller.apartments[index];

              /// 🔹 الكارد الأساسي
              final apartmentCard = Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Get.to(
                      () => ApartmentDetailsScreen(apartment: apartment),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// ✅ الصورة (مضبوطة)
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: apartment.mainImage != null &&
                                  apartment.mainImage!.isNotEmpty
                              ? Image.network(
                                  apartment.mainImage!,
                                  fit: BoxFit.cover,
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
                            Text(
                              apartment.price,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );

              /// 🔹 إذا كان مالك ➜ Slidable
              if (controller.isowner.value) {
                return Slidable(
                  key: ValueKey(apartment.id),
                  endActionPane: ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.2,
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          Get.dialog(
                            AlertDialog(
                              title: Text('تأكيد الحذف'.tr),
                              content:
                                  Text('هل تريد حذف هذه الشقة؟'.tr),
                              actions: [
                                TextButton(
                                  onPressed: Get.back,
                                  child: Text('إلغاء'.tr),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Get.back();
                                    controller.deleteApartment(
                                      apartment.id ?? 0,
                                      index,
                                    );
                                  },
                                  child: Text(
                                    'حذف'.tr,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
                  ),
                  child: apartmentCard,
                );
              }

              /// 🔹 غير المالك
              return apartmentCard;
            },
          ),
        );
      }),
    );
  }
}
