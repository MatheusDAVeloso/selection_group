part of '../selection_group.dart';

/// A controller that manages the selected value within a [SelectionGroup].
///
/// Similar to [TabController], this is created automatically by [SelectionGroup]
/// and can be accessed via [SelectionGroup.of].
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

  /// Selects the item with the given [value].
  void select(T value) => this.value = value;

  void _focusSelected() {
    if (value != null) _focusNodes[value]?.requestFocus();
  }

  void _setGroupFocused(bool hasFocus) {
    _groupHasFocus = hasFocus;
    if (!hasFocus) _onFocusedItemChanged?.call(null);
    notifyListeners();
  }
}