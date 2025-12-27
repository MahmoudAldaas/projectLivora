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
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
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
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('governorate'.tr, theme),
              const SizedBox(height: 8),
              Obx(
                () => _FilterDropdownButton(
                  title: controller.selectedGovernorate.value.isEmpty
                      ? 'choose_governorate'.tr
                      : controller.selectedGovernorate.value,
                  onTap: () => _showGovernorateSheet(context, controller, theme),
                ),
              ),

              const SizedBox(height: 20),

              _sectionTitle('city'.tr, theme),
              const SizedBox(height: 8),
              Obx(
                () => _FilterDropdownButton(
                  title: controller.selectedCity.value.isEmpty
                      ? 'choose_city'.tr
                      : controller.selectedCity.value,
                  enabled:
                      controller.selectedGovernorate.value.isNotEmpty,
                  onTap: () => _showCitySheet(context, controller, theme),
                ),
              ),

              const SizedBox(height: 20),

              _sectionTitle('price'.tr, theme),
              const SizedBox(height: 8),
              Obx(() => _priceSlider(controller, theme)),

              const SizedBox(height: 20),

              _sectionTitle('number_of_bedrooms'.tr, theme),
              const SizedBox(height: 8),
              Obx(
                () => _FilterDropdownButton(
                  title: controller.selectedBedrooms.value.isEmpty
                      ? 'choose_bedrooms'.tr
                      : _getBedroomsText(controller.selectedBedrooms.value),
                  onTap: () => _showBedroomsSheet(context, controller, theme),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: controller.applyFilter,
                  child: Text(
                    'search'.tr,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'DancingScript',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Widgets =================

  Widget _sectionTitle(String text, ThemeData theme) {
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontFamily: 'DancingScript',
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _priceSlider(FilterController controller, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${'from'.tr}: ${controller.formatPrice(controller.minPrice.value)}',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${'to'.tr}: ${controller.formatPrice(controller.maxPrice.value)}',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
          RangeSlider(
            values: RangeValues(
              controller.minPrice.value,
              controller.maxPrice.value,
            ),
            min: 100000,
            max: 1000000,
            divisions: 99,
            activeColor: theme.colorScheme.primary,
            onChanged: (values) {
              controller.minPrice.value = values.start;
              controller.maxPrice.value = values.end;
            },
          ),
        ],
      ),
    );
  }

  String _getBedroomsText(String bedrooms) {
    if (bedrooms == '1') return 'one_bedroom'.tr;
    if (bedrooms == '2') return 'two_bedrooms'.tr;
    if (bedrooms == '5') return 'five_bedrooms'.tr;
    return 'bedrooms_n'.tr.replaceAll('@n', bedrooms);
  }

  // ================= Bottom Sheets =================

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
      Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'DancingScript',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final value = items[i];
                return ListTile(
                  title: Text(
                    display != null ? display(value) : value,
                    style:
                        const TextStyle(fontFamily: 'DancingScript'),
                  ),
                  trailing: selected == value
                      ? Icon(Icons.check,
                          color: theme.colorScheme.primary)
                      : null,
                  onTap: () => onTap(value),
                );
              },
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ================= Dropdown Button =================

class _FilterDropdownButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool enabled;

  const _FilterDropdownButton({
    required this.title,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? theme.cardColor : theme.disabledColor.withOpacity(.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'DancingScript',
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? theme.textTheme.bodyLarge?.color
                      : theme.disabledColor,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down,
                color: enabled
                    ? theme.colorScheme.primary
                    : theme.disabledColor),
          ],
        ),
      ),
    );
  }
}
