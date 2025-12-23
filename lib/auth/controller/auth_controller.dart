import 'package:emp_management/auth/repo/auth_repository.dart';
import 'package:emp_management/routes/app_routes.dart';
import 'package:emp_management/services/toast_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  AuthController() : _repository = AuthRepository();

  final AuthRepository _repository;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  Future<void> login() async {
    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        ToastService.showError('Please enter email and password');
        return;
      }
      if (!_isValidEmail(email)) {
        ToastService.showError('Enter a valid email address');
        return;
      }

      isLoading.value = true;
      final result = await _repository.login(email: email, password: password);
      isLoading.value = false;

      if (result.user.role == 'admin') {
        Get.offAllNamed(AppRoutes.adminHome);
      } else {
        Get.offAllNamed(AppRoutes.employeeHome);
      }
    } catch (e) {
      isLoading.value = false;
      ToastService.showError('Login failed: ${_getErrorMessage(e)}');
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      ToastService.showError('Logout failed: ${_getErrorMessage(e)}');
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is Exception) {
      final message = error.toString();
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }
      return message;
    }
    return error.toString();
  }

  bool _isValidEmail(String value) {
    final pattern = RegExp(r'^[\w\.-]+@[\w\.-]+\.[A-Za-z]{2,}$');
    return pattern.hasMatch(value);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}


