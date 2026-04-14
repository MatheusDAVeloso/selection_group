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
/// - [moveFocusOnPress]: moves focus in this direction when the item is pressed.
///   Useful for TV navigation. When null, focus stays on the pressed item.
///
/// - [moveFocusOnBack]: moves focus in this direction when the back button is pressed.
///   Useful for TV navigation. When null, the back button behaves normally.
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
    this.moveFocusOnPress,
    this.moveFocusOnBack,
  });

  final T? value;
  final Widget Function(BuildContext context, Set<WidgetState> states) builder;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool autofocus;
  final Set<WidgetState>? externalStates;
  final TraversalDirection? moveFocusOnPress;
  final TraversalDirection? moveFocusOnBack;

  @override
  State<SelectionItem<T>> createState() => _SelectionItemState<T>();
}

class _SelectionItemState<T> extends State<SelectionItem<T>> with SelectionMixin<SelectionItem<T>, T> {
  @override
  T? get selectionValue => widget.value;

  @override
  Widget build(BuildContext context) {
    if (widget.externalStates != null) {
      return IgnorePointer(
        child: widget.builder(context, widget.externalStates!),
      );
    }

    Widget child = FilledButton(
      autofocus: widget.autofocus,
      focusNode: focusNode,
      onPressed: !widget.enabled
          ? null
          : () {
              select();
              widget.onPressed?.call();
              if (widget.moveFocusOnPress != null) {
                focusNode.focusInDirection(widget.moveFocusOnPress!);
              }
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

    if (widget.moveFocusOnBack != null) {
      child = PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop && focusNode.hasFocus) {
            focusNode.focusInDirection(widget.moveFocusOnBack!);
          }
        },
        child: child,
      );
    }

    return child;
  }
}
