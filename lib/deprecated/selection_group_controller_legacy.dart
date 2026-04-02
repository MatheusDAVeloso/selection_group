part of '../selection_group.dart';

/// A controller that manages the selected value within a [SelectionGroup].
///
/// Similar to [TabController], this is created automatically by [SelectionGroup]
/// and can be accessed via [SelectionGroup.of].
@Deprecated(
  'Use SelectionGroup.single() or SelectionGroup.multi() instead. '
  'Controllers are internal in 0.2.0 — see SelectionController for the public interface.',
)
class SelectionGroupController<T> extends ValueNotifier<T?> {
  SelectionGroupController({T? initialValue}) : super(initialValue);

  bool _selectOnFocus = true;
  bool _maintainSelectionOnFocus = false;

  /// When true, all items suppress [WidgetState.selected] while the group has focus.
  bool _groupHasFocus = false;

  /// Stores the [FocusNode] for each registered item.
  final Map<T, FocusNode> _focusNodes = {};

  /// Stores the focus listener for each registered item, used to remove them on [_unregister].
  final Map<T, VoidCallback> _focusListeners = {};

  ValueChanged<T?>? _onFocusedItemChanged;
  TraversalDirection? _moveFocusOnPress;

  void _register(T value, FocusNode node) {
    void listener() {
      if (node.hasFocus) {
        if (_selectOnFocus) select(value);
        _onFocusedItemChanged?.call(value);
      }
    }

    _focusNodes[value] = node;
    _focusListeners[value] = listener;
    node.addListener(listener);
  }

  void _unregister(T value) {
    final node = _focusNodes[value];
    final listener = _focusListeners[value];

    if (node != null && listener != null) {
      node.removeListener(listener);
    }

    _focusNodes.remove(value);
    _focusListeners.remove(value);
  }

  /// Selects the item with the given [value] and moves focus accordingly.
  ///
  /// If [_moveFocusOnPress] is set, moves focus in that direction from the
  /// selected item's [FocusNode] instead of keeping focus on it. Useful for
  /// sidebar/content layouts where pressing a nav item should move focus to
  /// the content area.
  ///
  /// If [_moveFocusOnPress] is null, focus moves to the selected item's
  /// [FocusNode]. If it is already focused, this is a no-op for focus.
  void select(T value) {
    this.value = value;

    final node = _focusNodes[value];
    if (_moveFocusOnPress != null && node != null) {
      node.focusInDirection(_moveFocusOnPress!);
    } else {
      // requestFocus ensures focus follows selection on touch platforms,
      // where tapping an item does not move focus automatically.
      node?.requestFocus();
    }
  }

  /// Returns whether the item with the given [value] should display
  /// [WidgetState.selected].
  ///
  /// Takes [maintainSelectionOnFocus] into account — when false, selected
  /// is suppressed while the group has focus so focused and selected states
  /// don't overlap visually.
  bool isSelected(T value) {
    final suppressOnFocus = !_maintainSelectionOnFocus;
    return !(suppressOnFocus && _groupHasFocus) && this.value == value;
  }

  void _focusSelected() {
    if (value != null) _focusNodes[value]?.requestFocus();
  }

  void _setGroupFocused(bool hasFocus) {
    _groupHasFocus = hasFocus;
    if (!hasFocus) _onFocusedItemChanged?.call(null);
    notifyListeners();
  }
}
