part of '../../selection_group.dart';

/// Groups selectable items and manages which ones are selected.
///
/// Works similarly to [FocusTraversalGroup] — wraps a subtree and provides
/// a [SelectionControllerBase] to descendants via [SelectionGroup.of].
///
/// Use [SelectionGroup.single] for single-selection (nav menus, radio groups)
/// and [SelectionGroup.multi] for multi-selection (chip groups, checklists).
///
/// > **Always specify the type parameter** (e.g. `SelectionGroup<String>.single(...)`).
/// > Without it, the group won't match values correctly and [WidgetState.selected]
/// > won't fire.
///
/// {@tool snippet}
/// ```dart
/// SelectionGroup<String>.single(
///   initialValue: 'home',
///   child: Column(
///     children: [
///       SelectionItem<String>(value: 'home', builder: ...),
///       SelectionItem<String>(value: 'search', builder: ...),
///     ],
///   ),
/// )
/// ```
/// {@end-tool}
class SelectionGroup<T> extends StatefulWidget {
  const SelectionGroup._({super.key});

  @Deprecated('Use SelectionGroup.single() instead.')
  factory SelectionGroup({
    Key? key,
    required Widget child,
    T? initialValue,
    ValueChanged<T?>? onFocusedItemChanged,
    bool selectOnFocus = true,
    bool maintainSelectionOnFocus = false,
    bool focusInitialItem = false,
    TraversalDirection? moveFocusOnPress,
  }) =>
      _SelectionGroupLegacy<T>(
        key: key,
        initialValue: initialValue,
        onFocusedItemChanged: onFocusedItemChanged,
        selectOnFocus: selectOnFocus,
        maintainSelectionOnFocus: maintainSelectionOnFocus,
        focusInitialItem: focusInitialItem,
        moveFocusOnPress: moveFocusOnPress,
        child: child,
      );

  /// Creates a single-selection group.
  ///
  /// When focus enters the group, it automatically moves to the selected item
  /// (scrolling it into view if it is inside a [Scrollable]).
  ///
  /// - [initialValue]: the item that receives selection (and focus) on the first
  ///   build. When [applySelectedState] is `false`, selection is not applied —
  ///   this only determines which item receives initial focus.
  ///   Ignored when [controller] is provided.
  /// - [controller]: optional external controller to drive selection programmatically.
  ///   If provided, [initialValue] is ignored.
  /// - [onFocusedItemChanged]: called when focused item changes. `null` when group loses focus.
  /// - [applySelectedState]: whether pressing an item applies [WidgetState.selected].
  ///   Set to `false` to use the group purely for focus management. Defaults to `true`.
  /// - [selectOnFocus]: whether focusing an item also selects it. Defaults to `true`.
  /// - [maintainSelectionOnFocus]: whether [WidgetState.selected] stays visible while the group has focus.
  /// - [focusInitialItem]: whether the initial item requests focus on the first frame.
  ///   Automatically scrolls the item into view if it is off-screen.
  /// - [moveFocusOnPress]: moves focus in this direction when an item is pressed.
  /// - [moveFocusOnBack]: moves focus in this direction when the back button is pressed.
  ///   Useful for TV navigation. When null, the back button behaves normally.
  factory SelectionGroup.single({
    Key? key,
    required Widget child,
    T? initialValue,
    SelectionControllerBase<T>? controller,
    ValueChanged<T?>? onFocusedItemChanged,
    bool applySelectedState = true,
    bool selectOnFocus = true,
    bool maintainSelectionOnFocus = false,
    bool focusInitialItem = false,
    TraversalDirection? moveFocusOnPress,
    TraversalDirection? moveFocusOnBack,
  }) {
    return _SelectionGroupSingle<T>(
      key: key,
      initialValue: initialValue,
      controller: controller,
      onFocusedItemChanged: onFocusedItemChanged,
      applySelectedState: applySelectedState,
      selectOnFocus: selectOnFocus,
      maintainSelectionOnFocus: maintainSelectionOnFocus,
      focusInitialItem: focusInitialItem,
      moveFocusOnPress: moveFocusOnPress,
      moveFocusOnBack: moveFocusOnBack,
      child: child,
    );
  }

  /// Creates a multi-selection group.
  ///
  /// - [initialValues]: the selected items on first build.
  /// - [controller]: optional external controller to drive selection programmatically.
  ///   If provided, [initialValue] is ignored.
  /// - [onItemToggled]: called when an item is toggled. Second argument is the new selected state.
  /// - [onFocusedItemChanged]: called when focused item changes. `null` when group loses focus.
  /// - [maxSelection]: maximum number of simultaneously selected items.
  /// - [maxSelectionBehavior]: what happens when [maxSelection] is reached.
  /// - [initialItemToFocus]: the item that receives focus on the first frame.
  ///   Automatically scrolls the item into view if it is off-screen.
  factory SelectionGroup.multi({
    Key? key,
    required Widget child,
    Set<T>? initialValues,
    SelectionControllerBase<T>? controller,
    void Function(T item, bool isSelected)? onItemToggled,
    int? maxSelection,
    MaxSelectionBehavior maxSelectionBehavior = MaxSelectionBehavior.block,
    T? initialItemToFocus,
    ValueChanged<T?>? onFocusedItemChanged,
  }) {
    return _SelectionGroupMulti<T>(
      key: key,
      initialValues: initialValues,
      controller: controller,
      onItemToggled: onItemToggled,
      maxSelection: maxSelection,
      maxSelectionBehavior: maxSelectionBehavior,
      initialItemToFocus: initialItemToFocus,
      onFocusedItemChanged: onFocusedItemChanged,
      child: child,
    );
  }

  /// Returns the [SelectionControllerBase] from the closest [SelectionGroup] ancestor,
  /// or null if there is none.
  ///
  /// Use this to drive selection programmatically from a descendant widget.
  /// To control the group from outside the widget tree, pass a [SelectionControllerBase]
  /// directly via the [SelectionGroup.single] or [SelectionGroup.multi] `controller` parameter.
  static SelectionControllerBase<T>? of<T>(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SelectionScope<T>>()?.controller;
  }

  @override
  State<SelectionGroup<T>> createState() => throw UnimplementedError();
}

class _SelectionScope<T> extends InheritedNotifier<SelectionControllerBase<T>> {
  const _SelectionScope({
    required SelectionControllerBase<T> controller,
    required super.child,
  }) : super(notifier: controller);

  SelectionControllerBase<T> get controller => notifier!;
}
