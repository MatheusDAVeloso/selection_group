part of '../../selection_group.dart';

/// Contract for selection controllers used internally by [SelectionGroup].
///
/// Accessible via [SelectionGroup.of] when you need to drive selection
/// programmatically from outside the group.
abstract interface class SelectionControllerBase<T> implements Listenable {
  void _register(T value, FocusNode node, WidgetStatesController statesController);
  void _unregister(T value);

  /// Selects the item with the given [value].
  void select(T value);

  /// Returns whether the item with the given [value] is currently selected.
  bool isSelected(T value);
}
