part of '../selection_group.dart';

/// A radio button that integrates with [SelectionGroup].
///
/// Renders a three-layer circular indicator — overlay, border, and dot —
/// driven entirely by [WidgetStateProperty] colors. All colors default to
/// transparent, so the component is ready to be styled from outside.
///
/// Must be placed inside a [SelectionGroup] for [WidgetState.selected] to work.
///
/// {@tool snippet}
/// ```dart
/// SelectionGroup<String>(
///   initialValue: 'a',
///   selectOnFocus: false,
///   child: Row(
///     children: [
///       SelectionGroupRadio<String>(
///         value: 'a',
///         borderColor: WidgetStateProperty.resolveWith((states) {
///           return states.contains(WidgetState.selected)
///               ? Colors.blue
///               : Colors.grey;
///         }),
///         dotColor: WidgetStateProperty.resolveWith((states) {
///           return states.contains(WidgetState.selected)
///               ? Colors.blue
///               : Colors.transparent;
///         }),
///       ),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
class SelectionGroupRadio<T> extends StatelessWidget {
  const SelectionGroupRadio({
    super.key,
    required this.value,
    this.enabled = true,
    this.overlayColor,
    this.borderColor,
    this.dotColor,
    this.externalStates,
  });

  /// The value that identifies this radio within its [SelectionGroup].
  final T value;

  /// Whether this radio is interactive.
  ///
  /// When false, [WidgetState.disabled] is applied and the radio cannot be pressed.
  /// The radio can still be [WidgetState.selected] while disabled.
  final bool enabled;

  /// Color of the outer overlay circle, typically used for focus and hover feedback.
  ///
  /// Defaults to transparent when null.
  final WidgetStateProperty<Color?>? overlayColor;

  /// Color of the radio border circle.
  ///
  /// Defaults to transparent when null.
  final WidgetStateProperty<Color?>? borderColor;

  /// Color of the inner dot, typically visible when selected.
  ///
  /// Defaults to transparent when null.
  final WidgetStateProperty<Color?>? dotColor;

  /// When provided, delegates directly to [SelectionGroupItem.externalStates].
  ///
  /// The radio enters passive display mode — it becomes non-interactive and
  /// renders using these states instead of its own. See
  /// [SelectionGroupItem.externalStates] for full details.
  final Set<WidgetState>? externalStates;

  @override
  Widget build(BuildContext context) {
    return SelectionGroupItem<T>(
      value: value,
      enabled: enabled,
      externalStates: externalStates,
      builder: (context, states) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: overlayColor?.resolve(states) ?? Colors.transparent,
          ),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor?.resolve(states) ?? Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor?.resolve(states) ?? Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
