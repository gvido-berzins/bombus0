import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/species.dart';
import '../models/finding.dart';
import '../providers/findings_provider.dart';

class DetailsScreen extends ConsumerStatefulWidget {
  final Species species;
  final Finding? existingFinding;

  const DetailsScreen({
    Key? key,
    required this.species,
    this.existingFinding,
  }) : super(key: key);

  @override
  ConsumerState<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends ConsumerState<DetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _locationController = TextEditingController();
  
  String? _imagePath;
  String _selectedType = BeeType.worker.name;
  LatLng? _selectedLocation;
  GoogleMapController? _mapController;
  bool _isLoadingLocation = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.existingFinding != null) {
      _initializeFromExisting();
    } else {
      _getCurrentLocation();
    }
  }

  void _initializeFromExisting() {
    final finding = widget.existingFinding!;
    _notesController.text = finding.notes;
    _locationController.text = finding.locationName ?? '';
    _selectedType = finding.type;
    _imagePath = finding.imagePath;
    _selectedLocation = LatLng(finding.latitude, finding.longitude);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingFinding != null ? 'Edit Finding' : 'Add Finding'),
        backgroundColor: Colors.amber.shade100,
        actions: [
          IconButton(
            onPressed: _saveFinding,
            icon: const Icon(Icons.save),
            tooltip: 'Save finding',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSpeciesInfo(),
              const SizedBox(height: 24),
              _buildImageSection(),
              const SizedBox(height: 24),
              _buildTypeSelection(),
              const SizedBox(height: 24),
              _buildNotesSection(),
              const SizedBox(height: 24),
              _buildLocationSection(),
              const SizedBox(height: 24),
              _buildMapSection(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeciesInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Species Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              widget.species.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              widget.species.scientificName,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),
            Text(widget.species.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  label: const Text('Habitat'),
                  backgroundColor: Colors.green.shade100,
                ),
                ...widget.species.habitat.map((h) => Chip(label: Text(h))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (_imagePath != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: FileImage(File(_imagePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () => setState(() => _imagePath = null),
                        icon: const Icon(Icons.delete, color: Colors.red),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'Add a photo of your finding',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('From Gallery'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bee Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: BeeType.values.map((type) {
                final isSelected = _selectedType == type.name;
                return FilterChip(
                  label: Text(type.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedType = type.name);
                    }
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: Colors.amber.shade200,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Add notes about your observation...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please add some notes about your finding';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Location',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (_isLoadingLocation)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    tooltip: 'Get current location',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location name (optional)',
                hintText: 'e.g., Central Park, My Garden',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.place),
              ),
            ),
            const SizedBox(height: 12),
            if (_selectedLocation != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No location selected. Tap the location button or select on map.',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Map Location',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _selectedLocation != null
                    ? GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _selectedLocation!,
                          zoom: 15,
                        ),
                        markers: {
                          Marker(
                            markerId: const MarkerId('finding_location'),
                            position: _selectedLocation!,
                            draggable: true,
                            onDragEnd: (newPosition) {
                              setState(() {
                                _selectedLocation = newPosition;
                              });
                            },
                          ),
                        },
                        onTap: (position) {
                          setState(() {
                            _selectedLocation = position;
                          });
                        },
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                      )
                    : Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text(
                                'Get location to show map',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
            if (_selectedLocation != null) ...[
              const SizedBox(height: 8),
              Text(
                'Tap on the map or drag the marker to adjust location',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _saveFinding,
            icon: const Icon(Icons.save),
            label: Text(widget.existingFinding != null ? 'Update Finding' : 'Save Finding'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.amber.shade600,
              foregroundColor: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.cancel),
            label: const Text('Cancel'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error getting location: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _saveFinding() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a location'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final finding = Finding(
      id: widget.existingFinding?.id ?? const Uuid().v4(),
      species: widget.species,
      type: _selectedType,
      notes: _notesController.text.trim(),
      imagePath: _imagePath,
      date: widget.existingFinding?.date ?? DateTime.now(),
      latitude: _selectedLocation!.latitude,
      longitude: _selectedLocation!.longitude,
      locationName: _locationController.text.trim().isNotEmpty 
          ? _locationController.text.trim() 
          : null,
    );

    if (widget.existingFinding != null) {
      ref.read(findingsProvider.notifier).updateFinding(finding);
    } else {
      ref.read(findingsProvider.notifier).addFinding(finding);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existingFinding != null 
              ? 'Finding updated successfully!' 
              : 'Finding saved successfully!',
        ),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.of(context).pop();
  }
}
