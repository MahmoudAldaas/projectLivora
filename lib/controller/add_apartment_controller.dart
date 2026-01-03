import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livora/core/api/api_service.dart';
import 'package:livora/controller/home_controller.dart';

class AddApartmentController extends GetxController {

  final titleController = TextEditingController();
  final governorateController = TextEditingController();
  final cityController = TextEditingController();
  final numberRoomsController = TextEditingController();
  final priceController = TextEditingController();
  final descriptionController = TextEditingController();

 
  final formKey = GlobalKey<FormState>();

  
  final Rx<File?> mainImage = Rx<File?>(null);
  final RxList<File> additionalImages = <File>[].obs;

  final isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();

 
  final HomeController homeController = Get.find<HomeController>();

  // Pick main image 
  Future<void> pickMainImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        mainImage.value = File(pickedFile.path);
      }
    } catch (e) {
      _showErrorSnackbar('فشل في اختيار الصورة'.tr);
    }
  }

  // Pick additional images 
  Future<void> pickAdditionalImages() async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage(
        imageQuality: 85,
      );
      
      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        final remainingSlots = 5 - additionalImages.length;
        final filesToAdd = pickedFiles.take(remainingSlots);
        
        additionalImages.addAll(filesToAdd.map((e) => File(e.path)));
        
        if (pickedFiles.length > remainingSlots) {
          Get.snackbar(
            'تنبيه'.tr,
            'يمكنك إضافة 5 صور إضافية كحد أقصى'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      _showErrorSnackbar('فشل في اختيار الصور'.tr);
    }
  }

  // Remove additional image
  void removeAdditionalImage(int index) {
    if (index >= 0 && index < additionalImages.length) {
      additionalImages.removeAt(index);
    }
  }

  // Remove main image
  void removeMainImage() {
    mainImage.value = null;
  }

  // Validate and submit apartment 
  Future<void> submitApartment() async {
   
    if (!formKey.currentState!.validate()) {
      return;
    }
    final numberRooms = int.tryParse(numberRoomsController.text);
    final price = double.tryParse(priceController.text);

    if (numberRooms == null || numberRooms <= 0) {
      _showErrorSnackbar('عدد الغرف غير صالح'.tr);
      return;
    }

    if (price == null || price <= 0) {
      _showErrorSnackbar('السعر غير صالح'.tr);
      return;
    }

    isLoading.value = true;

    try {
      final result = await ApiService.addApartment(
        title: titleController.text.trim(),
        governorate: governorateController.text.trim(),
        city: cityController.text.trim(),
        numberRooms: numberRooms,
        price: price,
        description: descriptionController.text.trim(),
        mainImagePath: mainImage.value?.path ?? '', 
        imagesPath: additionalImages.isNotEmpty 
            ? additionalImages.map((e) => e.path).toList() 
            : null, 
      );

      if (!result['error']) {
        _showSuccessSnackbar('تمت إضافة الشقة بنجاح'.tr);
        
        // Refresh home apartments list
        await homeController.loadApartments();
        
        
        Get.back();
      } else {
        _showErrorSnackbar(result['message'] ?? 'فشل في إضافة الشقة'.tr);
      }
    } catch (e) {
      _showErrorSnackbar('حدث خطأ أثناء إضافة الشقة'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  
  void _showSuccessSnackbar(String message) {
    if (Get.isSnackbarOpen) return;
    
    Get.snackbar(
      'نجح'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );
  }

  void _showErrorSnackbar(String message) {
    if (Get.isSnackbarOpen) return;
    
    Get.snackbar(
      'خطأ'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error, color: Colors.white),
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    governorateController.dispose();
    cityController.dispose();
    numberRoomsController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
}