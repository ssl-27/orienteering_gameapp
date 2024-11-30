import 'dart:convert';
import 'dart:io';
import 'package:pedometer/pedometer.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:orienteering/models/task_type.dart';
import 'package:orienteering/screens/qr_scanner_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../models/task.dart';
import '../service/task.dart';
import 'leader_board_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final String userId;
  final bool isIndoor;
  final String gameCode;

  const TaskDetailScreen({
    Key? key,
    required this.task,
    required this.gameCode,
    required this.userId,
    required this.isIndoor,
  }) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  // Controllers for form inputs
  final _formKey = GlobalKey<FormState>();
  final _contentController = TextEditingController();

  // Service instance for API calls
  late final TaskService _taskService;

  // State variables to track verification status
  bool _isLocationVerified = false;
  bool _isQrCodeVerified = false;
  bool _isSubmitting = false;
  int _stepCount = 0;
  XFile? _imageFile;

  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _pedestrianStatus = 'unknown';
  bool _isCountingSteps = false;

  @override
  void initState() {
    super.initState();
    _taskService = TaskService(gameCode: widget.gameCode);
    //_initStepCounter();
  }

  void _initStepCounter() {
    _stepCountStream = Pedometer.stepCountStream;
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
    _pedestrianStatusStream.listen(_onPedestrianStatusChanged).onError(_onPedestrianStatusError);
  }


  void _onStepCount(StepCount event) {
    if(_isCountingSteps) {
      setState(() {
        _stepCount = event.steps;
      });
    }
  }

  void _onStepCountError(error) {
    print('Step Count Error: $error');
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _pedestrianStatus = event.status;
    });
  }

  void _onPedestrianStatusError(error) {
    print('Pedestrian Status Error: $error');
  }

  void _toggleStepCounter() {
    setState(() {
      _isCountingSteps = !_isCountingSteps;
    });
  }

  // Handle QR code scanning for indoor tasks
  Future<void> _scanQrCode() async {
    try {
      // Navigate to QR scanner screen and wait for result
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => QRScannerScreen(),
        ),
      );

      // Verify scanned QR code matches expected value
      if (result == widget.task.additionalData['qrCode']) {
        setState(() {
          _isQrCodeVerified = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('QR Code verified successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid QR Code. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error scanning QR code')),
      );
    }
  }

  // Check user's location for outdoor tasks
  Future<void> _verifyLocation() async {
    try {
      // Request location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      // Get current location
      Position position = await Geolocator.getCurrentPosition();

      // Calculate distance between current location and target
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        widget.task.additionalData['latitude']!,
        widget.task.additionalData['longitude']!,
      );

      // Verify if user is within allowed distance
      if (distance <= 50.0) {
        setState(() {
          _isLocationVerified = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location verified successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are not at the correct location')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error verifying location: $e')),
      );
    }
  }

  Future<void>_pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    setState(() {
      _imageFile = image;
    });
  }

  // Submit completed task to server
  Future<void> _submitTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Prepare task data
      Map<String, dynamic> taskData = {
        'userId': widget.userId,
        'taskType': widget.task.type.name,
        'gameCode': widget.gameCode,
        'taskId': widget.task.taskId,
        'content': _contentController.text,
        if (widget.isIndoor)
          'qrCodeVerified': _isQrCodeVerified,
        if (!widget.isIndoor)
          'locationVerified': _isLocationVerified,
        if (widget.task.type == TaskType.photoTaking)
          'image': _imageFile?.path,
        if (widget.task.type == TaskType.stepCounter)
          'stepCount': _stepCount,
      };

      if (widget.task.type == TaskType.photoTaking && _imageFile != null) {
        String base64Image = base64Encode(File(_imageFile!.path).readAsBytesSync());
        taskData['image'] = base64Image;
      }

      // Submit to server
      bool success = await _taskService.submitTask(widget.task.taskId, taskData, widget.userId);

      if (success) {
        Navigator.pop(context, true); // Return success to previous screen
      } else {
        throw Exception('Failed to submit task');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting task: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Detail - Game ${widget.gameCode}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task header
              Row(
                children: [
                  Icon(
                    widget.task.completedBy.contains(widget.userId)
                        ? Icons.check_circle
                        : Icons.circle_outlined,
                    color: widget.task.completedBy.contains(widget.userId) ? Colors.green : Colors.grey,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.task.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Task type indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: widget.isIndoor
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  widget.isIndoor ? 'Indoor Task' : 'Outdoor Task',
                  style: TextStyle(
                    color: widget.isIndoor
                        ? Colors.blue
                        : Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Task description
              Text(
                'Description',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.task.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),

              // Verification section
              if (!widget.task.completedBy.contains(widget.userId)) ...[
                // Indoor task: QR code verification
                if (widget.isIndoor) ...[
                  ElevatedButton.icon(
                    onPressed: _isQrCodeVerified ? null : _scanQrCode,
                    icon: Icon(_isQrCodeVerified
                        ? Icons.check_circle
                        : Icons.qr_code_scanner),
                    label: Text(_isQrCodeVerified
                        ? 'QR Code Verified'
                        : 'Scan QR Code'),
                  ),
                ],

                // Outdoor task: Location verification
                if (!widget.isIndoor) ...[
                  ElevatedButton.icon(
                    onPressed: _isLocationVerified ? null : _verifyLocation,
                    icon: Icon(_isLocationVerified
                        ? Icons.check_circle
                        : Icons.location_on),
                    label: Text(_isLocationVerified
                        ? 'Location Verified'
                        : 'Verify Location'),
                  ),
                ],
                const SizedBox(height: 24),

                if (widget.task.type == TaskType.shortQuestion) ...[
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Answer',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your answer';
                      }
                      return null;
                    },
                  ),
                ],
                if (widget.task.type == TaskType.photoTaking) ...[
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                  ),
                  if (_imageFile != null)
                    Image.file(File(_imageFile!.path)),
                ],
                if (widget.task.type == TaskType.stepCounter) ...[
                  Text('Steps taken: $_stepCount'),
                  Text('Status: $_pedestrianStatus'),
                  ElevatedButton.icon(
                    onPressed: _toggleStepCounter,
                    icon: Icon(_isCountingSteps
                        ? Icons.pause
                        : Icons.play_arrow),
                    label: Text(_isCountingSteps
                        ? 'Pause Step Counter'
                        : 'Start Step Counter'),
                  ),
                ],
                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (widget.isIndoor &&
                        _isQrCodeVerified ||
                        !widget.isIndoor &&
                            _isLocationVerified)
                        && !_isSubmitting
                        ? _submitTask
                        : null,
                    child: _isSubmitting
                        ? const CircularProgressIndicator()
                        : const Text('Submit Task'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}