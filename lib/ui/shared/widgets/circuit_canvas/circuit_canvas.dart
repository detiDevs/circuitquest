import 'package:circuitquest/constants.dart';
import 'package:circuitquest/core/commands/command_controller.dart';
import 'package:circuitquest/core/commands/place_component_command.dart';
import 'package:circuitquest/l10n/app_localizations.dart';
import 'package:circuitquest/state/placed_component.dart';
import 'package:circuitquest/ui/shared/utils/snackbar_utils.dart';
import 'package:circuitquest/ui/shared/widgets/circuit_canvas/grid_painter.dart';
import 'package:circuitquest/ui/shared/widgets/circuit_canvas/placed_component_widget.dart';
import 'package:circuitquest/ui/shared/widgets/circuit_canvas/wire_painter.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../state/sandbox_state.dart';
import '../../../../core/components/component_registry.dart';
import 'package:circuitquest/levels/level.dart';

/// The main canvas where components are placed and connected.
///
/// Features:
/// - Grid background for alignment
/// - Drag and drop component placement
/// - Draggable components for repositioning
/// - Wire drawing between component pins
/// - Interactive component visualization
class CircuitCanvas extends ConsumerStatefulWidget {
  /// Optional level for pre-placing components on the canvas
  final Level? level;

  const CircuitCanvas({super.key, this.level});

  @override
  ConsumerState<CircuitCanvas> createState() => _CircuitCanvasState();
}

class _CircuitCanvasState extends ConsumerState<CircuitCanvas> {
  /// Grid size in pixels
  static const double gridSize = Constants.kGridCellSize;
  // Absolute scene-scale limits (independent from initial fit scale).
  static const double _absoluteMinScale = 0.1;
  static const double _absoluteMaxScale = 8.0;

  // Large boundary so pan constraints do not effectively raise min zoom
  // depending on where the circuit is centered.
  static const double _boundaryMarginSize =
      Constants.kGridSizeInPixels / _absoluteMinScale;

  // Initial viewport fit should not start already at max zoom.
  static const double _maxInitialFitScale = 2.0;

  // Last applied initial fit scale used to derive InteractiveViewer
  // relative min/max limits so absolute zoom range remains constant.
  double _initialFitScale = 1.0;

  /// Current mouse/touch position for wire drawing
  Offset? _currentPointerPosition;

  /// Controller for handling pan and zoom transformations
  final TransformationController _transformationController =
      TransformationController();

  /// Cached reference to sandbox state for cleanup
  late final SandboxState _sandboxState;

  /// Last handled recenter request id from SandboxState.
  int _lastViewportCenterRequestId = -1;

