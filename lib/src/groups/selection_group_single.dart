part of '../../selection_group.dart';

class _SelectionGroupSingle<T> extends SelectionGroup<T> {
  const _SelectionGroupSingle({
    super.key,
    required this.child,
    this.initialValue,
    this.controller,
    this.onFocusedItemChanged,
    this.applySelectedState = true,
    this.selectOnFocus = true,
    this.maintainSelectionOnFocus = false,
    this.focusInitialItem = false,
    this.moveFocusOnPress,
    this.moveFocusOnBack,
  }) : super._();

  final Widget child;
  final T? initialValue;
  final SelectionControllerBase<T>? controller;
  final ValueChanged<T?>? onFocusedItemChanged;
  final bool applySelectedState;
  final bool selectOnFocus;
  final bool maintainSelectionOnFocus;
  final bool focusInitialItem;
  final TraversalDirection? moveFocusOnPress;
  final TraversalDirection? moveFocusOnBack;

  @override
  State<_SelectionGroupSingle<T>> createState() => _SelectionGroupSingleState<T>();
}

class _SelectionGroupSingleState<T> extends State<_SelectionGroupSingle<T>> {
  late final _SelectionControllerSingle<T> _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller as _SelectionControllerSingle<T>;
    } else {
      _controller = _SelectionControllerSingle<T>(initialValue: widget.initialValue);
      _ownsController = true;
    }

    _controller._applySelectedState = widget.applySelectedState;
    _controller._selectOnFocus = widget.applySelectedState && widget.selectOnFocus;
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
    _controller._applySelectedState = widget.applySelectedState;
    _controller._selectOnFocus = widget.applySelectedState && widget.selectOnFocus;
    _controller._maintainSelectionOnFocus = widget.maintainSelectionOnFocus;
    _controller._onFocusedItemChanged = widget.onFocusedItemChanged;
    _controller._moveFocusOnPress = widget.moveFocusOnPress;
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    } else {
      // Controller is external — don't dispose it, but clear callbacks that
      // reference this widget's closures to prevent memory leaks.
      _controller._onFocusedItemChanged = null;
      _controller._moveFocusOnPress = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = FocusTraversalGroup(
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

    if (widget.moveFocusOnBack != null) {
      child = BackButtonListener(
        onBackButtonPressed: () async {
          return _controller._moveFocusOnBackPressed(widget.moveFocusOnBack!);
        },
        child: child,
      );
    }

    return child;
  }
}
