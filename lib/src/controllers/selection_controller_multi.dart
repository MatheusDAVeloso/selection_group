part of '../../selection_group.dart';

class _SelectionControllerMulti<T> extends ValueNotifier<Set<T>> implements SelectionControllerBase<T> {
  _SelectionControllerMulti({Set<T>? initialValues}) : super(initialValues ?? {});

  ValueChanged<T?>? _onFocusedItemChanged;
  int? _maxSelection;
  MaxSelectionBehavior _maxSelectionBehavior = MaxSelectionBehavior.block;
  void Function(T item, bool isSelected)? _onItemToggled;

  final Map<T, FocusNode> _focusNodes = {};
  final Map<T, VoidCallback> _focusListeners = {};
  final Map<T, WidgetStatesController> _statesControllers = {};

  @override
  void _register(T value, FocusNode node, WidgetStatesController statesController) {
    _statesControllers[value] = statesController;

    void listener() {
      if (node.hasFocus) {
        _onFocusedItemChanged?.call(value);
      }
    }

    _focusNodes[value] = node;
    _focusListeners[value] = listener;
    node.addListener(listener);

    _updateSelected(value, statesController);
  }

  @override
  void _unregister(T value) {
    _statesControllers.remove(value);

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
            final dequeued = selected.first;
            selected.remove(dequeued);
            final dequeuedSc = _statesControllers[dequeued];
            if (dequeuedSc != null) _updateSelected(dequeued, dequeuedSc);
        }
      }
      selected.add(value);
      this.value = selected;
      _onItemToggled?.call(value, true);
    }

    _focusNodes[value]?.requestFocus();

    final sc = _statesControllers[value];
    if (sc != null) _updateSelected(value, sc);
  }

  @override
  bool isSelected(T value) => this.value.contains(value);

  void _updateSelected(T value, WidgetStatesController statesController) {
    statesController.update(WidgetState.selected, isSelected(value));
  }

  void _setGroupFocused(bool hasFocus) {
    if (!hasFocus) _onFocusedItemChanged?.call(null);
    _statesControllers.forEach((k, sc) => _updateSelected(k, sc));
    notifyListeners();
  }

  void _focusInitial(T value) {
    _focusNodes[value]?.requestFocus();
  }
}
