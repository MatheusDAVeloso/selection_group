part of '../../selection_group.dart';

class _SelectionGroupMulti<T> extends SelectionGroup<T> {
  const _SelectionGroupMulti({
    super.key,
    required this.child,
    this.initialValues,
    this.onItemToggled,
    this.maxSelection,
    this.maxSelectionBehavior = MaxSelectionBehavior.block,
    this.initialItemToFocus,
    this.onFocusedItemChanged,
  }) : super._();

  final Widget child;
  final Set<T>? initialValues;
  final void Function(T item, bool isSelected)? onItemToggled;
  final int? maxSelection;
  final MaxSelectionBehavior maxSelectionBehavior;
  final T? initialItemToFocus;
  final ValueChanged<T?>? onFocusedItemChanged;

  @override
  State<_SelectionGroupMulti<T>> createState() => _SelectionGroupMultiState<T>();
}

class _SelectionGroupMultiState<T> extends State<_SelectionGroupMulti<T>> {
  late final SelectionControllerMulti<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = SelectionControllerMulti<T>(initialValues: widget.initialValues);
    _controller._onItemToggled = widget.onItemToggled;
    _controller._maxSelection = widget.maxSelection;
    _controller._maxSelectionBehavior = widget.maxSelectionBehavior;
    _controller._onFocusedItemChanged = widget.onFocusedItemChanged;

    if (widget.initialItemToFocus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller._focusInitial(widget.initialItemToFocus as T);
      });
    }
  }

  @override
  void didUpdateWidget(_SelectionGroupMulti<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller._onItemToggled = widget.onItemToggled;
    _controller._maxSelection = widget.maxSelection;
    _controller._maxSelectionBehavior = widget.maxSelectionBehavior;
    _controller._onFocusedItemChanged = widget.onFocusedItemChanged;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusTraversalGroup(
      policy: WidgetOrderTraversalPolicy(),
      child: Focus(
        skipTraversal: true,
        onFocusChange: (hasFocus) {
          _controller._setGroupFocused(hasFocus);
        },
        child: _SelectionScope<T>(
          controller: _controller,
          child: widget.child,
        ),
      ),
    );
  }
}
