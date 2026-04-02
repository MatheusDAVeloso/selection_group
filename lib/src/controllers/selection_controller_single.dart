part of '../../selection_group.dart';

class SelectionControllerSingle<T> extends ValueNotifier<T?> implements SelectionControllerBase<T> {
  SelectionControllerSingle({T? initialValue})
      : super(
          initialValue,
        );

  bool _selectOnFocus = true;
  bool _maintainSelectionOnFocus = false;
  bool _groupHasFocus = false;

  final Map<T, FocusNode> _focusNodes = {};
  final Map<T, VoidCallback> _focusListeners = {};

  ValueChanged<T?>? _onFocusedItemChanged;
  TraversalDirection? _moveFocusOnPress;

  @override
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

  @override
  void _unregister(T value) {
    final node = _focusNodes.remove(value);
    final listener = _focusListeners.remove(value);

    if (node != null && listener != null) {
      node.removeListener(listener);
    }
  }

  @override
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

  @override
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
