# selection_group — Roadmap & Technical Debt

This document tracks architectural decisions, known limitations, and planned
refactors for future versions. It is intended for the package author and
contributors, not end users.

---

## Vision

The long-term goal is a package where all entry points are named constructors:

```dart
SelectionGroup.single<T>(...)
SelectionGroup.multi<T>(...)
```

Named constructors are the preferred API convention for this package because
they communicate intent at the call site — when a developer types
`SelectionGroup.`, their IDE immediately shows all available modes. This makes
new features (like multi-selection) discoverable without reading documentation,
and makes it clear that `single` and `multi` are distinct contracts, not the
same widget with flags.

---

## Planned versions

### 0.1.2 — current

- `moveFocusOnPress` parameter on `SelectionGroup`
- `isSelected()` method extracted into `SelectionGroupController`
- `ROADMAP.md` added to repository

### 0.2.0 — next (breaking)

**Named constructor convention**

`SelectionGroup<T>()` is deprecated in favor of `SelectionGroup.single<T>()`.
This is the only breaking change — migration is a single line per usage.

The reason for the rename is not just aesthetics: once `SelectionGroup.multi()`
exists, a bare `SelectionGroup()` would be ambiguous. Establishing the named
constructor convention now avoids confusion later and makes the IDE experience
consistent — developers always pick a mode explicitly.

Migration guide:
```dart
// before
SelectionGroup<int>(...)

// after
SelectionGroup.single<int>(...)
```

**Multi-selection support**

`SelectionGroup.multi<T>()` is introduced with its own contract:

```dart
SelectionGroup.multi<T>(
  initialValue: Set<T>,
  onFocusedItemChanged: ValueChanged<T?>,   // focus is always a single item
  onSelectionChanged: ValueChanged<Set<T>>, // selection is now a Set
  maxSelection: int?,                       // null = unlimited
  maxSelectionBehavior: MaxSelectionBehavior, // block (default) or dequeue
  focusInitialItem: T?,                     // focus a specific item on first frame
  moveFocusOnPress: TraversalDirection?,
)
```

Behavioral differences from `single`:
- Toggle is built-in — pressing a selected item deselects it
- `selectOnFocus` is always false — selection only happens on press
- `maintainSelectionOnFocus` is always true — multiple items stay highlighted
- `focusInitialItem` takes a `T?` instead of a `bool` — you specify which item

`MaxSelectionBehavior` enum:
```dart
enum MaxSelectionBehavior {
  block,    // prevents new selection when limit is reached (default)
  dequeue,  // deselects the oldest item to make room for the new one
}
```

---

## Current limitations (0.1.x)

### 1. Single selection is hardcoded as the base contract

`SelectionGroupController<T>` extends `ValueNotifier<T?>`, which means the
entire package is built around "one selected value or null". Multi-selection
requires a separate controller (`ValueNotifier<Set<T>>`).

`single` and `multi` are intentionally kept as separate contracts — they are
not unified behind a flag. The types are fundamentally different and unifying
them would sacrifice type safety and clarity.

### 2. `SelectionGroupController` is not public

The controller is created internally by `SelectionGroup` and is not exposed as
a parameter. This means users cannot:
- Create a controller outside the widget and pass it in (like `TabController`)
- Control selection programmatically from outside the tree
- Share a controller between two widgets

**Planned:** expose `controller` as an optional parameter on both
`SelectionGroup.single()` and `SelectionGroup.multi()`.

### 3. `SelectionGroupController` is a controller in name, but a kernel in practice

It owns all core logic: registration, focus management, selection state,
`isSelected()`, `_moveFocusOnPress`. It is not a thin state holder — it is the
brain of the package.

The name `SelectionGroupController` may be misleading as the package grows.
A future rename to `SelectionGroupEngine` (or similar) is worth considering
when the architecture stabilizes, to better communicate its role.

For now, the direction is: **all core logic lives in the controller/engine**.
The mixin and widgets delegate to it — they do not make decisions about
selection or focus independently.

### 4. `onFocusedItemChanged` and `onSelectionChanged` are conflated

Currently `onFocusedItemChanged` doubles as the selection callback when
`selectOnFocus: true`. These are two distinct concerns:

- **Focus** — which item the user is currently navigating to. Always `T?`,
  always a single item.
- **Selection** — which item(s) are selected. In `multi` this will be `Set<T>`.

`SelectionGroup.multi()` will introduce `onSelectionChanged: ValueChanged<Set<T>>`
as a separate callback, establishing the correct separation going forward.

---

## Notes

- `single` and `multi` will never be unified into one constructor. They have
  different types, different behavioral defaults, and different mental models.
  Keeping them separate makes the IDE experience better and the API honest.
- `SelectionGroupRadio` is likely unaffected by the multi refactor since radio
  buttons are inherently single-selection by design.
- The mixin (`SelectionGroupItemMixin`) will need to handle both `T?` and
  `Set<T>` controllers — the split into two controller types may require a
  mixin variant or a shared base interface.