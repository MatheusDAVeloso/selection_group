part of '../../selection_group.dart';

class SelectionControllerMulti<T> extends ValueNotifier<Set<T>> implements SelectionControllerBase<T> {
  SelectionControllerMulti({Set<T>? initialValues})
      : super(
          initialValues ?? {},
        );

  bool _groupHasFocus = false;
  int? _maxSelection;
  MaxSelectionBehavior _maxSelectionBehavior = MaxSelectionBehavior.block;

  final Map<T, FocusNode> _focusNodes = {};
  final Map<T, VoidCallback> _focusListeners = {};

  void Function(T item, bool isSelected)? _onItemToggled;

  @override
  void _register(T value, FocusNode node) {
    void listener() {
      if (node.hasFocus) {
        _onItemToggled?.call(value, isSelected(value));
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
    final selected = Set<T>.from(this.value);

    if (selected.contains(value)) {
      selected.remove(value);
      this.value = selected;
      _onItemToggled?.call(value, false);
    } else {
      if (_maxSelection != null && selected.length >= _maxSelection!) {
        switch (_maxSelectionBehavior) {
          case MaxSelectionBehavior.block:
            return;
          case MaxSelectionBehavior.dequeue:
            selected.remove(selected.first);
        }
      }
      selected.add(value);
      this.value = selected;
      _onItemToggled?.call(value, true);
    }

    // requestFocus ensures focus follows selection on touch platforms,
    // where tapping an item does not move focus automatically.
    _focusNodes[value]?.requestFocus();
  }

  @override
  bool isSelected(T value) => this.value.contains(value);

  void _focusInitial(T value) {
    _focusNodes[value]?.requestFocus();
  }

  void _setGroupFocused(bool hasFocus) {
    _groupHasFocus = hasFocus;
    notifyListeners();
  }
}
