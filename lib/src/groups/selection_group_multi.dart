part of '../../selection_group.dart';

class _SelectionGroupMulti<T> extends SelectionGroup<T> {
  const _SelectionGroupMulti({
    super.key,
    required this.child,
    this.initialValues,
    this.controller,
    this.onItemToggled,
    this.maxSelection,
    this.maxSelectionBehavior = MaxSelectionBehavior.block,
    this.initialItemToFocus,
    this.onFocusedItemChanged,
  }) : super._();

  final Widget child;
  final Set<T>? initialValues;
  final SelectionControllerBase<T>? controller;
  final void Function(T item, bool isSelected)? onItemToggled;
  final int? maxSelection;
  final MaxSelectionBehavior maxSelectionBehavior;
  final T? initialItemToFocus;
  final ValueChanged<T?>? onFocusedItemChanged;

  @override
  State<_SelectionGroupMulti<T>> createState() => _SelectionGroupMultiState<T>();
}

class _SelectionGroupMultiState<T> extends State<_SelectionGroupMulti<T>> {
  late final _SelectionControllerMulti<T> _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();

    if (widget.controller != null) {
      _controller = widget.controller as _SelectionControllerMulti<T>;
    } else {
      _controller = _SelectionControllerMulti<T>(initialValues: widget.initialValues);
      _ownsController = true;
    }

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
    if (_ownsController) {
      _controller.dispose();
    } else {
      // Controller is external — don't dispose it, but clear callbacks that
      // reference this widget's closures to prevent memory leaks.
      _controller._onFocusedItemChanged = null;
      _controller._onItemToggled = null;
    }
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
