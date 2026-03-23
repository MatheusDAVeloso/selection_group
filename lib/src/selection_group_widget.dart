part of '../selection_group.dart';

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
    this.selectOnFocus = true,
  });

  final Widget child;

  /// The value of the item that is selected when the group is first built.
  final T? initialValue;

  /// Called when the focused item changes within the group.
  ///
  /// Returns the [value] of the item that gained focus, or [null] when
  /// the group loses focus entirely.
  final ValueChanged<T?>? onFocusedItemChanged;

  /// Whether the item should be selected when it gains focus.
  ///
  /// Defaults to true. Set to false when selection should only happen
  /// on press — for example, radio buttons on TV.
  final bool selectOnFocus;

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
    _controller._selectOnFocus = widget.selectOnFocus;
  }

  @override
  void didUpdateWidget(SelectionGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller._onFocusedItemChanged = widget.onFocusedItemChanged;
    _controller._selectOnFocus = widget.selectOnFocus;
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