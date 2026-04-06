part of '../../selection_group.dart';

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
    final isSelected = selectionValue != null && (_controller?.isSelected(selectionValue as T) ?? false);
    statesController.update(WidgetState.selected, isSelected);
  }

  /// Selects this item in the group.
  ///
  /// No-op when [selectionValue] is null or when there is no [SelectionGroup] ancestor.
  void select({bool fromPress = false}) {
    if (selectionValue != null) {
      _controller?.select(selectionValue as T, fromPress: fromPress);
    }
  }
}
