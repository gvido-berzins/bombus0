import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/finding.dart';
import '../providers/findings_provider.dart';
import '../screens/details_screen.dart';

class FindingsGallery extends ConsumerWidget {
  final List<Finding> findings;
  final SortOption sortOption;
  final Function(SortOption) onSortChanged;

  const FindingsGallery({
    Key? key,
    required this.findings,
    required this.sortOption,
    required this.onSortChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (findings.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No findings yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Start by identifying some bees!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildSortHeader(context),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: findings.length,
            itemBuilder: (context, index) {
              final finding = findings[index];
              return _buildGalleryCard(context, ref, finding);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSortHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Text(
            '${findings.length} findings',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          PopupMenuButton<SortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort options',
            onSelected: onSortChanged,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortOption.dateNewest,
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: sortOption == SortOption.dateNewest ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Newest first'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOption.dateOldest,
                child: Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: sortOption == SortOption.dateOldest ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Oldest first'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOption.species,
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_by_alpha,
                      color: sortOption == SortOption.species ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Species name'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOption.type,
                child: Row(
                  children: [
                    Icon(
                      Icons.category,
                      color: sortOption == SortOption.type ? Colors.blue : null,
                    ),
                    const SizedBox(width: 8),
                    const Text('Bee type'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryCard(BuildContext context, WidgetRef ref, Finding finding) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetails(context, finding),
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  color: Colors.grey.shade200,
                ),
                child: finding.imagePath != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        child: Stack(
                          children: [
                            Image.file(
                              File(finding.imagePath!),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  ),
                                );
                              },
                            ),
                            // Type badge
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(finding.type).withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  finding.type.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            // Actions menu
                            Positioned(
                              top: 4,
                              right: 4,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: PopupMenuButton<String>(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  onSelected: (action) => _handleAction(context, ref, finding, action),
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit),
                                          SizedBox(width: 8),
                                          Text('Edit'),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text('Delete', style: TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera,
                              size: 40,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'No Photo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
            // Details section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      finding.species.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      finding.species.scientificName,
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 10,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            _formatDate(finding.date),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (finding.locationName != null) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.place,
                            size: 10,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              finding.locationName!,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (finding.notes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          finding.notes,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context, Finding finding) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          species: finding.species,
          existingFinding: finding,
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, WidgetRef ref, Finding finding, String action) {
    switch (action) {
      case 'edit':
        _navigateToDetails(context, finding);
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref, finding);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, Finding finding) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Finding'),
        content: Text(
          'Are you sure you want to delete this finding of ${finding.species.name}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(findingsProvider.notifier).removeFinding(finding.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Finding deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'queen':
        return Colors.purple;
      case 'worker':
        return Colors.blue;
      case 'male':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class FindingDetailDialog extends StatelessWidget {
  final Finding finding;

  const FindingDetailDialog({
    Key? key,
    required this.finding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image section
            if (finding.imagePath != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  image: DecorationImage(
                    image: FileImage(File(finding.imagePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            // Details section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    finding.species.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    finding.species.scientificName,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(finding.type),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          finding.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatDate(finding.date),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  if (finding.locationName != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.place, size: 16),
                        const SizedBox(width: 4),
                        Expanded(child: Text(finding.locationName!)),
                      ],
                    ),
                  ],
                  if (finding.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Notes:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(finding.notes),
                  ],
                ],
              ),
            ),
            // Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'queen':
        return Colors.purple;
      case 'worker':
        return Colors.blue;
      case 'male':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
