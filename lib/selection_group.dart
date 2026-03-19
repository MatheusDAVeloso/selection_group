import 'package:flutter/material.dart';

/// A controller that manages the selected value within a [SelectionGroup].
///
/// Similar to [TabController], this is created automatically by [SelectionGroup]
/// and can be accessed via [SelectionGroup.of].
class SelectionGroupController<T> extends ValueNotifier<T?> {
  SelectionGroupController({T? initialValue}) : super(initialValue);

  /// When true, all items suppress [WidgetState.selected] regardless of selection.
  bool _groupHasFocus = false;

  /// Stores the [FocusNode] for each registered item.
  final Map<T, FocusNode> _focusNodes = {};

  /// Stores the focus listener for each registered item, used to remove them on [_unregister].
  final Map<T, VoidCallback> _focusListeners = {};
  
  ValueChanged<T?>? _onFocusedItemChanged;

  void _register(T value, FocusNode node) {
    void listener() {
      if (node.hasFocus) {
        select(value);
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

/// A mixin for [State] classes whose widget participates in a [SelectionGroup].
///
/// Handles registration, focus, and [WidgetState.selected] automatically.
///
/// {@tool snippet}
/// ```dart
/// class _MyItemState extends State<MyItem> with SelectionGroupItemMixin<MyItem, String> {
///   @override
///   String get selectionValue => widget.value;
/// }
/// ```
/// {@end-tool}
mixin SelectionGroupItemMixin<W extends StatefulWidget, T> on State<W> {
  late final FocusNode focusNode;
  late final WidgetStatesController statesController;
  SelectionGroupController<T>? _controller;

  /// The value that identifies this item within its [SelectionGroup].
  T get selectionValue;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    statesController = WidgetStatesController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _controller?.removeListener(_handleControllerChange);
    _controller?._unregister(selectionValue);

    _controller = SelectionGroup.of<T>(context);
    _controller?._register(selectionValue, focusNode);
    _controller?.addListener(_handleControllerChange);

    _handleControllerChange();
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleControllerChange);
    _controller?._unregister(selectionValue);
    focusNode.dispose();
    statesController.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    final isSelected = !(_controller?._groupHasFocus ?? false) && _controller?.value == selectionValue;
    statesController.update(WidgetState.selected, isSelected);
  }

  /// Selects this item in the group.
  void select() => _controller?.select(selectionValue);
}

/// A widget that groups selectable items and manages which one is selected.
///
/// Works similarly to [FocusTraversalGroup] — wraps a subtree and provides
/// a [SelectionGroupController] to descendants via [SelectionGroup.of].
///
/// When focus enters the group, it automatically moves to the selected item.
///
/// {@tool snippet}
/// ```dart
/// SelectionGroup<String>(
///   initialValue: 'home',
///   child: Column(
///     children: [
///       MyItem(value: 'home'),
///       MyItem(value: 'search'),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
class SelectionGroup<T> extends StatefulWidget {
  const SelectionGroup({
    super.key,
    required this.child,
    this.initialValue,
    this.onFocusedItemChanged,
  });

  final Widget child;

  /// The value of the item that is selected when the group is first built.
  final T? initialValue;

  /// Called when the focused item changes within the group.
  ///
  /// Returns the [value] of the item that gained focus, or [null] when
  /// the group loses focus entirely.
  final ValueChanged<T?>? onFocusedItemChanged;

  /// Returns the [SelectionGroupController] from the closest [SelectionGroup]
  /// ancestor, or null if there is none.
  static SelectionGroupController<T>? of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SelectionGroupScope<T>>()?.controller;
  }

  @override
  State<SelectionGroup<T>> createState() => _SelectionGroupState<T>();
}

class _SelectionGroupState<T> extends State<SelectionGroup<T>> {
  late final SelectionGroupController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = SelectionGroupController<T>(initialValue: widget.initialValue);
    _controller._onFocusedItemChanged = widget.onFocusedItemChanged;
  }

  @override
  void didUpdateWidget(SelectionGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller._onFocusedItemChanged = widget.onFocusedItemChanged;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      skipTraversal: true,
      onFocusChange: (hasFocus) {
        if (hasFocus) _controller._focusSelected();
        _controller._setGroupFocused(hasFocus);
      },
      child: _SelectionGroupScope<T>(
        controller: _controller,
        child: widget.child,
      ),
    );
  }
}

class _SelectionGroupScope<T> extends InheritedNotifier<SelectionGroupController<T>> {
  const _SelectionGroupScope({
    required SelectionGroupController<T> controller,
    required super.child,
  }) : super(notifier: controller);

  SelectionGroupController<T> get controller => notifier!;
}
