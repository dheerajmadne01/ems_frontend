import 'package:emp_management/admin/dashboard/controller/admin_dashboard_controller.dart';
import 'package:emp_management/core/app_colors.dart';
import 'package:emp_management/services/location_service.dart';
import 'package:emp_management/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

class SetLocationScreen extends StatefulWidget {
  const SetLocationScreen({Key? key}) : super(key: key);

  @override
  State<SetLocationScreen> createState() => _SetLocationScreenState();
}

class _SetLocationScreenState extends State<SetLocationScreen> {
  final AdminDashboardController _controller = Get.find<AdminDashboardController>();

  double? _latitude;
  double? _longitude;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final Position position = await LocationService().getCurrentPosition();

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      ToastService.showError('Failed to get location: ${e.toString()}');
    }
  }

  Future<void> _useThisLocation() async {
    if (_latitude == null || _longitude == null) {
      ToastService.showError('Location not available');
      return;
    }

    try {
      await _controller.setCompanyLocation(lat: _latitude!, lng: _longitude!);
      ToastService.showSuccess('Office location updated successfully');
      Get.offAllNamed('/admin'); // Navigate back to admin home/dashboard
    } catch (e) {
      ToastService.showError('Failed to save location: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Office Location'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Current Location',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            if (_isLoading) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Getting your current location...'),
            ] else if (_errorMessage.isNotEmpty) ...[
              const Icon(Icons.error_outline, color: Colors.red, size: 50),
              const SizedBox(height: 20),
              Text(
                'Error: $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: const Text('Try Again'),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Latitude:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _latitude?.toStringAsFixed(6) ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Longitude:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _longitude?.toStringAsFixed(6) ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _useThisLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Use This Location',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
