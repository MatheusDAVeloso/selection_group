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

They will never be unified into one constructor. The parameters are
fundamentally incompatible — several only make sense in one mode and would be
meaningless noise in the other. Keeping them separate makes the IDE experience
better and the API honest.

---

## Confirmed APIs (0.2.0)

### `SelectionGroup.single<T>`

```dart
SelectionGroup.single<T>(
  initialValue: T?,
  onFocusedItemChanged: ValueChanged<T?>,
  selectOnFocus: bool,
  maintainSelectionOnFocus: bool,
  focusInitialItem: bool,
  moveFocusOnPress: TraversalDirection?,
)
```

### `SelectionGroup.multi<T>`

```dart
SelectionGroup.multi<T>(
  initialValues: Set<T>,
  onItemToggled: void Function(T item, bool isSelected),
  maxSelection: int?,
  maxSelectionBehavior: MaxSelectionBehavior,
  initialItemToFocus: T?,
)
```

Why they cannot be unified — parameters exclusive to each mode:

| Parameter | single | multi |
|---|---|---|
| `initialValue: T?` | ✓ | — |
| `initialValues: Set<T>` | — | ✓ |
| `onFocusedItemChanged` | ✓ | — |
| `onItemToggled` | — | ✓ |
| `selectOnFocus` | ✓ | — |
| `maintainSelectionOnFocus` | ✓ | — |
| `focusInitialItem: bool` | ✓ | — |
| `initialItemToFocus: T?` | — | ✓ |
| `moveFocusOnPress` | ✓ | — |
| `maxSelection` | — | ✓ |
| `maxSelectionBehavior` | — | ✓ |

`MaxSelectionBehavior` enum:
```dart
enum MaxSelectionBehavior {
  block,    // prevents new selection when limit is reached (default)
  dequeue,  // deselects the oldest item to make room for the new one
}
```

---

## Public vs private surface (0.2.0)

**Public:**
- `SelectionGroup.single()`, `SelectionGroup.multi()` — entry points
- `SelectionGroupControllerBase<T>` — shared interface
- `SelectionGroupItemMixin` — depends on the interface, not the concrete controllers
- `SelectionGroupItem`, `SelectionGroupRadio` — ready-to-use widgets

**Private:**
- `SelectionGroupController<T>` — single implementation
- `SelectionGroupMultiController<T>` — multi implementation

The controllers are private because there is no real-world use case that
justifies exposing them — they are strongly coupled to the widget tree and the
mixin. The extension point for custom items is `SelectionGroupItemMixin`, which
depends only on `SelectionGroupControllerBase<T>`. Users can build custom items
without ever knowing which controller is running underneath.

---

## Folder structure (0.2.0)

```
lib/
  selection_group.dart        ← entry point, library declaration
  src/
    single/
      selection_group_single.dart
      selection_group_controller.dart
    multi/
      selection_group_multi.dart
      selection_group_multi_controller.dart
    shared/
      selection_group_controller_base.dart  ← public interface
      selection_group_item_mixin.dart       ← updated to use base interface
      selection_group_item.dart
      selection_group_radio.dart
  deprecated/
    selection_group_legacy.dart  ← SelectionGroup(), marked @Deprecated
    selection_group_controller_legacy.dart
    selection_group_item_mixin_legacy.dart
    selection_group_item_legacy.dart
    selection_group_radio_legacy.dart
```

Everything in `deprecated/` is still a `part of` the same library — the import
path for end users does not change. The folder is internal organization only.

**Compatibility guarantee:** everything in `deprecated/` will remain functional
and will not break. It will simply not receive new features. Users migrate at
their own pace by replacing `SelectionGroup<T>()` with `SelectionGroup.single<T>()`.

---

## Why the mixin and widgets go to deprecated too

The current `SelectionGroupItemMixin` depends directly on
`SelectionGroupController<T>` (the concrete class). The current
`SelectionGroupItem` and `SelectionGroupRadio` depend on the current mixin.
Once the shared interface `SelectionGroupControllerBase<T>` is introduced, a
new mixin is written against the interface — making it work transparently with
both `single` and `multi`. The old mixin cannot be updated without breaking its
contract, so it moves to deprecated alongside the default constructor.

---

## Planned versions

### 0.1.2 — current

- `moveFocusOnPress` parameter on `SelectionGroup`
- `isSelected()` method extracted into `SelectionGroupController`
- `ROADMAP.md` added to repository

### 0.2.0 — next (breaking)

- `SelectionGroup<T>()` deprecated → `SelectionGroup.single<T>()`
- `SelectionGroup.multi<T>()` introduced
- `SelectionGroupControllerBase<T>` interface introduced
- `SelectionGroupItemMixin` rewritten against the interface
- `SelectionGroupItem` and `SelectionGroupRadio` updated
- `MaxSelectionBehavior` enum introduced
- `deprecated/` folder established for 0.1.x legacy code
- Tests rewritten from scratch covering `single`, `multi`, mixin, and widgets

---

## Current limitations (0.1.x)

### 1. Default constructor instead of named constructors

`SelectionGroup<T>()` is the current entry point. Once `multi` is introduced,
a bare `SelectionGroup()` becomes ambiguous. The rename to `SelectionGroup.single()`
establishes the named constructor convention before the package grows further.

### 2. Mixin depends on concrete controller

`SelectionGroupItemMixin` accesses `SelectionGroupController<T>` directly,
including internal fields like `_maintainSelectionOnFocus` and `_groupHasFocus`.
This is resolved in 0.2.0 by introducing `SelectionGroupControllerBase<T>` as
the dependency boundary — the mixin will only know about the interface.

### 3. `SelectionGroupController` is a controller in name, but a kernel in practice

It owns all core logic: registration, focus management, selection state,
`isSelected()`, `_moveFocusOnPress`. It is not a thin state holder.

The name may be misleading as the package grows. A future rename to
`SelectionGroupEngine` is worth considering when the architecture stabilizes.

For now, the direction is: **all core logic lives in the controller/engine**.
The mixin and widgets delegate to it — they do not make decisions independently.

### 4. Tests are outdated

The current tests only cover `initialValue` and `select()` on the default
constructor. They will be fully rewritten in 0.2.0 alongside the new API,
covering `single`, `multi`, the mixin, focus behavior, and ready-to-use widgets.

---

Migration guide for `0.1.x` → `0.2.0`:
```dart
// before
SelectionGroup<int>(...)

// after
SelectionGroup.single<int>(...)
```

This is intentionally the only change required. The rename was designed with
pull requests in mind — a single search and replace across the codebase,
making the diff minimal and review straightforward.