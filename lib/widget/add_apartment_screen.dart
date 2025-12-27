import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/controller/add_apartment_controller.dart';

class AddApartmentScreen extends StatelessWidget {
  const AddApartmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddApartmentController());

    return Scaffold(
      appBar: AppBar(
        title: Text('إضافة شقة جديدة'.tr),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              _buildTextField(
                controller: controller.titleController,
                label: 'عنوان الشقة'.tr,
                icon: Icons.title,
                validator: (v) => v == null || v.isEmpty ? 'مطلوب'.tr : null,
              ),
              const SizedBox(height: 16),

              // Governorate Field
              _buildTextField(
                controller: controller.governorateController,
                label: 'المحافظة'.tr,
                icon: Icons.location_city,
                validator: (v) => v == null || v.isEmpty ? 'مطلوب'.tr : null,
              ),
              const SizedBox(height: 16),

              // City Field
              _buildTextField(
                controller: controller.cityController,
                label: 'المدينة'.tr,
                icon: Icons.location_on,
                validator: (v) => v == null || v.isEmpty ? 'مطلوب'.tr : null,
              ),
              const SizedBox(height: 16),

              // Number of Rooms
              _buildTextField(
                controller: controller.numberRoomsController,
                label: 'عدد الغرف'.tr,
                icon: Icons.bed,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'مطلوب'.tr : null,
              ),
              const SizedBox(height: 16),

              // Price Field
              _buildTextField(
                controller: controller.priceController,
                label: 'السعر'.tr,
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'مطلوب'.tr : null,
              ),
              const SizedBox(height: 16),

              // Description Field
              _buildTextField(
                controller: controller.descriptionController,
                label: 'الوصف (اختياري)'.tr,
                icon: Icons.description,
                maxLines: 4,
                validator: null,
              ),
              const SizedBox(height: 24),

              // Main Image Section
              Text(
                'الصورة الرئيسية'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Obx(() => _buildMainImagePicker(controller)),
              const SizedBox(height: 24),

              // Additional Images Section
              Text(
                'صور إضافية (اختياري - حتى 5 صور)'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              Obx(() => _buildAdditionalImagesPicker(controller)),
              const SizedBox(height: 32),

              // Submit Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.submitApartment,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'إضافة الشقة'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  // Build Text Field Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      validator: validator,
    );
  }

  // Main Image Picker Widget
  Widget _buildMainImagePicker(AddApartmentController controller) {
    if (controller.mainImage.value != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              controller.mainImage.value!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              onPressed: controller.removeMainImage,
              icon: const Icon(Icons.close),
              style: IconButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: controller.pickMainImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              'اضغط لاختيار صورة رئيسية'.tr,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // Additional Images Picker Widget
  Widget _buildAdditionalImagesPicker(AddApartmentController controller) {
    return Column(
      children: [
        // Display selected images
        if (controller.additionalImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.additionalImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          controller.additionalImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => controller.removeAdditionalImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        
        const SizedBox(height: 12),
        
        // Add button
        if (controller.additionalImages.length < 5)
          OutlinedButton.icon(
            onPressed: controller.pickAdditionalImages,
            icon: const Icon(Icons.add_photo_alternate),
            label: Text(
              controller.additionalImages.isEmpty
                  ? 'إضافة صور'.tr
                  : 'إضافة المزيد (${controller.additionalImages.length}/5)'.tr,
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
      ],
    );
  }
}