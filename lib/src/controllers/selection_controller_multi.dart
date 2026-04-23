part of '../../selection_group.dart';

class _SelectionControllerMulti<T> extends ValueNotifier<Set<T>> implements SelectionControllerBase<T> {
  _SelectionControllerMulti({Set<T>? initialValues}) : super(initialValues ?? {});

  ValueChanged<T?>? _onFocusedItemChanged;
  int? _maxSelection;
  MaxSelectionBehavior _maxSelectionBehavior = MaxSelectionBehavior.block;
  void Function(T item, bool isSelected)? _onItemToggled;
  bool _groupHasFocus = false;

  final Map<T, FocusNode> _focusNodes = {};
  final Map<T, VoidCallback> _focusListeners = {};
  final Map<T, WidgetStatesController> _statesControllers = {};
  final Map<T, BuildContext> _contexts = {};

  @override
  void _register(T value, FocusNode node, WidgetStatesController statesController, BuildContext context) {
    _statesControllers[value] = statesController;
    _contexts[value] = context;

    void listener() {
      if (node.hasFocus) {
        final bool isEntryFocus = !_groupHasFocus;
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
    _groupHasFocus = hasFocus;
    if (!hasFocus) _onFocusedItemChanged?.call(null);
    _statesControllers.forEach((k, sc) => _updateSelected(k, sc));
    notifyListeners();
  }

  void _focusInitial(T value) {
    _focusNodes[value]?.requestFocus();
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
}