  @override
  void dispose() {
    _transformationController.dispose();
    _sandboxState.reset();
    super.dispose();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void initState() {
    super.initState();
    // Store sandbox state reference for cleanup in dispose
    _sandboxState = ref.read(sandboxProvider);
    // Try to initialize from level after first frame to ensure provider readiness
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sandboxState.initializeFromLevelIfNeeded(
        widget.level,
        gridSize: gridSize,
      );
      _lastViewportCenterRequestId = _sandboxState.viewportCenterRequestId;
      _centerViewportOnCircuit(_sandboxState.placedComponents);
    });
  }

  /// Centers the viewport on the loaded circuit bounds.
  /// If there are no components, centers on the canvas origin.
  void _centerViewportOnCircuit(List<PlacedComponent> components) {
    // Schedule after interactive viewer is laid out
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        final renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final size = renderBox.size;

        final canvasCenter = Offset(
          Constants.kGridSizeInPixels / 2,
          Constants.kGridSizeInPixels / 2,
        );

        Offset targetCenter = canvasCenter;
        double scale = 1.0;

        if (components.isNotEmpty) {
          double minX = components.first.position.dx;
          double minY = components.first.position.dy;
          double maxX = components.first.position.dx + gridSize;
          double maxY = components.first.position.dy + gridSize;

          for (final component in components.skip(1)) {
            minX = component.position.dx < minX ? component.position.dx : minX;
            minY = component.position.dy < minY ? component.position.dy : minY;
            final componentMaxX = component.position.dx + gridSize;
            final componentMaxY = component.position.dy + gridSize;
            maxX = componentMaxX > maxX ? componentMaxX : maxX;
            maxY = componentMaxY > maxY ? componentMaxY : maxY;
          }

          // Add padding so components are not exactly touching viewport edges.
          final padding = gridSize * 2;
          minX -= padding;
          minY -= padding;
          maxX += padding;
          maxY += padding;

          targetCenter = Offset((minX + maxX) / 2, (minY + maxY) / 2);

          final boundsWidth = (maxX - minX).clamp(1.0, double.infinity);
          final boundsHeight = (maxY - minY).clamp(1.0, double.infinity);
          final scaleX = size.width / boundsWidth;
          final scaleY = size.height / boundsHeight;
          scale = scaleX < scaleY ? scaleX : scaleY;
        }
        final clampedScale = scale.clamp(
          _absoluteMinScale,
          _maxInitialFitScale,
        );
        final offsetX = size.width / 2 - (targetCenter.dx * clampedScale);
        final offsetY = size.height / 2 - (targetCenter.dy * clampedScale);
        if ((_initialFitScale - clampedScale).abs() > 0.0001) {
          setState(() {
            _initialFitScale = clampedScale;
          });
        }

        _transformationController.value = Matrix4.identity()
          ..setEntry(0, 0, clampedScale)
          ..setEntry(1, 1, clampedScale)
          ..setTranslationRaw(offsetX, offsetY, 0);
      } catch (e) {
        // Silently ignore if called before render object is ready
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sandboxProvider);

    ref.listen<SandboxState>(sandboxProvider, (_, next) {
      if (next.viewportCenterRequestId == _lastViewportCenterRequestId) {
        return;
      }

      _lastViewportCenterRequestId = next.viewportCenterRequestId;
      _centerViewportOnCircuit(next.placedComponents);
    });

    return DragTarget<ComponentType>(
      onAcceptWithDetails: (details) {
        // Convert global drop offset into viewport coordinates.
        final renderBox = context.findRenderObject() as RenderBox;
        final viewportPosition = renderBox.globalToLocal(details.offset);

        // Convert viewport coordinates to scene (canvas) coordinates,
        // accounting for current pan/zoom/initial centering transform.
        final scenePosition = _transformationController.toScene(
          viewportPosition,
        );
        final gridPosition = _snapToGrid(scenePosition);

        // Create and place the component using command pattern
        final component = details.data.createComponent();
        final sandboxState = ref.read(sandboxProvider);

        final command = PlaceComponentCommand(
          sandboxState,
          details.data.name,
          gridPosition,
          component,
          onError: (_) => SnackBarUtils.showError(context, AppLocalizations.of(context)!.gridCellOccupied)
        );

        // Execute command (this will also add it to undo history if SandboxState supports it)
        CommandController.executeCommand(command);
      },
      builder: (context, candidateData, rejectedData) {
        final effectiveMinScale = (_absoluteMinScale / _initialFitScale).clamp(
          0.01,
          1000.0,
        );
        final effectiveMaxScale = (_absoluteMaxScale / _initialFitScale).clamp(
          0.01,
          1000.0,
        );

        return InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(_boundaryMarginSize),
          minScale: effectiveMinScale,
          maxScale: effectiveMaxScale,
          constrained: false,
          onInteractionEnd: (details) {
            // Cancel wire drawing when zoom/pan interaction ends
            if (state.wireDrawingStart != null) {
              state.cancelWireDrawing();
              setState(() {
                _currentPointerPosition = null;
              });
            }
          },
          child: MouseRegion(
            onHover: (event) {
              // Track mouse position for wire drawing feedback
              if (state.wireDrawingStart != null) {
                setState(() {
                  _currentPointerPosition = event.localPosition;
                });
              }
            },
            child: GestureDetector(
              onTapDown: (details) {
                // Cancel wire drawing only when tapping empty space
                if (state.wireDrawingStart != null) {
                  final hitComponent = _hitTestComponent(
                    state,
                    details.localPosition,
                  );
                  if (hitComponent == null) {
                    state.cancelWireDrawing();
                    setState(() {
                      _currentPointerPosition = null;
                    });
                  }
                }
              },
              child: SizedBox(
                width: Constants.kGridSizeInPixels,
                height: Constants.kGridSizeInPixels,
                child: CustomPaint(
                  painter: GridPainter(),
                  child: Stack(
                    children: [
                      // Draw wires
                      CustomPaint(
                        painter: WirePainter(
                          connections: state.connections,
                          placedComponents: state.placedComponents,
                          wireDrawingStart: state.wireDrawingStart,
                          currentPointerPosition: _currentPointerPosition,
                          cellSize: gridSize,
                          activeComponentIds: state.activeComponentIds,
                        ),
                        child: Container(),
                      ),
                      // Draw components
                      ...state.placedComponents.map((placed) {
                        return PlacedComponentWidget(
                          key: ValueKey(placed.id),
                          placedComponent: placed,
                          gridSize: gridSize,
                          isActive: state.activeComponentIds.contains(
                            placed.id,
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Snaps a position to the nearest grid point.
  Offset _snapToGrid(Offset position) {
    return Offset(
      (position.dx / gridSize).round() * gridSize,
      (position.dy / gridSize).round() * gridSize,
    );
  }

  /// Returns the component under the given local canvas position, if any.
  PlacedComponent? _hitTestComponent(SandboxState state, Offset position) {
    for (final component in state.placedComponents) {
      final rect = Rect.fromLTWH(
        component.position.dx,
        component.position.dy,
        gridSize,
        gridSize,
      );
      if (rect.contains(position)) {
        return component;
      }
    }
    return null;
  }
}


