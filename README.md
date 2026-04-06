# SelectionGroup

A Flutter package for managing selection and focus state across a group of items —
without boilerplate.

Built for TV, desktop, and mobile. Especially useful where D-pad/keyboard navigation
needs to restore focus to the last selected item when re-entering a group.

---

## Overview

Flutter has no built-in way to group arbitrary selectable widgets and track which one
is selected while also managing focus correctly. `SelectionGroup` fills that gap.

It works similarly to `TabController` for tabs — but for any custom widget, any type,
and any platform.

---

## Quick start

### Single selection
```dart
SelectionGroup<String>.single(
  initialValue: 'home',
  child: Column(
    children: [
      SelectionItem<String>(
        value: 'home',
        builder: (context, states) => MyNavItem(
          label: 'Home',
          isSelected: states.contains(WidgetState.selected),
          isFocused: states.contains(WidgetState.focused),
        ),
      ),
      SelectionItem<String>(
        value: 'search',
        builder: (context, states) => MyNavItem(
          label: 'Search',
          isSelected: states.contains(WidgetState.selected),
          isFocused: states.contains(WidgetState.focused),
        ),
      ),
    ],
  ),
)
```

### Multi selection
```dart
SelectionGroup<String>.multi(
  initialValues: {'flutter', 'dart'},
  onItemToggled: (value, isSelected) {
    print('$value → $isSelected');
  },
  child: Wrap(
    children: [
      SelectionItem<String>(
        value: 'flutter',
        builder: (context, states) => MyChip(
          label: 'Flutter',
          selected: states.contains(WidgetState.selected),
        ),
      ),
      SelectionItem<String>(
        value: 'dart',
        builder: (context, states) => MyChip(
          label: 'Dart',
          selected: states.contains(WidgetState.selected),
        ),
      ),
    ],
  ),
)
```

> **Always specify the type** (e.g. `<String>`, `<MyEnum>`). Without it, the group
> won't match values correctly and `WidgetState.selected` won't fire.

---

## Building blocks

| Piece | What it does |
|---|---|
| `SelectionGroup.single()` | Single-selection group. Focus auto-restores to the selected item when re-entering. |
| `SelectionGroup.multi()` | Multi-selection group with optional max limit and toggle callbacks. |
| `SelectionItem` | Ready-to-use item. Wraps a `FilledButton` — you only write the visual via `builder`. |
| `SelectionMixin` | For full widget control. Add to your `State` to get `focusNode`, `statesController`, and `select()`. |
| `SelectionRadio` | Ready-to-use radio button, fully themeable via `WidgetStateProperty`. |

---

## SelectionGroup.single()

| Parameter | Type | Default | Description |
|---|---|---|---|
| `initialValue` | `T?` | `null` | The selected item on first build. |
| `onFocusedItemChanged` | `ValueChanged<T?>?` | `null` | Called when the focused item changes. `null` when the group loses focus. |
| `selectOnFocus` | `bool` | `true` | Whether focusing an item also selects it. Set to `false` for radio buttons. |
| `maintainSelectionOnFocus` | `bool` | `false` | Whether `WidgetState.selected` stays visible while the group has focus. |
| `focusInitialItem` | `bool` | `false` | Whether the initial item requests focus on the first frame. |
| `moveFocusOnPress` | `TraversalDirection?` | `null` | Moves focus in this direction when an item is pressed, instead of keeping it there. |

### Switching pages
```dart
SelectionGroup<int>.single(
  initialValue: 0,
  onFocusedItemChanged: (value) {
    if (value != null) pageController.jumpToPage(value);
  },
  child: Row(...),
)
```

### Radio button behavior
```dart
SelectionGroup<String>.single(
  initialValue: 'a',
  selectOnFocus: false, // selection only happens on press
  child: Column(...),
)
```

### Sidebar/content layout on TV
```dart
SelectionGroup<Section>.single(
  initialValue: Section.profile,
  moveFocusOnPress: TraversalDirection.right, // after press, focus jumps to content
  child: Column(...),
)
```

### Show selected and focused simultaneously
```dart
SelectionGroup<String>.single(
  initialValue: 'item1',
  maintainSelectionOnFocus: true,
  child: Column(...),
)
```

> By default, `WidgetState.selected` is suppressed while the group has focus so
> focused and selected states don't overlap visually. Set `maintainSelectionOnFocus: true`
> when you want both active at once — for example, a list where the selected item should
> stay highlighted while the user navigates.

---

## SelectionGroup.multi()

