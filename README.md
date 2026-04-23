# SelectionGroup

A Flutter package for grouping selectable widgets with automatic focus management —
no boilerplate, works on TV, desktop, and mobile.

---

## Why it exists

Flutter has no built-in way to group arbitrary selectable widgets and manage focus
correctly across them. The common problems this package solves:

- **Focus restoration** — when the user re-enters a group, focus returns to the last
  selected item automatically. No `FocusNode` juggling.
- **D-pad / keyboard navigation** — items register themselves into the group; traversal,
  selection on focus, and back-button handling are all wired up internally.
- **WidgetState.selected without a controller** — any widget can react to selected,
  focused, pressed, and hovered states through a unified `WidgetStatesController`,
  without managing it manually.

---

## Building blocks

| Piece | What it does |
|---|---|
| `SelectionGroup.single()` | Single-selection group. Focus auto-restores to the selected item when re-entering. |
| `SelectionGroup.multi()` | Multi-selection group with optional max limit and toggle callbacks. |
| `SelectionItem` | Ready-to-use item. Wraps a `FilledButton` — you only write the visual via `builder`. |
| `SelectionMixin` | For full widget control. Add to your `State` to get `focusNode`, `statesController`, and `select()`. |
| `SelectionRadio` | Themeable radio button driven by `WidgetStateProperty`. |
| `SelectionControllerBase<T>` | The "brain". Manage selection programmatically from BLoCs or ViewModels. |

Start with `SelectionItem` — it covers most cases. Use `SelectionMixin` when you need
to plug selection into an existing widget without restructuring it. Use `SelectionRadio`
when Flutter's built-in `Radio` doesn't expose enough state hooks for your design.

---



---

## Common patterns

These aren't named constructors — they're configuration recipes for `SelectionGroup.single()` and `.multi()`.

### Tab bar / Sidebar
Focus moves to content when a tab is pressed. Selection stays active.

```dart
SelectionGroup<Section>.single(
  initialValue: Section.home,
  selectOnFocus: false,
  maintainSelectionOnFocus: true,
  moveFocusOnPress: TraversalDirection.down, // or right
  child: Row(...),
)
```

### Radio group
Selection only happens on press, not on focus. Useful when the user browses
options before confirming.

```dart
SelectionGroup<String>.single(
  selectOnFocus: false,
  maintainSelectionOnFocus: true,
  child: Column(...),
)
```

### Multi-selection Tag Cloud
Allows selecting up to 3 tags. Oldest is removed when the 4th is selected.

```dart
SelectionGroup<String>.multi(
  maxSelection: 3,
  maxSelectionBehavior: MaxSelectionBehavior.dequeue,
  onItemToggled: (tag, selected) => print('$tag: $selected'),
  child: Wrap(
    children: tags.map((t) => SelectionItem<String>(
      value: t,
      builder: (context, states) => MyChip(
        label: t,
        selected: states.contains(WidgetState.selected),
      ),
    )).toList(),
  ),
)
```

### Swapping pages
Focusing an item automatically scrolls a `PageController`.

```dart
SelectionGroup<int>.single(
  initialValue: 0,
  onFocusedItemChanged: (index) {
    if (index != null) pageController.animateToPage(index, ...);
  },
  child: Row(...),
)
```

### Focus-only group
Manages focus restoration and D-pad traversal without any visual selection state.

```dart
SelectionGroup<String>.single(
  applySelectedState: false,
  child: Column(...),
)
```

---

## External state (BLoC / ViewModel)

Starting with version **0.2.2**, you can instantiate controllers outside the widget
tree. This is the recommended way to handle selection in complex apps.

### 1. Create the controller

```dart
// In your State or ViewModel
final controller = SelectionControllerBase<String>.single(initialValue: 'home');

// Drive it programmatically
controller.select('search');   // selects + requests focus (respects applySelectedState)
controller.focus('search');    // requests focus only, no selection state change

// Check state at any time
final isSelected = controller.isSelected('profile');
```

> [!NOTE]
> `focus()` is safe to call before the widget tree is built. If the item's `FocusNode`
> isn't registered yet, the focus request is automatically deferred to the next frame
> internally — no need to wrap it in `postFrameCallback` manually.
> It also automatically handles scrolling into view for off-screen items.

### 2. Pass it to the group

```dart
SelectionGroup<String>.single(
  controller: controller, // Group will not dispose it
  child: Column(...),
)
```

> [!TIP]
> Since you own the lifecycle, call `dispose()` when your ViewModel or State is
> destroyed — it removes all `FocusNode` listeners and clears internal maps.

```dart
@override
void dispose() {
  controller.dispose();
  super.dispose();
}
```

---

## TV / D-pad example

A sidebar where pressing OK moves focus into the content area. Pressing back from
the content area returns focus to the sidebar.

```dart
Row(
  children: [
    SelectionGroup<Section>.single(
      initialValue: Section.profile,
      selectOnFocus: true,
      moveFocusOnPress: TraversalDirection.right,
      child: Column(
        children: Section.values.map((s) =>
          SelectionItem<Section>(
            value: s,
            builder: (context, states) => SidebarTile(
              label: s.label,
              isSelected: states.contains(WidgetState.selected),
              isFocused: states.contains(WidgetState.focused),
            ),
          ),
        ).toList(),
      ),
    ),
    Expanded(
      child: SelectionItem<Section>(
        value: currentSection,
        moveFocusOnBack: TraversalDirection.left,
        builder: (context, states) => ContentView(section: currentSection),
      ),
    ),
  ],
)
```

> **Always specify the type** (e.g. `<String>`, `<MyEnum>`). Without it, the group
> won't match values correctly and `WidgetState.selected` won't fire.

---

