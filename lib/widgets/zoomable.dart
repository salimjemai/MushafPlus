import 'package:flutter/material.dart';

/// Zoom state for a book view: pinch / ctrl+wheel zoom plus programmatic
/// zoom in, zoom out and fit. At 1x the child's own drag gestures (page
/// turning) win; once zoomed in, dragging pans the magnified page.
class ZoomController extends ChangeNotifier {
  ZoomController() {
    transformation.addListener(notifyListeners);
  }

  final transformation = TransformationController();
  Size viewport = Size.zero;

  static const minScale = 1.0;
  static const maxScale = 3.0;

  double get scale => transformation.value.getMaxScaleOnAxis();
  bool get zoomed => scale > 1.01;

  void zoomIn() => zoomBy(1.25);
  void zoomOut() => zoomBy(1 / 1.25);
  void reset() => transformation.value = Matrix4.identity();

  /// Scales around the centre of the viewport.
  void zoomBy(double factor) {
    final next = (scale * factor).clamp(minScale, maxScale);
    if (next <= 1.001) {
      reset();
      return;
    }
    final center = Offset(viewport.width / 2, viewport.height / 2);
    final scene = transformation.toScene(center);
    transformation.value = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(next, next, 1, 1)
      ..translateByDouble(-scene.dx, -scene.dy, 0, 1);
  }

  @override
  void dispose() {
    transformation.dispose();
    super.dispose();
  }
}

class Zoomable extends StatelessWidget {
  const Zoomable({super.key, required this.controller, required this.child});
  final ZoomController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        controller.viewport = constraints.biggest;
        return ListenableBuilder(
          listenable: controller,
          builder: (context, _) => InteractiveViewer(
            transformationController: controller.transformation,
            panEnabled: controller.zoomed,
            scaleEnabled: true,
            minScale: ZoomController.minScale,
            maxScale: ZoomController.maxScale,
            boundaryMargin: EdgeInsets.zero,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Zoom in / zoom out / fit entries for an app-bar menu.
List<PopupMenuEntry<String>> zoomMenuItems(BuildContext context, {required String zoomIn, required String zoomOut, required String fit}) => [
      PopupMenuItem(value: 'zoom_in', child: ListTile(leading: const Icon(Icons.zoom_in), title: Text(zoomIn), contentPadding: EdgeInsets.zero)),
      PopupMenuItem(value: 'zoom_out', child: ListTile(leading: const Icon(Icons.zoom_out), title: Text(zoomOut), contentPadding: EdgeInsets.zero)),
      PopupMenuItem(value: 'zoom_fit', child: ListTile(leading: const Icon(Icons.fit_screen_outlined), title: Text(fit), contentPadding: EdgeInsets.zero)),
    ];

/// Applies a zoom menu selection; returns true when it was a zoom action.
bool handleZoomMenu(String value, ZoomController zoom) {
  switch (value) {
    case 'zoom_in':
      zoom.zoomIn();
    case 'zoom_out':
      zoom.zoomOut();
    case 'zoom_fit':
      zoom.reset();
    default:
      return false;
  }
  return true;
}
