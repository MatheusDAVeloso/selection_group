# SelectionGroup

A Flutter widget that manages selection and focus state across a group of items — similar to how `TabController` works for tabs, but for any custom selectable widget.

When focus enters the group (e.g. via TV remote or keyboard), it automatically moves to the currently selected item.

## Motivation

Flutter doesn't have a built-in way to group arbitrary selectable widgets and track which one is selected while also managing focus correctly. This is especially noticeable on TV/desktop, where navigating into a sidebar or menu should restore focus to the last selected item.

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

### 2. Add `SelectionGroupItemMixin` to your item's State
```dart
class MyNavItem extends StatefulWidget {
  const MyNavItem({super.key, required this.value, required this.label});

  final String value;
  final String label;

  @override
  State<MyNavItem> createState() => _MyNavItemState();
}

class _MyNavItemState extends State<MyNavItem>
    with SelectionGroupItemMixin<MyNavItem, String> {

  // Identifies this item within the group
  @override
  String get selectionValue => widget.value;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      focusNode: focusNode,           // provided by the mixin
      statesController: statesController, // provided by the mixin
      onPressed: () => select(),      // provided by the mixin
      child: Text(widget.label),
    );
  }
}
```

The mixin provides:
- `focusNode` — pass to your button/widget so the group can control focus
- `statesController` — already includes `WidgetState.selected` when this item is selected
- `select()` — call this on press to mark this item as selected in the group

### 3. Works with any type, not just String
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

### 4. React when focus changes

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

> While the group has focus, `WidgetState.selected` is automatically suppressed on all items. It restores when the group loses focus.

## How it works

`SelectionGroup` uses an `InheritedWidget` to provide a `SelectionGroupController` to all descendants. When focus enters the group, it calls `requestFocus()` on the `FocusNode` of the currently selected item.

Each item registers its `FocusNode` with the controller via `SelectionGroupItemMixin`, which handles registration, cleanup, and `WidgetState.selected` updates automatically.