# SelectionGroup

A Flutter package for managing selection and focus state across a group of items — similar to how `TabController` works for tabs, but for any custom selectable widget.

When focus enters the group (e.g. via TV remote or keyboard), it automatically moves to the currently selected item.

## Motivation

Flutter doesn't have a built-in way to group arbitrary selectable widgets and track which one is selected while also managing focus correctly. This is especially noticeable on TV/desktop, where navigating into a sidebar or menu should restore focus to the last selected item.

## Building blocks

The package is designed as composable pieces — use as much or as little as you need:

| Piece | What it does |
|---|---|
| `SelectionGroup` | Provides a `SelectionGroupController` to descendants and manages focus routing |
| `SelectionGroupController` | Tracks the selected value and registered focus nodes |
| `SelectionGroupItemMixin` | Handles registration, unregistration, focus, and `WidgetState.selected` automatically — exposes `focusNode`, `statesController`, and `select()` to your `State` |
| `SelectionGroupItem` | Ready-to-use item: wraps `FilledButton` + `ValueListenableBuilder` so you only write the visual |

You can use `SelectionGroupItem` for most cases. Drop down to `SelectionGroupItemMixin` when you need full control over the widget structure.

> **Note:** `select()` and `WidgetState.selected` only make sense inside a `SelectionGroup` — without one, there's no shared selection state to update. Outside a group, `SelectionGroupItem` still gives you focus and other states via Flutter's native focus engine, but `select()` is a no-op and `WidgetState.selected` is never applied.

## Usage

### 1. Wrap your items with `SelectionGroup`
```dart
SelectionGroup<String>(
  initialValue: 'home',
  child: Column(
    children: [
      MyNavItem(value: 'home', label: 'Home'),
      MyNavItem(value: 'search', label: 'Search'),
      MyNavItem(value: 'profile', label: 'Profile'),
    ],
  ),
)
```

### 2. Use ready-to-use `SelectionGroupItem` — the recommended starting point

Handles focus, press, and visual states. You only write the visual:
```dart
SelectionGroupItem<String>(
  value: 'home',
  builder: (context, states) {
    final isSelected = states.contains(WidgetState.selected);
    final isFocused = states.contains(WidgetState.focused);

    return Container(
      color: isSelected ? Colors.blue : Colors.transparent,
      child: Text(
        'Home',
        style: TextStyle(fontWeight: isFocused ? FontWeight.bold : FontWeight.normal),
      ),
    );
  },
)
```

> Under the hood it uses a `FilledButton` with a neutral style, inheriting Flutter's native focus engine — TV (D-pad), touch, mouse, and keyboard work automatically.

>`SelectionGroupItem` can also be used outside of a `SelectionGroup` — passing `value: null` opts out of group selection while keeping focus and other button states. Useful when you want the same button boilerplate without the selection logic.

### 3. Or use `SelectionGroupItemMixin` for full control

Add the mixin to your `State` when you need complete control over the widget structure:
```dart
class _MyNavItemState extends State<MyNavItem>
    with SelectionGroupItemMixin<MyNavItem, String> {

  @override
  String? get selectionValue => widget.value; // return null to opt out of group selection

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      focusNode: focusNode,               // provided by the mixin
      statesController: statesController, // provided by the mixin — includes WidgetState.selected
      onPressed: () => select(),          // provided by the mixin — no-op outside a group
      child: Text(widget.label),
    );
  }
}
```

The mixin provides:
- `focusNode` — pass to your button so the group can control focus
- `statesController` — automatically updated with `WidgetState.selected` when this item is selected
- `select()` — marks this item as selected in the group on press

### 4. Works with any type, not just String
```dart
enum NavDestination { home, search, profile }

SelectionGroup<NavDestination>(
  initialValue: NavDestination.home,
  child: Column(
    children: [
      MyNavItem(value: NavDestination.home),
      MyNavItem(value: NavDestination.search),
    ],
  ),
)
```

### 5. React when focus changes

Use `onFocusedItemChanged` to react when the focused item changes — useful for switching pages, expanding a sidebar, or triggering animations.

Returns the `value` of the focused item, or `null` when the group loses focus entirely:
```dart
SelectionGroup<String>(
  initialValue: 'home',
  onFocusedItemChanged: (value) {
    if (value != null) {
      // item 'value' gained focus — switch page, expand drawer, etc.
    } else {
      // group lost focus — collapse drawer, etc.
    }
  },
  child: Column(...),
)
```

> By default, `WidgetState.selected` is suppressed on all items while the group has focus, so focused and selected states don't overlap visually. It restores when the group loses focus entirely.

### 6. Control when selection happens

By default, an item is selected as soon as it gains focus — ideal for TV navigation drawers where focus and selection are the same thing.

Set `selectOnFocus: false` when selection should only happen on press — for example, radio buttons:
```dart
SelectionGroup(
  initialValue: 'option1',
  selectOnFocus: false,
  child: Column(
    children: [
      MyRadioItem(value: 'option1'),
      MyRadioItem(value: 'option2'),
    ],
  ),
)
```

> Focus still moves freely between items — only the selection behavior changes.

### 7. Show selected and focused states simultaneously

By default, `WidgetState.selected` is suppressed while the group has focus so the two states don't overlap visually. Set `maintainSelectionOnFocus: true` when you want both states visible at the same time — for example, a list where the selected row should stay highlighted while you navigate:

```dart
SelectionGroup<String>(
  initialValue: 'item1',
  maintainSelectionOnFocus: true,
  child: Column(
    children: [
      MyListItem(value: 'item1'),
      MyListItem(value: 'item2'),
    ],
  ),
)
```

> With this enabled, items can show `WidgetState.selected` and `WidgetState.focused` at the same time. Without it (the default), `WidgetState.selected` is only visible when the group has no focus.

### 8. Focus the initial item automatically

Set `focusInitialItem: true` to have the `initialValue` item request focus on the first frame — useful when a screen opens and focus should land directly on the selected item without any user interaction:

```dart
SelectionGroup<String>(
  initialValue: 'home',
  focusInitialItem: true,
  child: Column(
    children: [
      MyNavItem(value: 'home'),
      MyNavItem(value: 'search'),
    ],
  ),
)
```

> This is a one-time request on mount. After that, focus follows the normal traversal rules.

## How it works

`SelectionGroup` uses an `InheritedWidget` to provide a `SelectionGroupController` to all descendants. When focus enters the group, the controller calls `requestFocus()` on the `FocusNode` of the currently selected item.

Each item registers its `FocusNode` with the controller via `SelectionGroupItemMixin`, which handles registration, cleanup, and `WidgetState.selected` updates automatically.