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
| `SelectionGroupItemMixin` | Handles registration, unregistration, focus, and `WidgetState.selected` automatically — exposes `focusNode`, `statesController`, and `select()` to your `State`. Also the right choice when you already have an existing widget and just want to plug in group selection logic without restructuring anything. |
| `SelectionGroupItem` | Ready-to-use item: wraps `FilledButton` + `ValueListenableBuilder` so you only write the visual. Supports `externalStates` for passive display mode. |
| `SelectionGroupRadio` | Ready-to-use radio button, fully themeable via `WidgetStateProperty` colors, built on top of `SelectionGroupItem`. Supports `externalStates` for passive display mode. |

You can use `SelectionGroupItem` for most cases. Drop down to `SelectionGroupItemMixin` when you need full control over the widget structure.

> **Note:** `select()` and `WidgetState.selected` only make sense inside a `SelectionGroup` — without one, there's no shared selection state to update. Outside a group, `SelectionGroupItem` still gives you focus and other states via Flutter's native focus engine, but `select()` is a no-op and `WidgetState.selected` is never applied.

## Usage

### 1. Wrap your items with `SelectionGroup`

> **CRITICAL:** Always specify the type (e.g., `<String>` or `<MyEnum>`). 
> If you omit the type, the group may fail to match the values correctly, 
> and `WidgetState.selected` won't be triggered.

```dart
SelectionGroup<String>( // Specify the type here
  initialValue: 'home',
  child: Column(
    children: [
      MyNavItem(value: 'home', label: 'Home'), // Value must match the group type
      MyNavItem(value: 'search', label: 'Search'), // Value must match the group type
      MyNavItem(value: 'profile', label: 'Profile'), // Value must match the group type
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

> **CRITICAL:** You must specify the type in the mixin signature (e.g., `<MyWidget, String>`). 
> If you omit the type, the mixin defaults to dynamic and will fail, 
> to find the `SelectionGroup<String>` ancestor.

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

`SelectionGroupItemMixin` is also the right choice when you already have an existing widget and just want to plug in group selection logic — without restructuring or wrapping anything. Just add the mixin to your existing `State`, implement `selectionValue`, and the registration, focus, and `WidgetState.selected` wiring happens automatically.

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

By default, `WidgetState.selected` is suppressed while any item in the group has focus. This prevents visual "noise" on TVs where the focused item is usually the one intended to be selected.

```dart
SelectionGroup<String>(
  initialValue: 'item1',
  maintainSelectionOnFocus: true, // Both states can be active at once
  child: Column(
    children: [
      MyListItem(value: 'item1'),
      MyListItem(value: 'item2'),
    ],
  ),
)
```

> **How it works:**
> 
> * **Default (`false`):** When the group is focused, only the focused item shows its state. The selected highlight is hidden until focus leaves the group entirely.
> 
> * **With `maintainSelectionOnFocus: true`:** The selected item stays visually "checked/active" regardless of where the focus pointer is. This is the ideal behavior when you want the currently selected item to remain highlighted even while the user moves the focus to other items in the group.

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

### Using `SelectionGroupRadio`

A ready-to-use radio button. All colors default to transparent — pass `WidgetStateProperty` to style each state:
```dart
SelectionGroup<String>(
  initialValue: 'a',
  selectOnFocus: false,
  child: Row(
    children: [
      SelectionGroupRadio<String>(
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

### Advanced patterns

**Independent groups side by side** — each `SelectionGroup` manages its own selection independently, even with the same values, even one inside the other:
```dart
Row(
  children: [
    SelectionGroup<String>(
      initialValue: '1',
      child: SelectionGroupRadio(value: '1', enabled: false), // selected but disabled
    ),
    SelectionGroup<String>(
      initialValue: '1',
      selectOnFocus: false,
      child: Column(
        children: [
          SelectionGroupRadio(value: '1'),
          SelectionGroupRadio(value: '2'),
          SelectionGroupRadio(value: '3'),
        ],
      ),
    ),
  ],
)
```

> Groups are scoped by the `InheritedWidget` tree — a `SelectionGroupRadio` (or any item) only registers with the nearest `SelectionGroup` ancestor. Two groups with the same values don't interfere with each other.

**Radio button inside a list item** — pass `externalStates` to make the radio a passive indicator that mirrors the list item's own states, without stealing focus or intercepting input:
```dart
SelectionGroupItem<String>(
  value: 'option1',
  builder: (context, states) {
    return Row(
      children: [
        Text('Option 1'),
        SelectionGroupRadio<String>(
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

> When `externalStates` is set, the item bypasses its internal `statesController`, `focusNode`, and `FilledButton` entirely — it becomes a pure visual indicator driven by the parent's states.

## How it works

`SelectionGroup` uses an `InheritedWidget` to provide a `SelectionGroupController` to all descendants. When focus enters the group, the controller calls `requestFocus()` on the `FocusNode` of the currently selected item.

Each item registers its `FocusNode` with the controller via `SelectionGroupItemMixin`, which handles registration, cleanup, and `WidgetState.selected` updates automatically.

`SelectionGroup` also wraps its subtree in a `FocusTraversalGroup` with `WidgetOrderTraversalPolicy`, ensuring focus follows widget tree order internally — so developers don't need to add their own traversal groups or worry about focus leaking outside the group.