## SelectionGroup.single()

| Parameter | Type | Default | Description |
|---|---|---|---|
| `initialValue` | `T?` | `null` | The selected item on first build. When `applySelectedState` is `false`, determines which item receives initial focus only. Ignored when `controller` is provided. |
| `controller` | `SelectionControllerBase<T>?` | `null` | External controller. When provided, the group does not dispose it. |
| `onFocusedItemChanged` | `ValueChanged<T?>?` | `null` | Called when the focused item changes. `null` when the group loses focus. |
| `applySelectedState` | `bool` | `true` | When `false`, the group manages focus only — `WidgetState.selected` is never applied. |
| `selectOnFocus` | `bool` | `true` | Whether focusing an item also selects it. Ignored when `applySelectedState` is `false`. |
| `maintainSelectionOnFocus` | `bool` | `false` | Whether `WidgetState.selected` stays visible while the group has focus. |
| `focusInitialItem` | `bool` | `false` | Whether the initial item requests focus on the first frame. |
| `moveFocusOnPress` | `TraversalDirection?` | `null` | Moves focus in this direction when an item is pressed. |
| `moveFocusOnBack` | `TraversalDirection?` | `null` | Moves focus in this direction when the **back button** (remotes/controllers) is pressed and a group item has focus. |

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

---

## SelectionGroup.of\<T\>()

Returns the `SelectionControllerBase<T>` from the closest `SelectionGroup<T>` ancestor,
or `null` if there is none:

```dart
// select: applies selection state + requests focus
SelectionGroup.of<String>(context)?.select('home');

// focus: requests focus only, no selection state change
SelectionGroup.of<String>(context)?.focus('home');

final isSelected = SelectionGroup.of<String>(context)?.isSelected('home');
```

> **Always specify the type** when calling `SelectionGroup.of<T>()`.

---

## SelectionItem

Handles focus, press, and `WidgetState` automatically — you only write the visual:

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

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `T?` | required | Identifies this item within the group. Pass `null` to opt out of group selection while keeping focus and press states. |
| `builder` | `Widget Function(BuildContext, Set<WidgetState>)` | required | Builds the visual. Receives the current state set on every change. |
| `onPressed` | `VoidCallback?` | `null` | Additional callback fired on press, after `select()`. |
| `enabled` | `bool` | `true` | When `false`, `WidgetState.disabled` is applied. |
| `autofocus` | `bool` | `false` | Whether this item requests focus when first built. Automatically scrolls into view. |
| `moveFocusOnPress` | `TraversalDirection?` | `null` | Moves focus in this direction when this item is pressed. Overrides the group's `moveFocusOnPress` for this item. |
| `moveFocusOnBack` | `TraversalDirection?` | `null` | Moves focus in this direction when the **back button** (remotes/controllers) is pressed and this item has focus. |
| `externalStates` | `Set<WidgetState>?` | `null` | When set, the item becomes a passive visual driven by these states. See below. |

### externalStates

When `externalStates` is set, the item bypasses its own `focusNode`, `statesController`,
and `FilledButton` entirely (rendered inside `IgnorePointer`). Useful for composing a
radio inside a list item:

```dart
SelectionItem<String>(
  value: 'option1',
  builder: (context, states) {
    return Row(
      children: [
        Text('Option 1'),
        SelectionRadio<String>(
          value: 'option1',
          externalStates: states,
        ),
      ],
    );
  },
)
```

---

## SelectionMixin

Use when you need full control over the widget structure:

```dart
class _MyNavItemState extends State<MyNavItem>
    with SelectionMixin<MyNavItem, String> {

  @override
  String? get selectionValue => widget.value;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      focusNode: focusNode,
      statesController: statesController,
      onPressed: () => select(),
      child: Text(widget.label),
    );
  }
}
```
> **Always specify both types** (e.g. `SelectionMixin<MyWidget, String>`).

---

## SelectionRadio

Flutter's built-in `Radio` doesn't expose its `WidgetStatesController` — reacting to
`focused`, `hovered`, and `selected` simultaneously in a custom design isn't possible
without rewriting the widget. `SelectionRadio` solves that by exposing three layers,
each driven by a `WidgetStateProperty`:

| Parameter | Type | Default | Description |
|---|---|---|---|
| `value` | `T` | required | Identifies this radio within its `SelectionGroup`. |
| `enabled` | `bool` | `true` | When `false`, `WidgetState.disabled` is applied. |
| `overlayColor` | `WidgetStateProperty<Color?>?` | `null` | Outer circle — typically used for focus/hover feedback. |
| `borderColor` | `WidgetStateProperty<Color?>?` | `null` | Border circle. |
| `dotColor` | `WidgetStateProperty<Color?>?` | `null` | Inner dot — typically visible when selected. |
| `externalStates` | `Set<WidgetState>?` | `null` | When set, renders passively using these states. |

```dart
SelectionGroup<String>.single(
  initialValue: 'a',
  selectOnFocus: false,
  child: Row(
    children: [
      SelectionRadio<String>(
        value: 'a',
        overlayColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.focused)
            ? Colors.blue.withValues(alpha: 0.12)
            : Colors.transparent,
        ),
        borderColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? Colors.blue : Colors.grey,
        ),
        dotColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? Colors.blue : Colors.transparent,
        ),
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

Starting with **0.2.4**, it also handles **off-screen items** in `ListView`s. If an item 
is outside the viewport when the group **initially gains focus** (restoration, autofocus, 
or programmatic `focus()`), the controller automatically calls `Scrollable.ensureVisible` 
to scroll it into view. This ensures visibility on entry without overriding natural 
scroll behavior during normal D-pad navigation.

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

The old API still works but is deprecated and frozen.