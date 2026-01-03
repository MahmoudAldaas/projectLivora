import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/controller/home_controller.dart';
import 'package:livora/controller/favorites_controller.dart';
import 'package:livora/controller/filter_controller.dart';
import 'package:livora/widget/apartment_details_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController controller = Get.find<HomeController>();
  final FavoritesController favoritesController = Get.put(FavoritesController());
  final FilterController filterController = Get.put(FilterController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final apartments = filterController.filteredApartments.isNotEmpty
            ? filterController.filteredApartments
            : controller.apartments;

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

        if (apartments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  filterController.hasActiveFilters
                      ? 'لا توجد شقق تطابق البحث'.tr
                      : 'لا توجد شقق متاحة'.tr,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (filterController.hasActiveFilters) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      filterController.resetFilter();
                      controller.loadApartments();
                    },
                    icon: const Icon(Icons.refresh),
                    label: Text('إعادة تعيين الفلتر'.tr),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            filterController.resetFilter();
            await controller.refreshApartments();
          },
          child: Column(
            children: [
              if (filterController.hasActiveFilters)
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_alt,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'الفلتر نشط - ${apartments.length} ${'شقة'.tr}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          filterController.resetFilter();
                          controller.loadApartments();
                        },
                        icon: Icon(
                          Icons.close,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: apartments.length,
                  itemBuilder: (context, index) {
                    final apartment = apartments[index];

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
                                    child: apartment.mainImage != null &&
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
                                
                                if (controller.isowner.value)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: PopupMenuButton<String>(
                                        icon: const Icon(
                                          Icons.more_vert,
                                          color: Colors.white,
                                        ),
                                        itemBuilder: (BuildContext context) => [
                                          PopupMenuItem<String>(
                                            value: 'edit',
                                            child: Row(
                                              children: [
                                                const Icon(Icons.edit, color: Colors.blue),
                                                const SizedBox(width: 8),
                                                Text('تعديل'.tr),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem<String>(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                const Icon(Icons.delete, color: Colors.red),
                                                const SizedBox(width: 8),
                                                Text('حذف'.tr),
                                              ],
                                            ),
                                          ),
                                        ],
                                        onSelected: (String value) {
                                          if (value == 'edit') {
                                            _showEditDialog(apartment);
                                          } else if (value == 'delete') {
                                            controller.deleteApartment(
                                              apartment.id ?? 0,
                                              index,
                                            );
                                          }
                                        },
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          apartment.title,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      
                                      if (!controller.isowner.value)
                                        Obx(() {
                                          final isFav = favoritesController.isFavorite(apartment.id ?? 0);
                                          return Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              onTap: () => favoritesController.toggleFavorite(apartment),
                                              borderRadius: BorderRadius.circular(20),
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                child: Icon(
                                                  isFav ? Icons.favorite : Icons.favorite_border,
                                                  color: isFav ? Colors.red : Colors.grey,
                                                  size: 28,
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                    ],
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
                                  Text(
                                    '${apartment.price} \$',
                                    style: const TextStyle(
                                      fontSize: 20,
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
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showEditDialog(apartment) {
    final titleController = TextEditingController(text: apartment.title);
    final descriptionController = TextEditingController(text: apartment.description ?? '');
    final priceController = TextEditingController(text: apartment.price);

    Get.dialog(
      AlertDialog(
        title: Text('تعديل الشقة'.tr),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'العنوان'.tr,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'الوصف'.tr,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'السعر'.tr,
                  border: const OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('إلغاء'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final description = descriptionController.text.trim();
              final priceText = priceController.text.trim();

              if (title.isEmpty || priceText.isEmpty) {
                Get.snackbar(
                  'خطأ'.tr,
                  'يرجى ملء العنوان والسعر'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              final price = double.tryParse(priceText);
              if (price == null) {
                Get.snackbar(
                  'خطأ'.tr,
                  'السعر غير صحيح'.tr,
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
                return;
              }

              Get.back();

              controller.updateApartment(
                apartmentId: apartment.id!,
                title: title,
                description: description.isEmpty ? null : description,
                price: price,
              );
            },
            child: Text('حفظ'.tr),
          ),
        ],
      ),
    );
  }
}