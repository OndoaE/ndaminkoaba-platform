import 'package:flutter/material.dart';
import 'nda_page_background.dart';

/// Standard Scaffold behavior with a quiet, fabric-inspired body background.
class NdaScaffold extends Scaffold {
  NdaScaffold({
    super.key,
    Widget? body,
    super.appBar,
    super.backgroundColor,
    super.floatingActionButton,
    super.floatingActionButtonLocation,
    super.bottomNavigationBar,
    super.bottomSheet,
    super.drawer,
    super.endDrawer,
    super.resizeToAvoidBottomInset,
    super.extendBody,
    super.extendBodyBehindAppBar,
    super.persistentFooterButtons,
    super.drawerEnableOpenDragGesture,
    super.onDrawerChanged,
    super.onEndDrawerChanged,
    super.restorationId,
    super.primary,
    super.drawerScrimColor,
  }) : super(body: NdaPageBackground(child: body ?? const SizedBox.expand()));
}
