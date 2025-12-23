
import 'package:emp_management/routes/app_pages.dart';
import 'package:emp_management/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Employee Management System',
      debugShowCheckedModeBanner: false,
      initialRoute: _resolveInitialRoute(),
      getPages: AppPages.pages,
      builder: (context, child) {
        final media = MediaQuery.of(context);
        // Clamp text scaling to reduce overflow across devices.
        final scaledMedia = media.copyWith(
          textScaler: media.textScaler.clamp(
            minScaleFactor: 0.85,
            maxScaleFactor: 1.15,
          ),
        );
        return MediaQuery(
          data: scaledMedia,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

String _resolveInitialRoute() {
  final box = GetStorage();
  final token = box.read<String>('auth_access_token') ?? box.read<String>('auth_token');
  final role = box.read<String>('auth_role');

  if (token != null && token.isNotEmpty) {
    if (role == 'admin') return AppRoutes.adminHome;
    if (role == 'employee') return AppRoutes.employeeHome;
  }
  return AppRoutes.login;
}

