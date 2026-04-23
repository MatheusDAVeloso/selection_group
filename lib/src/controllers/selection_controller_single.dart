part of '../../selection_group.dart';

class _SelectionControllerSingle<T> extends ValueNotifier<T?> implements SelectionControllerBase<T> {
  _SelectionControllerSingle({T? initialValue}) : super(initialValue);

  bool _applySelectedState = true;
  bool _selectOnFocus = true;
  bool _maintainSelectionOnFocus = false;
  bool _groupHasFocus = false;
  T? _focusedValue;

  final Map<T, FocusNode> _focusNodes = {};
  final Map<T, VoidCallback> _focusListeners = {};
  final Map<T, WidgetStatesController> _statesControllers = {};
  final Map<T, BuildContext> _contexts = {};

  ValueChanged<T?>? _onFocusedItemChanged;
  TraversalDirection? _moveFocusOnPress;

  @override
  void _register(T value, FocusNode node, WidgetStatesController statesController, BuildContext context) {
    _statesControllers[value] = statesController;
    _contexts[value] = context;

    void listener() {
      if (node.hasFocus) {
        final bool isEntryFocus = !_groupHasFocus;
        _focusedValue = value;
        if (_selectOnFocus) select(value);
        _onFocusedItemChanged?.call(value);

        if (isEntryFocus) {
          final ctx = _contexts[value];
          if (ctx != null && ctx.mounted) {
            Scrollable.ensureVisible(ctx, alignment: 0.5, duration: Duration.zero);
          }
        }
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
    _contexts.remove(value);

    final node = _focusNodes.remove(value);
    final listener = _focusListeners.remove(value);

    if (node != null && listener != null) {
      node.removeListener(listener);
    }
  }

  @override
  void select(T value) {
    final node = _focusNodes[value];
    final isPressed = _statesControllers[value]?.value.contains(WidgetState.pressed) ?? false;

    if (isPressed && _moveFocusOnPress != null && node != null) {
      node.focusInDirection(_moveFocusOnPress!);
    } else if (isPressed || !(node?.hasFocus ?? false)) {
      node?.requestFocus();
    }

    if (!_applySelectedState) return;

    final previous = this.value;
    this.value = value;

    if (previous != null && previous != value) {
      final sc = _statesControllers[previous];
      if (sc != null) _updateSelected(previous, sc);
    }
    final sc = _statesControllers[value];
    if (sc != null) _updateSelected(value, sc);
  }

  @override
  bool isSelected(T value) {
    if (!_applySelectedState) return false;
    final suppressOnFocus = !_maintainSelectionOnFocus;
    return !(suppressOnFocus && _groupHasFocus) && this.value == value;
  }

  void _updateSelected(T value, WidgetStatesController statesController) {
    statesController.update(WidgetState.selected, isSelected(value));
  }

  void _setGroupFocused(bool hasFocus) {
    _groupHasFocus = hasFocus;
    if (!hasFocus) {
      _focusedValue = null;
      _onFocusedItemChanged?.call(null);
    }
    _statesControllers.forEach((k, sc) => _updateSelected(k, sc));
    notifyListeners();
  }

  void _focusSelected() {
    if (value != null) _focusNodes[value]?.requestFocus();
  }

  @override
  void focus(T value) {
    final node = _focusNodes[value];
    final ctx = _contexts[value];
    if (node != null) {
      node.requestFocus();
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(ctx, alignment: 0.5, duration: Duration.zero);
      }
    } else {
      // Node not yet registered — schedule for the next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[value]?.requestFocus();
        final lateCtx = _contexts[value];
        if (lateCtx != null && lateCtx.mounted) {
          Scrollable.ensureVisible(lateCtx, alignment: 0.5, duration: Duration.zero);
        }
      });
    }
  }

  @override
  void dispose() {
    for (final entry in _focusNodes.entries) {
      final listener = _focusListeners[entry.key];
      if (listener != null) entry.value.removeListener(listener);
    }
    _focusNodes.clear();
    _focusListeners.clear();
    _statesControllers.clear();
    _contexts.clear();
    _onFocusedItemChanged = null;
    super.dispose();
  }

  bool _moveFocusOnBackPressed(TraversalDirection direction) {
    final node = _focusNodes[_focusedValue];
    if (node == null) return false;
    node.focusInDirection(direction);
    return true;
  }
}
