import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/finding.dart';
import '../models/species.dart';

// Provider for findings list
final findingsProvider = StateNotifierProvider<FindingsNotifier, List<Finding>>((ref) {
  return FindingsNotifier();
});

// Provider for species data
final speciesProvider = Provider<List<Species>>((ref) {
  return _sampleSpecies;
});

// Provider for filtered findings
final filteredFindingsProvider = Provider.family<List<Finding>, FindingsFilter>((ref, filter) {
  final findings = ref.watch(findingsProvider);
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
});

// Provider for search results based on color selection
final searchResultsProvider = Provider.family<List<Species>, Map<String, String>>((ref, selectedColors) {
  final species = ref.watch(speciesProvider);
  
  if (selectedColors.isEmpty) {
    return species;
  }
  
  return species.where((species) {
    // Check if species matches the selected colors
    int matches = 0;
    for (final entry in selectedColors.entries) {
      if (species.bodyColors[entry.key] == entry.value) {
        matches++;
      }
    }
    // Return species that match at least 70% of selected colors
    return matches >= (selectedColors.length * 0.7);
  }).toList();
});

class FindingsNotifier extends StateNotifier<List<Finding>> {
  FindingsNotifier() : super([]) {
    _loadFindings();
  }

  Future<void> _loadFindings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final findingsJson = prefs.getStringList('findings') ?? [];
      
      final findings = findingsJson
          .map((json) => Finding.fromJson(jsonDecode(json)))
          .toList();
      
      state = findings;
    } catch (e) {
      // If loading fails, start with empty list
      state = [];
    }
  }

  Future<void> _saveFindings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final findingsJson = state
          .map((finding) => jsonEncode(finding.toJson()))
          .toList();
      
      await prefs.setStringList('findings', findingsJson);
    } catch (e) {
      // Handle save error
      print('Error saving findings: $e');
    }
  }

  void addFinding(Finding finding) {
    state = [...state, finding];
    _saveFindings();
  }

  void updateFinding(Finding updatedFinding) {
    state = state.map((finding) {
      return finding.id == updatedFinding.id ? updatedFinding : finding;
    }).toList();
    _saveFindings();
  }

  void removeFinding(String id) {
    state = state.where((finding) => finding.id != id).toList();
    _saveFindings();
  }

  List<Finding> getSortedFindings(SortOption sortOption) {
    final findings = List<Finding>.from(state);
    
    switch (sortOption) {
      case SortOption.dateNewest:
        findings.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.dateOldest:
        findings.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.species:
        findings.sort((a, b) => a.species.name.compareTo(b.species.name));
        break;
      case SortOption.type:
        findings.sort((a, b) => a.type.compareTo(b.type));
        break;
    }
    
    return findings;
  }
}

class FindingsFilter {
  final String? speciesId;
  final String? type;
  final DateTime? startDate;
  final DateTime? endDate;

  const FindingsFilter({
    this.speciesId,
    this.type,
    this.startDate,
    this.endDate,
  });
}

enum SortOption {
  dateNewest,
  dateOldest,
  species,
  type,
}

// Sample species data
final List<Species> _sampleSpecies = [
  Species(
    id: '1',
    name: 'Common Carder Bee',
    scientificName: 'Bombus pascuorum',
    imageQueen: 'assets/images/pascuorum_queen.jpg',
    imageWorker: 'assets/images/pascuorum_worker.jpg',
    imageMale: 'assets/images/pascuorum_male.jpg',
    bodyColors: {
      'head': 'black',
      'thorax': 'yellow',
      'abdomen1': 'orange',
      'abdomen2': 'black',
      'abdomen3': 'white',
      'legs': 'black',
      'wings': 'gray',
    },
    description: 'A common species with distinctive orange and white markings.',
    habitat: ['Gardens', 'Parks', 'Meadows', 'Woodland edges'],
    distribution: 'Throughout Europe and parts of Asia',
  ),
  Species(
    id: '2',
    name: 'Buff-tailed Bumblebee',
    scientificName: 'Bombus terrestris',
    imageQueen: 'assets/images/terrestris_queen.jpg',
    imageWorker: 'assets/images/terrestris_worker.jpg',
    imageMale: 'assets/images/terrestris_male.jpg',
    bodyColors: {
      'head': 'black',
      'thorax': 'yellow',
      'abdomen1': 'black',
      'abdomen2': 'black',
      'abdomen3': 'white',
      'legs': 'black',
      'wings': 'gray',
    },
    description: 'One of the most common bumblebees with a distinctive white tail.',
    habitat: ['Urban areas', 'Gardens', 'Agricultural land', 'Grasslands'],
    distribution: 'Europe, introduced to other continents',
  ),
  Species(
    id: '3',
    name: 'Red-tailed Bumblebee',
    scientificName: 'Bombus lapidarius',
    imageQueen: 'assets/images/lapidarius_queen.jpg',
    imageWorker: 'assets/images/lapidarius_worker.jpg',
    imageMale: 'assets/images/lapidarius_male.jpg',
    bodyColors: {
      'head': 'black',
      'thorax': 'black',
      'abdomen1': 'black',
      'abdomen2': 'black',
      'abdomen3': 'red',
      'legs': 'black',
      'wings': 'gray',
    },
    description: 'Distinctive all-black body with bright red tail.',
    habitat: ['Gardens', 'Parks', 'Heathland', 'Coastal areas'],
    distribution: 'Europe and western Asia',
  ),
  Species(
    id: '4',
    name: 'White-tailed Bumblebee',
    scientificName: 'Bombus lucorum',
    imageQueen: 'assets/images/lucorum_queen.jpg',
    imageWorker: 'assets/images/lucorum_worker.jpg',
    imageMale: 'assets/images/lucorum_male.jpg',
    bodyColors: {
      'head': 'black',
      'thorax': 'yellow',
      'abdomen1': 'yellow',
      'abdomen2': 'black',
      'abdomen3': 'white',
      'legs': 'black',
      'wings': 'gray',
    },
    description: 'Similar to buff-tailed but with yellow band on abdomen.',
    habitat: ['Woodlands', 'Gardens', 'Meadows', 'Mountain areas'],
    distribution: 'Northern Europe and mountainous regions',
  ),
];

// Predefined color presets
final List<ColorPreset> colorPresets = [
  ColorPreset(
    name: 'Classic Yellow & Black',
    colors: {
      'head': 'black',
      'thorax': 'yellow',
      'abdomen1': 'black',
      'abdomen2': 'black',
      'abdomen3': 'white',
    },
    description: 'Most common bumblebee pattern',
  ),
  ColorPreset(
    name: 'Red-tailed',
    colors: {
      'head': 'black',
      'thorax': 'black',
      'abdomen1': 'black',
      'abdomen2': 'black',
      'abdomen3': 'red',
    },
    description: 'All black with red tail',
  ),
  ColorPreset(
    name: 'Carder Bee',
    colors: {
      'head': 'black',
      'thorax': 'yellow',
      'abdomen1': 'orange',
      'abdomen2': 'black',
      'abdomen3': 'white',
    },
    description: 'Orange and white markings',
  ),
];
