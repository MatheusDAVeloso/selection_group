part of '../../selection_group.dart';

class _SelectionGroupSingle<T> extends SelectionGroup<T> {
  const _SelectionGroupSingle({
    super.key,
    required this.child,
    this.initialValue,
    this.onFocusedItemChanged,
    this.selectOnFocus = true,
    this.maintainSelectionOnFocus = false,
    this.focusInitialItem = false,
    this.moveFocusOnPress,
  }) : super._();

  final Widget child;
  final T? initialValue;
  final ValueChanged<T?>? onFocusedItemChanged;
  final bool selectOnFocus;
  final bool maintainSelectionOnFocus;
  final bool focusInitialItem;
  final TraversalDirection? moveFocusOnPress;

  @override
  State<_SelectionGroupSingle<T>> createState() => _SelectionGroupSingleState<T>();
}

class _SelectionGroupSingleState<T> extends State<_SelectionGroupSingle<T>> {
  late final _SelectionControllerSingle<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = _SelectionControllerSingle<T>(initialValue: widget.initialValue);
    _controller._selectOnFocus = widget.selectOnFocus;
    _controller._maintainSelectionOnFocus = widget.maintainSelectionOnFocus;
    _controller._onFocusedItemChanged = widget.onFocusedItemChanged;
    _controller._moveFocusOnPress = widget.moveFocusOnPress;

    if (widget.focusInitialItem) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller._focusSelected();
      });
    }
  }

  @override
  void didUpdateWidget(_SelectionGroupSingle<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller._selectOnFocus = widget.selectOnFocus;
    _controller._maintainSelectionOnFocus = widget.maintainSelectionOnFocus;
    _controller._onFocusedItemChanged = widget.onFocusedItemChanged;
    _controller._moveFocusOnPress = widget.moveFocusOnPress;
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
          if (hasFocus) _controller._focusSelected();
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
