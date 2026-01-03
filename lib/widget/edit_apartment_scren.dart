import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/models/apartment.dart';
import 'package:livora/core/api/api_service.dart';

class EditApartmentScreen extends StatefulWidget {
  final Apartment apartment;

  const EditApartmentScreen({super.key, required this.apartment});

  @override
  State<EditApartmentScreen> createState() => _EditApartmentScreenState();
}

class _EditApartmentScreenState extends State<EditApartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.apartment.title);
    _descriptionController = TextEditingController(text: widget.apartment.description ?? '');
    _priceController = TextEditingController(text: widget.apartment.price);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _updateApartment() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      final result = await ApiService.updateApartment(
        id: widget.apartment.id!,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()),
      );

      if (result['error'] == false) {
        Get.back(result: true); 
        
        Get.snackbar(
          'نجح'.tr,
          'تم تحديث الشقة بنجاح'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
      } else {
        Get.snackbar(
          'خطأ'.tr,
          result['message'] ?? 'فشل في تحديث الشقة'.tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      print('Error updating apartment: $e');
      Get.snackbar(
        'خطأ'.tr,
        'حدث خطأ أثناء التحديث'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل الشقة'.tr),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'العنوان'.tr,
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال العنوان'.tr;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              decoration: InputDecoration(
                labelText: 'السعر'.tr,
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال السعر'.tr;
                }
                if (double.tryParse(value.trim()) == null) {
                  return 'الرجاء إدخال رقم صحيح'.tr;
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'الوصف'.tr,
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'الرجاء إدخال الوصف'.tr;
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            Obx(() => SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isLoading.value ? null : _updateApartment,
                icon: isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  isLoading.value ? 'جاري التحديث...'.tr : 'حفظ التعديلات'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}