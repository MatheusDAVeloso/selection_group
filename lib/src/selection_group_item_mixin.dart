part of '../selection_group.dart';

/// A mixin for [State] classes whose widget participates in a [SelectionGroup].
///
/// Handles registration, unregistration, focus, and [WidgetState.selected]
/// automatically — exposes [focusNode], [statesController], and [select] to
/// your [State].
///
/// When used inside a [SelectionGroup], the item registers itself and reacts
/// to selection changes via [WidgetState.selected] on its [statesController].
///
/// When used outside a [SelectionGroup] — or when [selectionValue] is null —
/// the item still provides [focusNode] and [statesController] for focus and
/// press states, but [WidgetState.selected] is never set and [select] is a
/// no-op.
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
  /// The focus node used by this item's interactive widget.
  late final FocusNode focusNode;

  /// The states controller used by this item's interactive widget.
  ///
  /// Automatically updated with [WidgetState.selected] when the item's
  /// [selectionValue] matches the [SelectionGroupController]'s current value.
  ///
  /// Whether [WidgetState.selected] is suppressed while the group has focus
  /// is controlled by [SelectionGroup.maintainSelectionOnFocus].
  late final WidgetStatesController statesController;

  SelectionGroupController<T>? _controller;

  /// The value that identifies this item within its [SelectionGroup].
  ///
  /// When null, the item does not register in any group and
  /// [WidgetState.selected] is never applied.
  T? get selectionValue;

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
    if (selectionValue != null) _controller?._unregister(selectionValue as T);

    _controller = SelectionGroup.of<T>(context);
    if (selectionValue != null) _controller?._register(selectionValue as T, focusNode);
    _controller?.addListener(_handleControllerChange);

    _handleControllerChange();
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleControllerChange);
    if (selectionValue != null) _controller?._unregister(selectionValue as T);
    focusNode.dispose();
    statesController.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    final suppressOnFocus = !(_controller?._maintainSelectionOnFocus ?? false);
    final isSelected = selectionValue != null &&
        !(suppressOnFocus && (_controller?._groupHasFocus ?? false)) &&
        _controller?.value == selectionValue;
    statesController.update(WidgetState.selected, isSelected);
  }

  /// Selects this item in the group.
  ///
  /// No-op when [selectionValue] is null or when there is no [SelectionGroup] ancestor.
  void select() {
    if (selectionValue != null) {
      _controller?.select(selectionValue as T);
    }
  }
}