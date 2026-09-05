import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/preview/data_import_page.dart';
import '../features/preview/invoice_gallery_page.dart';
import '../features/preview/invoice_preview_page.dart';
import '../features/preview/thermal_gallery_page.dart';
import '../features/preview/thermal_preview_page.dart';
import '../features/settings/presentation/printer_settings_page.dart';
import '../features/invoice_templates/invoice_template_type.dart';
import '../features/thermal_templates/thermal_template_type.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
      GoRoute(
        path: '/invoices',
        builder: (context, state) => const InvoiceGalleryPage(),
        routes: [
          GoRoute(
            path: 'preview',
            builder: (context, state) {
              final extra = state.uri.queryParameters['template'];
              return InvoicePreviewPage(
                initialTemplate: extra == null
                    ? null
                    : InvoiceTemplateTypeX.parse(extra),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/thermal',
        builder: (context, state) => const ThermalGalleryPage(),
        routes: [
          GoRoute(
            path: 'preview',
            builder: (context, state) {
              final extra = state.uri.queryParameters['template'];
              return ThermalPreviewPage(
                initialTemplate: extra == null
                    ? null
                    : ThermalTemplateTypeX.parse(extra),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/erp',
        builder: (context, state) => const InvoicePreviewPage(
          initialTemplate: InvoiceTemplateType.standard,
          loadErp: true,
        ),
      ),
      GoRoute(
        path: '/pos',
        builder: (context, state) => const ThermalPreviewPage(
          initialTemplate: ThermalTemplateType.thermal,
          loadPos: true,
        ),
      ),
      GoRoute(
        path: '/data',
        builder: (context, state) => const DataImportPage(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const PrinterSettingsPage(),
      ),
    ],
  );
});
