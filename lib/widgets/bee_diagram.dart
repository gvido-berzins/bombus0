import 'package:flutter/material.dart';
import '../models/species.dart';

class BeeDiagram extends StatefulWidget {
  final Map<String, String> selectedColors;
  final Function(String region, String color) onRegionColorChanged;
  final bool isInteractive;

  const BeeDiagram({
    Key? key,
    required this.selectedColors,
    required this.onRegionColorChanged,
    this.isInteractive = true,
  }) : super(key: key);

  @override
  State<BeeDiagram> createState() => _BeeDiagramState();
}

class _BeeDiagramState extends State<BeeDiagram> {
  String? selectedRegion;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Bee diagram
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: BeePainter(
                selectedColors: widget.selectedColors,
                selectedRegion: selectedRegion,
                onRegionTap: widget.isInteractive ? _onRegionTap : null,
              ),
              child: GestureDetector(
                onTapDown: widget.isInteractive ? _handleTapDown : null,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Region labels
          if (widget.isInteractive) _buildRegionLabels(),
        ],
      ),
    );
  }

  void _onRegionTap(String region) {
    setState(() {
      selectedRegion = region;
    });
    _showColorPicker(region);
  }

  void _handleTapDown(TapDownDetails details) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    // Calculate which region was tapped based on position
    final region = _getRegionFromPosition(localPosition);
    if (region != null) {
      _onRegionTap(region);
    }
  }

  String? _getRegionFromPosition(Offset position) {
    // Simple region detection based on position
    // This is a simplified version - in a real app, you'd use more precise hit detection
    final width = 300.0; // Approximate diagram width
    final height = 300.0; // Approximate diagram height
    
    final x = position.dx;
    final y = position.dy;
    
    // Head region (top center)
    if (x > width * 0.35 && x < width * 0.65 && y > height * 0.1 && y < height * 0.3) {
      return BodyRegion.head.value;
    }
    
    // Thorax region (middle center)
    if (x > width * 0.3 && x < width * 0.7 && y > height * 0.3 && y < height * 0.5) {
      return BodyRegion.thorax.value;
    }
    
    // Abdomen regions (bottom, divided into segments)
    if (y > height * 0.5 && y < height * 0.9) {
      if (x > width * 0.25 && x < width * 0.75) {
        if (y < height * 0.63) return BodyRegion.abdomen1.value;
        if (y < height * 0.76) return BodyRegion.abdomen2.value;
        return BodyRegion.abdomen3.value;
      }
    }
    
    // Legs (sides)
    if ((x < width * 0.3 || x > width * 0.7) && y > height * 0.3 && y < height * 0.8) {
      return BodyRegion.legs.value;
    }
    
    // Wings (upper sides)
    if ((x < width * 0.35 || x > width * 0.65) && y > height * 0.25 && y < height * 0.55) {
      return BodyRegion.wings.value;
    }
    
    return null;
  }

  void _showColorPicker(String region) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Color for ${region.toUpperCase()}'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BeeColor.values.map((color) {
            return GestureDetector(
              onTap: () {
                widget.onRegionColorChanged(region, color.value);
                Navigator.of(context).pop();
                setState(() {
                  selectedRegion = null;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getColorFromString(color.value),
                  border: Border.all(
                    color: widget.selectedColors[region] == color.value
                        ? Colors.blue
                        : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: widget.selectedColors[region] == color.value
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                selectedRegion = null;
              });
            },
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionLabels() {
    return Column(
      children: [
        const Text(
          'Tap on a body region to select its color',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: BodyRegion.values.map((region) {
            final color = widget.selectedColors[region.value];
            return Chip(
              label: Text(
                region.value.toUpperCase(),
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: color != null 
                  ? _getColorFromString(color).withOpacity(0.3)
                  : Colors.grey.shade200,
              side: BorderSide(
                color: color != null 
                    ? _getColorFromString(color)
                    : Colors.grey,
              ),
            );
          }).toList(),
        ),
      ],
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

class BeePainter extends CustomPainter {
  final Map<String, String> selectedColors;
  final String? selectedRegion;
  final Function(String)? onRegionTap;

  BeePainter({
    required this.selectedColors,
    this.selectedRegion,
    this.onRegionTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black87;

    final selectedPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.blue;

    // Draw bee body parts
    _drawHead(canvas, size, paint, outlinePaint, selectedPaint);
    _drawThorax(canvas, size, paint, outlinePaint, selectedPaint);
    _drawAbdomen(canvas, size, paint, outlinePaint, selectedPaint);
    _drawLegs(canvas, size, paint, outlinePaint, selectedPaint);
    _drawWings(canvas, size, paint, outlinePaint, selectedPaint);
  }

  void _drawHead(Canvas canvas, Size size, Paint paint, Paint outlinePaint, Paint selectedPaint) {
    final center = Offset(size.width * 0.5, size.height * 0.2);
    final radius = size.width * 0.08;

    paint.color = _getColorFromString(selectedColors['head'] ?? 'black');
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius, outlinePaint);

    if (selectedRegion == 'head') {
      canvas.drawCircle(center, radius, selectedPaint);
    }

    // Eyes
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawCircle(Offset(center.dx - radius * 0.4, center.dy - radius * 0.2), radius * 0.2, eyePaint);
    canvas.drawCircle(Offset(center.dx + radius * 0.4, center.dy - radius * 0.2), radius * 0.2, eyePaint);
  }

  void _drawThorax(Canvas canvas, Size size, Paint paint, Paint outlinePaint, Paint selectedPaint) {
    final center = Offset(size.width * 0.5, size.height * 0.4);
    final width = size.width * 0.12;
    final height = size.height * 0.08;

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      const Radius.circular(8),
    );

    paint.color = _getColorFromString(selectedColors['thorax'] ?? 'yellow');
    canvas.drawRRect(rect, paint);
    canvas.drawRRect(rect, outlinePaint);

    if (selectedRegion == 'thorax') {
      canvas.drawRRect(rect, selectedPaint);
    }
  }

  void _drawAbdomen(Canvas canvas, Size size, Paint paint, Paint outlinePaint, Paint selectedPaint) {
    final segments = ['abdomen1', 'abdomen2', 'abdomen3'];
    
    for (int i = 0; i < segments.length; i++) {
      final center = Offset(size.width * 0.5, size.height * (0.56 + i * 0.13));
      final width = size.width * (0.14 - i * 0.01);
      final height = size.height * 0.06;

      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: width, height: height),
        const Radius.circular(6),
      );

      paint.color = _getColorFromString(selectedColors[segments[i]] ?? 'black');
      canvas.drawRRect(rect, paint);
      canvas.drawRRect(rect, outlinePaint);

      if (selectedRegion == segments[i]) {
        canvas.drawRRect(rect, selectedPaint);
      }
    }
  }

  void _drawLegs(Canvas canvas, Size size, Paint paint, Paint outlinePaint, Paint selectedPaint) {
    paint.color = _getColorFromString(selectedColors['legs'] ?? 'black');
    
    final legPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = paint.color;

    // Left legs
    for (int i = 0; i < 3; i++) {
      final start = Offset(size.width * 0.35, size.height * (0.35 + i * 0.15));
      final end = Offset(size.width * 0.15, size.height * (0.45 + i * 0.15));
      canvas.drawLine(start, end, legPaint);
    }

    // Right legs
    for (int i = 0; i < 3; i++) {
      final start = Offset(size.width * 0.65, size.height * (0.35 + i * 0.15));
      final end = Offset(size.width * 0.85, size.height * (0.45 + i * 0.15));
      canvas.drawLine(start, end, legPaint);
    }

    if (selectedRegion == 'legs') {
      legPaint.color = Colors.blue;
      legPaint.strokeWidth = 6;
      // Redraw with selection color
      for (int i = 0; i < 3; i++) {
        final start = Offset(size.width * 0.35, size.height * (0.35 + i * 0.15));
        final end = Offset(size.width * 0.15, size.height * (0.45 + i * 0.15));
        canvas.drawLine(start, end, legPaint);
      }
      for (int i = 0; i < 3; i++) {
        final start = Offset(size.width * 0.65, size.height * (0.35 + i * 0.15));
        final end = Offset(size.width * 0.85, size.height * (0.45 + i * 0.15));
        canvas.drawLine(start, end, legPaint);
      }
    }
  }

  void _drawWings(Canvas canvas, Size size, Paint paint, Paint outlinePaint, Paint selectedPaint) {
    paint.color = _getColorFromString(selectedColors['wings'] ?? 'gray').withOpacity(0.7);
    
    // Left wing
    final leftWing = Path()
      ..moveTo(size.width * 0.35, size.height * 0.35)
      ..quadraticBezierTo(size.width * 0.15, size.height * 0.25, size.width * 0.25, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.5, size.width * 0.4, size.height * 0.45)
      ..close();

    // Right wing
    final rightWing = Path()
      ..moveTo(size.width * 0.65, size.height * 0.35)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.25, size.width * 0.75, size.height * 0.45)
      ..quadraticBezierTo(size.width * 0.7, size.height * 0.5, size.width * 0.6, size.height * 0.45)
      ..close();

    canvas.drawPath(leftWing, paint);
    canvas.drawPath(rightWing, paint);
    canvas.drawPath(leftWing, outlinePaint);
    canvas.drawPath(rightWing, outlinePaint);

    if (selectedRegion == 'wings') {
      canvas.drawPath(leftWing, selectedPaint);
      canvas.drawPath(rightWing, selectedPaint);
    }
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
