part of '../../selection_group.dart';

/// A ready-to-use selectable item that integrates with [SelectionGroup].
///
/// Wraps a [FilledButton] with a [ValueListenableBuilder], exposing the current
/// [WidgetState] set to a [builder] so the widget can react visually to focus,
/// press, and selection changes without any boilerplate.
///
/// Works with both [SelectionGroup.single()] and [SelectionGroup.multi()].
///
/// When [value] is provided and the item is inside a [SelectionGroup] of the
/// same type, pressing the item calls [SelectionMixin.select] automatically,
/// and [WidgetState.selected] is applied when this item is selected.
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
/// SelectionGroup.single<String>(
///   initialValue: 'a',
///   child: Row(
///     children: [
///       SelectionItem<String>(
///         value: 'a',
///         builder: (context, states) => Container(
///           color: states.contains(WidgetState.selected) ? Colors.blue : Colors.grey,
///           child: const Text('Option A'),
///         ),
///       ),
///       SelectionItem<String>(
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
class SelectionItem<T> extends StatefulWidget {
  const SelectionItem({
    super.key,
    required this.value,
    required this.builder,
    this.onPressed,
    this.enabled = true,
    this.autofocus = false,
    this.externalStates,
  });

  final T? value;
  final Widget Function(BuildContext context, Set<WidgetState> states) builder;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool autofocus;
  final Set<WidgetState>? externalStates;

  @override
  State<SelectionItem<T>> createState() => _SelectionItemState<T>();
}

class _SelectionItemState<T> extends State<SelectionItem<T>>
    with SelectionMixin<SelectionItem<T>, T> {
  @override
  T? get selectionValue => widget.value;

  @override
  Widget build(BuildContext context) {
    if (widget.externalStates != null) {
      return IgnorePointer(
        child: widget.builder(context, widget.externalStates!),
      );
    }

    return FilledButton(
      autofocus: widget.autofocus,
      focusNode: focusNode,
      onPressed: !widget.enabled
          ? null
          : () {
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
      ),
      child: ValueListenableBuilder(
        valueListenable: statesController,
        builder: (context, states, _) => widget.builder(context, states),
      ),
    );
  }
}