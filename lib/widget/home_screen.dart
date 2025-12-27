import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; 
import 'package:livora/controller/home_controller.dart';
import 'package:livora/widget/apartment_details_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home ".tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.refreshApartments(),
          ),
        ],
      ),
      floatingActionButton: Obx(() => controller.isOwner.value
          ? FloatingActionButton(
              onPressed: () {
                // add apartment
              },
              child: const Icon(Icons.add),
            )
          : const SizedBox()),
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
                Text('حدث خطأ في التحميل'.tr, style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => controller.loadApartments(),
                  icon: const Icon(Icons.refresh),
                  label: Text('إعادة المحاولة'.tr),
                ),
              ],
            ),
          );
        }

        if (controller.apartments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.apartment, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'لا توجد شقق متاحة'.tr,
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // ✨ Display Apartment with Slidable
        return RefreshIndicator(
          onRefresh: controller.refreshApartments,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.apartments.length,
            itemBuilder: (context, index) {
              final apartment = controller.apartments[index];
              
              // ✨ لف الـ Card بـ Slidable
              return Slidable(
                key: ValueKey(apartment.id), // مهم للـ key
                
                // ✨ إظهار زر الحذف عند السحب من اليسار
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  extentRatio: 0.2,
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        // ✨ حوار تأكيد الحذف
                        Get.dialog(
                          AlertDialog(
                            title: Text('تأكيد الحذف'.tr),
                            content: Text('هل تريد حذف هذه الشقة؟'.tr),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: Text('إلغاء'.tr),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.back(); // إغلاق الحوار
                                  controller.deleteApartment(
                                    apartment.id ?? 0,
                                    index,
                                  );
                                },
                                child: Text(
                                  'حذف'.tr,
                                  style: TextStyle(color: Colors.red),
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
                      flex: 1,
                    ),
                  ],
                ),
                
                // ✨ الـ Card الأصلي
                child: Card(
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
                        // ... باقي الكود كما هو (الصورة والمعلومات)
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                          child: apartment.mainImage != null &&
                                  apartment.mainImage!.isNotEmpty
                              ? Image.network(
                                  apartment.mainImage!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: double.infinity,
                                    height: 200,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.apartment,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  loadingBuilder: (_, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      width: double.infinity,
                                      height: 200,
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                  ),
                                  child: const Icon(
                                    Icons.apartment,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                        
                        // باقي معلومات الشقة (نفس الكود السابق)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                apartment.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              if (apartment.description != null &&
                                  apartment.description!.isNotEmpty)
                                Text(
                                  apartment.description!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              const SizedBox(height: 12),
                              if (apartment.city != null ||
                                  apartment.governorate != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 18,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${apartment.city ?? ''} ${apartment.governorate != null ? '- ${apartment.governorate}' : ''}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 8),
                              if (apartment.numberRooms != null)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.bed,
                                      size: 18,
                                      color: Colors.grey[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${apartment.numberRooms} غرفة',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.attach_money,
                                        size: 20,
                                        color: Colors.green,
                                      ),
                                      Text(
                                        apartment.price,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (apartment.ownerName != null &&
                                      apartment.ownerName!.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.person,
                                          size: 16,
                                          color: Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          apartment.ownerName!,
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}