import 'package:flutter/material.dart';

/// Lets non-widget code (the Dio auth interceptor) trigger navigation
/// without a BuildContext, and without api_client.dart importing
/// app_router.dart (which would create a dependency cycle back through the
/// screens the router builds).
final rootNavigatorKey = GlobalKey<NavigatorState>();
