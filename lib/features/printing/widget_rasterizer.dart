import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Rasterizes a widget that is not mounted in the app's widget tree.
///
/// Builds the widget in a private render pipeline sized to [logicalSize], so
/// the result is identical to what the on-screen preview paints, at whatever
/// resolution [pixelRatio] asks for.
class WidgetRasterizer {
  const WidgetRasterizer();

  Future<Uint8List> rasterize({
    required Widget widget,
    required Size logicalSize,
    double pixelRatio = 3.0,
  }) async {
    final boundary = RenderRepaintBoundary();
    final view = WidgetsBinding.instance.platformDispatcher.views.first;

    final renderView = RenderView(
      view: view,
      child: RenderPositionedBox(
        alignment: Alignment.topLeft,
        child: boundary,
      ),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tight(logicalSize),
        physicalConstraints: BoxConstraints.tight(logicalSize * pixelRatio),
        devicePixelRatio: pixelRatio,
      ),
    );

    final pipelineOwner = PipelineOwner()..rootNode = renderView;
    renderView.prepareInitialFrame();

    final buildOwner = BuildOwner(focusManager: FocusManager());
    final element = RenderObjectToWidgetAdapter<RenderBox>(
      container: boundary,
      child: MediaQuery(
        data: MediaQueryData(size: logicalSize, devicePixelRatio: pixelRatio),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: logicalSize.width,
            height: logicalSize.height,
            child: widget,
          ),
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner
      ..buildScope(element)
      ..finalizeTree();

    pipelineOwner
      ..flushLayout()
      ..flushCompositingBits()
      ..flushPaint();

    ui.Image? image;
    try {
      image = await boundary.toImage(pixelRatio: pixelRatio);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    } finally {
      image?.dispose();
      // Detach so the private pipeline and its render objects can be collected.
      element.detachRenderObject();
      pipelineOwner.rootNode = null;
      renderView.dispose();
    }
  }
}
