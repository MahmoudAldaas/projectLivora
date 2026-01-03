import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livora/controller/filter_controller.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = Get.put(FilterController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          leading: IconButton(
            icon: Icon(Icons.close, color: theme.iconTheme.color),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'filter'.tr,
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: 'DancingScript',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          actions: [
            Obx(
              () => controller.hasActiveFilters
                  ? TextButton(
                      onPressed: controller.resetFilter,
                      child: Text(
                        'reset'.tr,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'DancingScript',
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(width: 8),
          ],
        ),

        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection(
                      title: 'governorate'.tr,
                      theme: theme,
                      child: Obx(
                        () => _FilterCard(
                          title: controller.selectedGovernorate.value.isEmpty
                              ? 'choose_governorate'.tr
                              : controller.selectedGovernorate.value.tr,
                          icon: Icons.location_city,
                          hasValue: controller.selectedGovernorate.value.isNotEmpty,
                          theme: theme,
                          onTap: () => _showGovernorateSheet(context, controller, theme),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildSection(
                      title: 'city'.tr,
                      theme: theme,
                      child: Obx(
                        () => _FilterCard(
                          title: controller.selectedCity.value.isEmpty
                              ? 'choose_city'.tr
                              : controller.selectedCity.value.tr,
                          icon: Icons.location_on,
                          hasValue: controller.selectedCity.value.isNotEmpty,
                          enabled: controller.selectedGovernorate.value.isNotEmpty,
                          theme: theme,
                          onTap: () => _showCitySheet(context, controller, theme),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildSection(
                      title: 'price'.tr,
                      theme: theme,
                      child: Obx(() => _buildPriceRange(controller, theme)),
                    ),

                    const SizedBox(height: 24),

                    _buildSection(
                      title: 'number_of_bedrooms'.tr,
                      theme: theme,
                      child: Obx(
                        () => _FilterCard(
                          title: controller.selectedBedrooms.value.isEmpty
                              ? 'choose_bedrooms'.tr
                              : _getBedroomsText(controller.selectedBedrooms.value),
                          icon: Icons.bed,
                          hasValue: controller.selectedBedrooms.value.isNotEmpty,
                          theme: theme,
                          onTap: () => _showBedroomsSheet(context, controller, theme),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value 
                          ? null 
                          : controller.applyFilter,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'search'.tr,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontFamily: 'DancingScript',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required ThemeData theme,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12, right: 4),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'DancingScript',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildPriceRange(FilterController controller, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPriceLabel(
                'from'.tr,
                controller.formatPrice(controller.minPrice.value),
                theme,
              ),
              _buildPriceLabel(
                'to'.tr,
                controller.formatPrice(controller.maxPrice.value),
                theme,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(Get.context!).copyWith(
              trackHeight: 4,
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: theme.dividerColor.withOpacity(0.2),
              thumbColor: theme.colorScheme.primary,
              overlayColor: theme.colorScheme.primary.withOpacity(0.1),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: RangeSlider(
              values: RangeValues(
                controller.minPrice.value,
                controller.maxPrice.value,
              ),
              min: 200,
              max: 10000,
              divisions: 99,
              onChanged: (values) {
                controller.minPrice.value = values.start;
                controller.maxPrice.value = values.end;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceLabel(String label, String value, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  String _getBedroomsText(String bedrooms) {
    if (bedrooms == '1') return 'one_bedroom'.tr;
    if (bedrooms == '2') return 'two_bedrooms'.tr;
    if (bedrooms == '5') return 'five_bedrooms'.tr;
    return 'bedrooms_n'.tr.replaceAll('@n', bedrooms);
  }


  void _showGovernorateSheet(
      BuildContext context, FilterController c, ThemeData theme) {
    _showBottomSheet(
      title: 'choose_governorate'.tr,
      items: c.governorates.keys.toList(),
      selected: c.selectedGovernorate.value,
      theme: theme,
      onTap: (v) {
        c.setGovernorate(v);
        Get.back();
      },
    );
  }

  void _showCitySheet(
      BuildContext context, FilterController c, ThemeData theme) {
    _showBottomSheet(
      title: 'choose_city'.tr,
      items: c.cities,
      selected: c.selectedCity.value,
      theme: theme,
      onTap: (v) {
        c.setCity(v);
        Get.back();
      },
    );
  }

  void _showBedroomsSheet(
      BuildContext context, FilterController c, ThemeData theme) {
    _showBottomSheet(
      title: 'choose_bedrooms'.tr,
      items: c.bedroomsOptions,
      selected: c.selectedBedrooms.value,
      theme: theme,
      display: _getBedroomsText,
      onTap: (v) {
        c.setBedrooms(v);
        Get.back();
      },
    );
  }

  void _showBottomSheet({
    required String title,
    required List<String> items,
    required String selected,
    required ThemeData theme,
    required Function(String) onTap,
    String Function(String)? display,
  }) {
    Get.bottomSheet(
      Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'DancingScript',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(Get.context!).size.height * 0.5,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final value = items[i];
                    final isSelected = selected == value;

                    return InkWell(
                      onTap: () => onTap(value),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary.withOpacity(0.08)
                              : null,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                display != null ? display(value) : value.tr,
                                style: TextStyle(
                                  fontFamily: 'DancingScript',
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.primary,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _FilterCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool hasValue;
  final bool enabled;
  final ThemeData theme;
  final VoidCallback onTap;

  const _FilterCard({
    required this.title,
    required this.icon,
    required this.hasValue,
    required this.theme,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: enabled
              ? theme.cardColor
              : theme.disabledColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasValue
                ? theme.colorScheme.primary.withOpacity(0.3)
                : theme.dividerColor.withOpacity(0.1),
            width: hasValue ? 1.5 : 1,
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: enabled
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.disabledColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: enabled
                    ? theme.colorScheme.primary
                    : theme.disabledColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'DancingScript',
                  fontWeight: hasValue ? FontWeight.bold : FontWeight.w600,
                  color: enabled
                      ? (hasValue
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyLarge?.color)
                      : theme.disabledColor,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: enabled
                  ? theme.colorScheme.primary
                  : theme.disabledColor,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}