import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:convert';
import '../models/task.dart';
import '../models/task_type.dart';
import '../utils/qr_code_manager.dart';
import 'qr_codes_screen.dart';

class AddTaskScreen extends StatefulWidget {
  final bool isIndoor;
  final String gameCode;

  const AddTaskScreen({
    super.key,
    required this.isIndoor,
    required this.gameCode,
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name = '';
  late String _location = '';
  late int _points = 0;
  late String _content = '';
  TaskType _selectedType = TaskType.shortQuestion;
  LatLng? _selectedLocation;
  final _uuid = const Uuid();

  Future<String> _generateAndSaveQRCode() async {
  final qrKey = 'or!enteering-${_uuid.v4()}';
  final qrData = {
    'code': qrKey,
    'location': _location,
  };

  // Generate QR code image
  final qrPainter = QrPainter(
    data: json.encode(qrData),
    version: QrVersions.auto,
    eyeStyle: const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Colors.black,
    ),
  );

  // Create combined image with QR code and text
  final qrSize = 200.0;
  final imageSize = Size(qrSize, qrSize + 60);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Draw white background
  canvas.drawRect(
    Rect.fromLTWH(0, 0, imageSize.width, imageSize.height),
    Paint()..color = Colors.white,
  );

  // Draw QR code
  canvas.translate(0, 0);
  qrPainter.paint(canvas, Size(qrSize, qrSize));

  // Draw text
  final textPainter = TextPainter(
    text: TextSpan(
      text: '${widget.gameCode} - $_location',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout(maxWidth: imageSize.width);
  textPainter.paint(
    canvas,
    Offset((imageSize.width - textPainter.width) / 2, qrSize + 20),
  );

  // Convert to image
  final picture = recorder.endRecording();
  final img = await picture.toImage(
    imageSize.width.toInt(),
    imageSize.height.toInt(),
  );
  final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
  
  // Save using QRCodeManager
  final filePath = await QRCodeManager.saveQRCode(
    pngBytes!.buffer.asUint8List(),
    widget.gameCode,
    _location,
  );

  // Show success message
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR Code saved to: $filePath'),
        action: SnackBarAction(
          label: 'View All',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const QRCodesScreen(),
              ),
            );
          },
        ),
      ),
    );
  }

  return qrKey;
}

  Future<Task> _createTask() async {
    Map<String, dynamic>? additionalData;

    if (widget.isIndoor) {
      final qrKey = await _generateAndSaveQRCode();
      additionalData = {'qrCode': qrKey};
    } else if (_selectedLocation != null) {
      additionalData = {
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
      };
    }

    return Task(
      id: _uuid.v4(),
      name: _name,
      location: _location,
      points: _points,
      content: _content,
      type: _selectedType,
      additionalData: additionalData ?? {},
      completedBy: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add ${widget.isIndoor ? "Indoor" : "Outdoor"} Task'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Location',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter a location';
                  }
                  return null;
                },
                onSaved: (value) => _location = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Points',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter points';
                  }
                  if (int.tryParse(value!) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) => _points = int.parse(value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<TaskType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Task Type',
                ),
                items: TaskType.values.map((TaskType type) {
                  return DropdownMenuItem<TaskType>(
                    value: type,
                    child: Text(type.toString().split('.').last),
                  );
                }).toList(),
                onChanged: (TaskType? newValue) {
                  setState(() {
                    _selectedType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Task Content',
                ),
                maxLines: 3,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter task content';
                  }
                  return null;
                },
                onSaved: (value) => _content = value!,
              ),
              if (!widget.isIndoor) ...[
                const SizedBox(height: 16),
                const Text('Select Location on Map:'),
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(0, 0),
                      zoom: 2,
                    ),
                    onTap: (LatLng location) {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                    markers: _selectedLocation == null
                        ? {}
                        : {
                            Marker(
                              markerId: const MarkerId('selected'),
                              position: _selectedLocation!,
                            ),
                          },
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (!widget.isIndoor && _selectedLocation == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select a location on the map'),
                        ),
                      );
                      return;
                    }
                    _formKey.currentState!.save();
                    final task = await _createTask();
                    if (mounted) {
                      Navigator.pop(context, task);
                    }
                  }
                },
                child: const Text('Create Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}