| Parameter | Type | Default | Description |
|---|---|---|---|
| `initialValues` | `Set<T>?` | `null` | The selected items on first build. |
| `onItemToggled` | `void Function(T, bool)?` | `null` | Called when an item is toggled. Second argument is the new selected state. |
| `onFocusedItemChanged` | `ValueChanged<T?>?` | `null` | Called when the focused item changes. `null` when the group loses focus. |
| `maxSelection` | `int?` | `null` | Maximum number of simultaneously selected items. |
| `maxSelectionBehavior` | `MaxSelectionBehavior` | `.block` | What happens when `maxSelection` is reached. |
| `initialItemToFocus` | `T?` | `null` | The item that receives focus on the first frame. |

### MaxSelectionBehavior

| Value | Behavior |
|---|---|
| `block` | Prevents selecting more items once the limit is reached. |
| `dequeue` | Removes the oldest selected item to make room for the new one. |
```dart
SelectionGroup<String>.multi(
  maxSelection: 3,
  maxSelectionBehavior: MaxSelectionBehavior.dequeue,
  child: Column(...),
)
```

---

## SelectionItem

The recommended starting point. Handles focus, press, and `WidgetState` automatically —
you only write the visual:
```dart
SelectionItem<String>(
  value: 'home',
  builder: (context, states) {
    return Container(
      color: states.contains(WidgetState.selected) ? Colors.blue : Colors.transparent,
      child: Text('Home'),
    );
  },
)
```

Under the hood it uses a `FilledButton` with a neutral style, inheriting Flutter's native
focus engine — TV (D-pad), touch, mouse, and keyboard all work automatically.

Pass `value: null` to opt out of group selection while keeping focus and press states.
Useful when you want the same button boilerplate without selection logic.

### externalStates

When `externalStates` is set, the item becomes a pure visual indicator driven by an
external state set — it bypasses its own `focusNode`, `statesController`, and
`FilledButton` entirely. Useful for composing a radio inside a list item:
```dart
SelectionItem<String>(
  value: 'option1',
  builder: (context, states) {
    return Row(
      children: [
        Text('Option 1'),
        SelectionRadio<String>(
          value: 'option1',
          externalStates: states, // mirrors the parent — no independent focus or press
          borderColor: ...,
          dotColor: ...,
        ),
      ],
    );
  },
)
```

---

## SelectionMixin

Use when you need full control over the widget structure — for example, when you already
have an existing widget and want to plug in selection logic without restructuring it:
```dart
class _MyNavItemState extends State<MyNavItem>
    with SelectionMixin<MyNavItem, String> {

  @override
  String? get selectionValue => widget.value;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      focusNode: focusNode,               // provided by the mixin
      statesController: statesController, // includes WidgetState.selected automatically
      onPressed: () => select(),          // no-op outside a group
      child: Text(widget.label),
    );
  }
}
```

> **Always specify both types** in the mixin signature (e.g. `<MyWidget, String>`).
> Without the value type, the mixin defaults to `dynamic` and won't find the
> `SelectionGroup<String>` ancestor.

---

## SelectionRadio

Flutter's built-in `Radio` doesn't expose its `WidgetStatesController` — so reacting
to `focused`, `hovered`, and `selected` simultaneously in a custom design isn't possible
without rewriting the widget from scratch. `SelectionRadio` exists to solve that.

It exposes three layers — overlay, border, and dot — each driven by a
`WidgetStateProperty`, so you write the appearance once and all state combinations work
automatically:
```dart
SelectionGroup<String>.single(
  initialValue: 'a',
  selectOnFocus: false,
  child: Row(
    children: [
      SelectionRadio<String>(
        value: 'a',
        overlayColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.focused)
              ? Colors.blue.withValues(alpha: 0.12)
              : Colors.transparent;
        }),
        borderColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.blue
              : Colors.grey;
        }),
        dotColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? Colors.blue
              : Colors.transparent;
        }),
      ),
    ],
  ),
)
```

---

## How it works

`SelectionGroup` uses an `InheritedWidget` to provide a controller to all descendants.
When focus enters the group, the controller calls `requestFocus()` on the `FocusNode`
of the currently selected item — restoring focus exactly where the user left off.

Each item registers its `FocusNode` via `SelectionMixin`, which handles registration,
cleanup, and `WidgetState.selected` updates automatically. Calling `select()` also
requests focus for the item, so touch interactions move focus correctly without any
extra wiring.

`SelectionGroup` wraps its subtree in a `FocusTraversalGroup` with
`WidgetOrderTraversalPolicy`, so focus follows widget tree order internally and doesn't
leak outside the group.

---

## Migration from 0.1.x

| Old | New |
|---|---|
| `SelectionGroup()` | `SelectionGroup.single()` |
| `SelectionGroupItem` | `SelectionItem` |
| `SelectionGroupItemMixin` | `SelectionMixin` |
| `SelectionGroupRadio` | `SelectionRadio` |
| `SelectionGroupController` | Internal — no longer part of the public API |

The old API still works but is deprecated and frozen — it won't receive new features or
bug fixes. Migrate to the new constructors to get multi-selection support and the
`moveFocusOnPress` fix.