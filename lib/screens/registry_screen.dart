import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/finding.dart';
import '../models/species.dart';
import '../providers/findings_provider.dart';
import '../widgets/findings_list.dart';
import '../widgets/findings_gallery.dart';

class RegistryScreen extends ConsumerStatefulWidget {
  const RegistryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegistryScreen> createState() => _RegistryScreenState();
}

class _RegistryScreenState extends ConsumerState<RegistryScreen>
    with SingleTickerProviderStateMixin {
  bool _isGridView = false;
  SortOption _sortOption = SortOption.dateNewest;
  FindingsFilter _filter = const FindingsFilter();
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
    final allFindings = ref.watch(findingsProvider);
    
    // Sort findings based on current sort option
    final sortedFindings = ref.read(findingsProvider.notifier).getSortedFindings(_sortOption);
    final finalFindings = _applyFilter(sortedFindings, _filter);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Findings'),
        backgroundColor: Colors.amber.shade100,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_hasActiveFilter())
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Filter findings',
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: _isGridView ? 'List view' : 'Gallery view',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _getStatusText(allFindings.length, finalFindings.length),
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                if (_hasActiveFilter())
                  TextButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: finalFindings.isEmpty && allFindings.isNotEmpty
          ? _buildNoResultsView()
          : _isGridView
              ? FindingsGallery(
                  findings: finalFindings,
                  sortOption: _sortOption,
                  onSortChanged: (option) {
                    setState(() {
                      _sortOption = option;
                    });
                  },
                )
              : FindingsList(
                  findings: finalFindings,
                  sortOption: _sortOption,
                  onSortChanged: (option) {
                    setState(() {
                      _sortOption = option;
                    });
                  },
                ),
      floatingActionButton: allFindings.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showStatsDialog,
              icon: const Icon(Icons.analytics),
              label: const Text('Stats'),
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.black87,
            )
          : null,
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No findings match your filters',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filter settings',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.clear),
            label: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final species = ref.read(speciesProvider);
    
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        currentFilter: _filter,
        availableSpecies: species,
        onFilterChanged: (newFilter) {
          setState(() {
            _filter = newFilter;
          });
        },
      ),
    );
  }

  void _showStatsDialog() {
    final findings = ref.read(findingsProvider);
    
    showDialog(
      context: context,
      builder: (context) => StatsDialog(findings: findings),
    );
  }

  void _clearFilters() {
    setState(() {
      _filter = const FindingsFilter();
    });
  }

  bool _hasActiveFilter() {
    return _filter.speciesId != null ||
           _filter.type != null ||
           _filter.startDate != null ||
           _filter.endDate != null;
  }

  String _getStatusText(int total, int filtered) {
    if (total == 0) {
      return 'No findings yet';
    } else if (filtered == total) {
      return '$total findings';
    } else {
      return '$filtered of $total findings';
    }
  }

  List<Finding> _applyFilter(List<Finding> findings, FindingsFilter filter) {
    return findings.where((finding) {
      bool matchesSpecies = filter.speciesId == null || finding.species.id == filter.speciesId;
      bool matchesType = filter.type == null || finding.type == filter.type;
      bool matchesDateRange = true;
      
      if (filter.startDate != null) {
        matchesDateRange = finding.date.isAfter(filter.startDate!) || 
                          finding.date.isAtSameMomentAs(filter.startDate!);
      }
      
      if (filter.endDate != null && matchesDateRange) {
        matchesDateRange = finding.date.isBefore(filter.endDate!) || 
                          finding.date.isAtSameMomentAs(filter.endDate!);
      }
      
      return matchesSpecies && matchesType && matchesDateRange;
    }).toList();
  }
}

class FilterDialog extends StatefulWidget {
  final FindingsFilter currentFilter;
  final List<Species> availableSpecies;
  final Function(FindingsFilter) onFilterChanged;

  const FilterDialog({
    Key? key,
    required this.currentFilter,
    required this.availableSpecies,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  late String? _selectedSpeciesId;
  late String? _selectedType;
  late DateTime? _startDate;
  late DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedSpeciesId = widget.currentFilter.speciesId;
    _selectedType = widget.currentFilter.type;
    _startDate = widget.currentFilter.startDate;
    _endDate = widget.currentFilter.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Filter Findings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Species filter
            const Text('Species', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedSpeciesId,
              decoration: const InputDecoration(
                hintText: 'All species',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All species'),
                ),
                ...widget.availableSpecies.map((species) {
                  return DropdownMenuItem<String>(
                    value: species.id,
                    child: Text(species.name),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSpeciesId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Type filter
            const Text('Bee Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: const InputDecoration(
                hintText: 'All types',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('All types'),
                ),
                ...BeeType.values.map((type) {
                  return DropdownMenuItem<String>(
                    value: type.name,
                    child: Text(type.displayName),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Date range filter
            const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, true),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_startDate != null 
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Start date'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _selectDate(context, false),
                    icon: const Icon(Icons.calendar_today),
                    label: Text(_endDate != null 
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'End date'),
                  ),
                ),
              ],
            ),
            if (_startDate != null || _endDate != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear dates'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _selectedSpeciesId = null;
              _selectedType = null;
              _startDate = null;
              _endDate = null;
            });
          },
          child: const Text('Clear All'),
        ),
        ElevatedButton(
          onPressed: () {
            final filter = FindingsFilter(
              speciesId: _selectedSpeciesId,
              type: _selectedType,
              startDate: _startDate,
              endDate: _endDate,
            );
            widget.onFilterChanged(filter);
            Navigator.of(context).pop();
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = DateTime(2020);
    final lastDate = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
        } else {
          _endDate = date;
        }
      });
    }
  }
}

class StatsDialog extends StatelessWidget {
  final List<Finding> findings;

  const StatsDialog({Key? key, required this.findings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return AlertDialog(
      title: const Text('Findings Statistics'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard('Total Findings', stats['total'].toString()),
            const SizedBox(height: 12),
            _buildStatCard('Unique Species', stats['uniqueSpecies'].toString()),
            const SizedBox(height: 12),
            const Text('By Type:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...stats['byType'].entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key),
                    Text(entry.value.toString()),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
            const Text('Most Common Species:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...stats['topSpecies'].entries.take(3).map((entry) {
              return Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    Expanded(child: Text(entry.key)),
                    Text(entry.value.toString()),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateStats() {
    final byType = <String, int>{};
    final bySpecies = <String, int>{};
    final uniqueSpecies = <String>{};

    for (final finding in findings) {
      // Count by type
      byType[finding.type] = (byType[finding.type] ?? 0) + 1;
      
      // Count by species
      bySpecies[finding.species.name] = (bySpecies[finding.species.name] ?? 0) + 1;
      uniqueSpecies.add(finding.species.id);
    }

    // Sort species by count
    final sortedSpecies = bySpecies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'total': findings.length,
      'uniqueSpecies': uniqueSpecies.length,
      'byType': byType,
      'topSpecies': Map.fromEntries(sortedSpecies),
    };
  }
}
