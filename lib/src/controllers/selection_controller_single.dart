part of '../../selection_group.dart';

class _SelectionControllerSingle<T> extends ValueNotifier<T?> implements SelectionControllerBase<T> {
  _SelectionControllerSingle({T? initialValue}) : super(initialValue);

  bool _selectOnFocus = true;
  bool _maintainSelectionOnFocus = false;
  bool _groupHasFocus = false;

  final Map<T, FocusNode> _focusNodes = {};
  final Map<T, VoidCallback> _focusListeners = {};
  final Map<T, WidgetStatesController> _statesControllers = {};

  ValueChanged<T?>? _onFocusedItemChanged;
  TraversalDirection? _moveFocusOnPress;

  @override
  void _register(T value, FocusNode node, WidgetStatesController statesController) {
    _statesControllers[value] = statesController;

    void listener() {
      if (node.hasFocus) {
        if (_selectOnFocus) select(value);
        _onFocusedItemChanged?.call(value);
      }
    }

    _focusNodes[value] = node;
    _focusListeners[value] = listener;
    node.addListener(listener);

    // Atualiza o estado selected ao registrar
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
    final previous = this.value;
    this.value = value;

    if (previous != null && previous != value) {
      final sc = _statesControllers[previous];
      if (sc != null) _updateSelected(previous, sc);
    }
    final sc = _statesControllers[value];
    if (sc != null) _updateSelected(value, sc);

    final node = _focusNodes[value];
    final isPressed = _statesControllers[value]?.value.contains(WidgetState.pressed) ?? false;

    if (isPressed && _moveFocusOnPress != null && node != null) {
      node.focusInDirection(_moveFocusOnPress!);
    } else if (isPressed || !(node?.hasFocus ?? false)) {
      node?.requestFocus();
    }
  }

  @override
  bool isSelected(T value) {
    final suppressOnFocus = !_maintainSelectionOnFocus;
    return !(suppressOnFocus && _groupHasFocus) && this.value == value;
  }

  void _updateSelected(T value, WidgetStatesController statesController) {
    statesController.update(WidgetState.selected, isSelected(value));
  }

  void _setGroupFocused(bool hasFocus) {
    _groupHasFocus = hasFocus;
    if (!hasFocus) _onFocusedItemChanged?.call(null);
    // Reavalia selected de todos os itens pois _groupHasFocus afeta isSelected
    _statesControllers.forEach((k, sc) => _updateSelected(k, sc));
    notifyListeners();
  }

  void _focusSelected() {
    if (value != null) _focusNodes[value]?.requestFocus();
  }
}
