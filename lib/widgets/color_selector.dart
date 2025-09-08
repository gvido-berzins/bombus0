import 'package:flutter/material.dart';
import '../models/species.dart';
import '../providers/findings_provider.dart';

class ColorSelector extends StatelessWidget {
  final Map<String, String> selectedColors;
  final Function(Map<String, String>) onColorsChanged;
  final bool showPresets;

  const ColorSelector({
    Key? key,
    required this.selectedColors,
    required this.onColorsChanged,
    this.showPresets = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showPresets) ...[
          const Text(
            'Quick Presets',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildPresets(context),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
        ],
        const Text(
          'Manual Color Selection',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildManualSelector(),
      ],
    );
  }

  Widget _buildPresets(BuildContext context) {
    return Column(
      children: colorPresets.map((preset) {
        final isSelected = _isPresetSelected(preset);
        return Card(
          elevation: isSelected ? 4 : 1,
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
          child: ListTile(
            title: Text(
              preset.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(preset.description),
                const SizedBox(height: 8),
                _buildPresetColors(preset.colors),
              ],
            ),
            trailing: isSelected 
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
            onTap: () => _selectPreset(preset),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPresetColors(Map<String, String> colors) {
    return Wrap(
      spacing: 4,
      children: colors.entries.map((entry) {
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: _getColorFromString(entry.value),
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Tooltip(
            message: '${entry.key}: ${entry.value}',
            child: const SizedBox(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildManualSelector() {
    return Column(
      children: BodyRegion.values.map((region) {
        final selectedColor = selectedColors[region.value];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    region.value.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Wrap(
                    spacing: 8,
                    children: BeeColor.values.map((color) {
                      final isSelected = selectedColor == color.value;
                      return GestureDetector(
                        onTap: () => _selectColor(region.value, color.value),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getColorFromString(color.value),
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey,
                              width: isSelected ? 3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check,
                                  size: 16,
                                  color: _getContrastColor(color.value),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                  onPressed: selectedColor != null
                      ? () => _clearColor(region.value)
                      : null,
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear color',
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _isPresetSelected(ColorPreset preset) {
    if (selectedColors.length != preset.colors.length) return false;
    
    for (final entry in preset.colors.entries) {
      if (selectedColors[entry.key] != entry.value) return false;
    }
    return true;
  }

  void _selectPreset(ColorPreset preset) {
    onColorsChanged(Map<String, String>.from(preset.colors));
  }

  void _selectColor(String region, String color) {
    final newColors = Map<String, String>.from(selectedColors);
    newColors[region] = color;
    onColorsChanged(newColors);
  }

  void _clearColor(String region) {
    final newColors = Map<String, String>.from(selectedColors);
    newColors.remove(region);
    onColorsChanged(newColors);
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'yellow':
        return Colors.yellow.shade600;
      case 'orange':
        return Colors.orange.shade600;
      case 'red':
        return Colors.red.shade600;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'brown':
        return Colors.brown.shade600;
      case 'gray':
        return Colors.grey.shade600;
      default:
        return Colors.grey;
    }
  }

  Color _getContrastColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black':
      case 'brown':
      case 'red':
        return Colors.white;
      default:
        return Colors.black;
    }
  }
}

class ColorPresetCard extends StatelessWidget {
  final ColorPreset preset;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorPresetCard({
    Key? key,
    required this.preset,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 6 : 2,
      color: isSelected 
          ? Theme.of(context).primaryColor.withOpacity(0.1) 
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      preset.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                preset.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: preset.colors.entries.map((entry) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _getColorFromString(entry.value),
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.key.substring(0, 3).toUpperCase(),
                          style: const TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'yellow':
        return Colors.yellow.shade600;
      case 'orange':
        return Colors.orange.shade600;
      case 'red':
        return Colors.red.shade600;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'brown':
        return Colors.brown.shade600;
      case 'gray':
        return Colors.grey.shade600;
      default:
        return Colors.grey;
    }
  }
}
