import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/species.dart';
import '../providers/findings_provider.dart';
import '../widgets/bee_diagram.dart';
import '../widgets/color_selector.dart';
import 'details_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  Map<String, String> selectedColors = {};
  bool showPresetView = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider(selectedColors));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bumble Bee Identifier'),
        backgroundColor: Colors.amber.shade100,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _clearSelection,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear all selections',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.touch_app), text: 'Interactive'),
            Tab(icon: Icon(Icons.palette), text: 'Manual'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search interface
          Expanded(
            flex: 2,
            child: TabBarView(
              controller: _tabController,
              children: [
                // Interactive bee diagram tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        elevation: 4,
                        child: BeeDiagram(
                          selectedColors: selectedColors,
                          onRegionColorChanged: _onRegionColorChanged,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildPresetToggle(),
                      if (showPresetView) ...[
                        const SizedBox(height: 16),
                        _buildQuickPresets(),
                      ],
                    ],
                  ),
                ),
                // Manual color selection tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: ColorSelector(
                    selectedColors: selectedColors,
                    onColorsChanged: _onColorsChanged,
                    showPresets: true,
                  ),
                ),
              ],
            ),
          ),
          
          // Search button and results
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: selectedColors.isNotEmpty ? _performSearch : null,
                        icon: const Icon(Icons.search),
                        label: Text(
                          selectedColors.isEmpty 
                              ? 'Select colors to search'
                              : 'Search Species (${selectedColors.length} colors)',
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.amber.shade600,
                          foregroundColor: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: _showSearchTips,
                      icon: const Icon(Icons.help_outline),
                      tooltip: 'Search tips',
                    ),
                  ],
                ),
                if (selectedColors.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildSelectedColorsChips(),
                ],
              ],
            ),
          ),
          
          // Results section
          Expanded(
            flex: 3,
            child: _buildSearchResults(searchResults),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetToggle() {
    return Card(
      child: SwitchListTile(
        title: const Text('Show Quick Presets'),
        subtitle: const Text('Use predefined color combinations'),
        value: showPresetView,
        onChanged: (value) {
          setState(() {
            showPresetView = value;
          });
        },
        secondary: const Icon(Icons.speed),
      ),
    );
  }

  Widget _buildQuickPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Presets',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...colorPresets.map((preset) {
          final isSelected = _isPresetSelected(preset);
          return Card(
            color: isSelected ? Colors.amber.shade50 : null,
            child: ListTile(
              title: Text(preset.name),
              subtitle: Text(preset.description),
              trailing: isSelected 
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () => _selectPreset(preset),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildSelectedColorsChips() {
    return Wrap(
      spacing: 8,
      children: selectedColors.entries.map((entry) {
        return Chip(
          label: Text('${entry.key}: ${entry.value}'),
          backgroundColor: _getColorFromString(entry.value).withOpacity(0.3),
          deleteIcon: const Icon(Icons.close, size: 18),
          onDeleted: () => _removeColor(entry.key),
        );
      }).toList(),
    );
  }

  Widget _buildSearchResults(List<Species> results) {
    if (selectedColors.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Select colors to find matching species',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Tap on the bee diagram or use manual selection',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.orange.shade300),
            const SizedBox(height: 16),
            const Text(
              'No matching species found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your color selection',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _clearSelection,
              child: const Text('Clear Selection'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Found ${results.length} matching species',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final species = results[index];
              return _buildSpeciesCard(species);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpeciesCard(Species species) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetails(species),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          species.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          species.scientificName,
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                species.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Colors: '),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      children: species.bodyColors.entries.map((entry) {
                        return Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: _getColorFromString(entry.value),
                            border: Border.all(color: Colors.black26),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onRegionColorChanged(String region, String color) {
    setState(() {
      selectedColors[region] = color;
    });
  }

  void _onColorsChanged(Map<String, String> colors) {
    setState(() {
      selectedColors = colors;
    });
  }

  void _clearSelection() {
    setState(() {
      selectedColors.clear();
    });
  }

  void _removeColor(String region) {
    setState(() {
      selectedColors.remove(region);
    });
  }

  bool _isPresetSelected(ColorPreset preset) {
    if (selectedColors.length != preset.colors.length) return false;
    
    for (final entry in preset.colors.entries) {
      if (selectedColors[entry.key] != entry.value) return false;
    }
    return true;
  }

  void _selectPreset(ColorPreset preset) {
    setState(() {
      selectedColors = Map<String, String>.from(preset.colors);
    });
  }

  void _performSearch() {
    // Search is performed automatically via the provider
    // This method could be used for analytics or additional actions
  }

  void _navigateToDetails(Species species) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsScreen(species: species),
      ),
    );
  }

  void _showSearchTips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Tips'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Tap on body regions in the bee diagram to select colors'),
            SizedBox(height: 8),
            Text('• Use quick presets for common patterns'),
            SizedBox(height: 8),
            Text('• The more colors you select, the more specific the search'),
            SizedBox(height: 8),
            Text('• Results show species that match at least 70% of your selection'),
            SizedBox(height: 8),
            Text('• Tap on a result to see detailed information and add a finding'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
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
