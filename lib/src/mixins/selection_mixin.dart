part of '../../selection_group.dart';

/// Connects a [StatefulWidget] to the nearest [SelectionGroup] ancestor.
///
/// Add this mixin to your [State] to get [focusNode], [statesController],
/// and [select] wired up automatically — registration, unregistration, and
/// [WidgetState.selected] updates are handled internally.
///
/// Implement [selectionValue] to identify this item within the group.
/// Return `null` to opt out of group selection while keeping focus and
/// press states.
///
/// > **Always specify both type parameters** (e.g. `SelectionMixin<MyWidget, String>`).
/// > Without the value type, the mixin won't find the correct [SelectionGroup] ancestor.
///
/// {@tool snippet}
/// ```dart
/// class _MyItemState extends State<MyItem>
///     with SelectionMixin<MyItem, String> {
///
///   @override
///   String? get selectionValue => widget.value;
///
///   @override
///   Widget build(BuildContext context) {
///     return FilledButton(
///       focusNode: focusNode,                // provided by the mixin
///       statesController: statesController,  // provided by the mixin
///       onPressed: select,                   // provided by the mixin
///       child: Text(widget.label),
///     );
///   }
/// }
/// ```
/// {@end-tool}
mixin SelectionMixin<W extends StatefulWidget, T> on State<W> {
  late final FocusNode focusNode;
  late final WidgetStatesController statesController;
  SelectionControllerBase<T>? _controller;
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

    if (selectionValue != null) _controller?._unregister(selectionValue as T);

    _controller = SelectionGroup.of<T>(context);
    if (selectionValue != null) {
      _controller?._register(selectionValue as T, focusNode, statesController);
    }
  }

  @override
  void dispose() {
    if (selectionValue != null) _controller?._unregister(selectionValue as T);
    focusNode.dispose();
    statesController.dispose();
    super.dispose();
  }

  void select() {
    if (selectionValue != null) {
      _controller?.select(selectionValue as T);
    }
  }
}
