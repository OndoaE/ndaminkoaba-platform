import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_config.dart';
import '../navigation/navigator_key.dart';
import '../services/storage_service.dart';

class ApiClient {
  ApiClient._();

  static final Dio dio = _create();

  static Dio _create() {
    final instance = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    instance.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final isLoginRequest = error.requestOptions.path.contains('/auth/login');

          // A 401 on the login request itself just means "wrong password" —
          // let the login screen show that. Any other 401 means the stored
          // token is stale/invalid, so clear it and bounce to the login
          // screen instead of leaving every screen silently empty.
          if (error.response?.statusCode == 401 && !isLoginRequest) {
            await StorageService.logout();
            final context = rootNavigatorKey.currentContext;
            if (context != null && context.mounted) {
              GoRouter.of(context).go('/login');
            }
          }

          handler.next(error);
        },
      ),
    );

    return instance;
  }
}