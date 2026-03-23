part of '../selection_group.dart';

/// A ready-to-use selectable item that integrates with [SelectionGroup].
///
/// Wraps a [FilledButton] with a [ValueListenableBuilder], exposing the current
/// [WidgetState] set to a [builder] so the widget can react visually to focus,
/// press, and selection changes without any boilerplate.
///
/// When [value] is provided and the item is inside a [SelectionGroup] of the
/// same type, pressing the item calls [SelectionGroupItemMixin.select]
/// automatically, and [WidgetState.selected] is applied when this item is the
/// group's current selection.
///
/// When [value] is null or there is no [SelectionGroup] ancestor, the item
/// still handles focus and press states normally — it just never receives
/// [WidgetState.selected].
///
/// An optional [style] is merged on top of the base [ButtonStyle], which
/// already zeroes out all visual defaults (overlay, background, splash,
/// padding, minimum size). Use it to override specific properties such as
/// [ButtonStyle.minimumSize] when needed.
///
/// {@tool snippet}
/// ```dart
/// SelectionGroup<String>(
///   initialValue: 'a',
///   child: Row(
///     children: [
///       SelectionGroupItem<String>(
///         value: 'a',
///         builder: (context, states) => Container(
///           color: states.contains(WidgetState.selected) ? Colors.blue : Colors.grey,
///           child: const Text('Option A'),
///         ),
///       ),
///       SelectionGroupItem<String>(
///         value: 'b',
///         builder: (context, states) => Container(
///           color: states.contains(WidgetState.selected) ? Colors.blue : Colors.grey,
///           child: const Text('Option B'),
///         ),
///       ),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
class SelectionGroupItem<T> extends StatefulWidget {
  const SelectionGroupItem({
    super.key,
    required this.value,
    required this.builder,
    this.onPressed,
    this.autofocus = false,
    this.style,
  });

  /// The value that identifies this item within its [SelectionGroup].
  ///
  /// Pass null to use this item outside of a group — focus and press states
  /// still work normally, but [WidgetState.selected] is never applied.
  final T? value;

  /// Called with the current [WidgetState] set on every state change.
  ///
  /// Use the states to drive colors, scale, or any other visual property.
  final Widget Function(BuildContext context, Set<WidgetState> states) builder;

  /// Called after [SelectionGroupItemMixin.select] when the item is pressed.
  ///
  /// When null, the item is still interactive — it just does not trigger any
  /// external callback on press.
  final VoidCallback? onPressed;

  /// Whether this item should request focus when the widget tree is first built.
  final bool autofocus;

  /// An optional [ButtonStyle] merged on top of the base style.
  ///
  /// The base style already sets [ButtonStyle.overlayColor],
  /// [ButtonStyle.backgroundColor], [ButtonStyle.splashFactory],
  /// [ButtonStyle.minimumSize], [ButtonStyle.visualDensity],
  /// [ButtonStyle.tapTargetSize], and [ButtonStyle.padding] to neutral values.
  /// Use this parameter to override only what you need.
  final ButtonStyle? style;

  @override
  State<SelectionGroupItem<T>> createState() => _SelectionGroupItemState<T>();
}

class _SelectionGroupItemState<T> extends State<SelectionGroupItem<T>>
    with SelectionGroupItemMixin<SelectionGroupItem<T>, T> {
  @override
  T? get selectionValue => widget.value;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      autofocus: widget.autofocus,
      focusNode: focusNode,
      onPressed: () {
        select();
        widget.onPressed?.call();
      },
      statesController: statesController,
      style: const ButtonStyle(
        overlayColor: WidgetStatePropertyAll(Colors.transparent),
        backgroundColor: WidgetStatePropertyAll(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        minimumSize: WidgetStatePropertyAll(Size.zero),
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: WidgetStatePropertyAll(EdgeInsets.zero),
      ).merge(widget.style),
      child: ValueListenableBuilder(
        valueListenable: statesController,
        builder: (context, states, _) => widget.builder(context, states),
      ),
    );
  }
}
