part of '../../selection_group.dart';

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

  factory SelectionGroup.single({
    Key? key,
    required Widget child,
    T? initialValue,
    ValueChanged<T?>? onFocusedItemChanged,
    bool selectOnFocus = true,
    bool maintainSelectionOnFocus = false,
    bool focusInitialItem = false,
    TraversalDirection? moveFocusOnPress,
  }) {
    return _SelectionGroupSingle<T>(
      key: key,
      initialValue: initialValue,
      onFocusedItemChanged: onFocusedItemChanged,
      selectOnFocus: selectOnFocus,
      maintainSelectionOnFocus: maintainSelectionOnFocus,
      focusInitialItem: focusInitialItem,
      moveFocusOnPress: moveFocusOnPress,
      child: child,
    );
  }

  factory SelectionGroup.multi({
    Key? key,
    required Widget child,
    Set<T>? initialValues,
    void Function(T item, bool isSelected)? onItemToggled,
    int? maxSelection,
    MaxSelectionBehavior maxSelectionBehavior = MaxSelectionBehavior.block,
    T? initialItemToFocus,
  }) {
    return _SelectionGroupMulti<T>(
      key: key,
      initialValues: initialValues,
      onItemToggled: onItemToggled,
      maxSelection: maxSelection,
      maxSelectionBehavior: maxSelectionBehavior,
      initialItemToFocus: initialItemToFocus,
      child: child,
    );
  }

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
