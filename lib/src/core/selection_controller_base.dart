part of '../../selection_group.dart';

/// Contract for selection controllers used internally by [SelectionGroup].
///
/// Accessible via [SelectionGroup.of] when you need to drive selection
/// programmatically from outside the group.
abstract interface class SelectionControllerBase<T> implements Listenable {
  void _register(T value, FocusNode node, WidgetStatesController statesController, BuildContext context);
  void _unregister(T value);

  /// Creates a controller for single selection.
  factory SelectionControllerBase.single({T? initialValue}) = _SelectionControllerSingle<T>;

  /// Creates a controller for multi selection.
  factory SelectionControllerBase.multi({Set<T>? initialValues}) = _SelectionControllerMulti<T>;

  /// Selects the item with the given [value], applying selection state and
  /// requesting focus based on the group's configuration.
  void select(T value);

  /// Requests focus on the item with the given [value] directly, without
  /// changing selection state or checking press conditions.
  ///
  /// If the item is inside a [Scrollable] (like a [ListView]) and currently
  /// off-screen, it is automatically scrolled into view via [Scrollable.ensureVisible].
  ///
  /// If the item's [FocusNode] is not yet registered (e.g. because the widget
  /// tree hasn't been built yet), the focus request is automatically scheduled
  /// for the next frame via [WidgetsBinding.addPostFrameCallback].
  void focus(T value);

  /// Returns whether the item with the given [value] is currently selected.
  bool isSelected(T value);

  /// Releases all resources held by this controller.
  ///
  /// Must be called when the controller is no longer needed and is not owned
  /// by a [SelectionGroup] (i.e. was created externally and passed via the
  /// [controller] parameter).
  void dispose();
}
