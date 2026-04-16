## 0.2.3

- feat(controller): added `focus(T value)` to `SelectionControllerBase` —
  requests focus on the item with the given value directly, without changing
  selection state or checking press conditions (contrast with `select()`, which
  applies selection state and respects `applySelectedState` and press guards).
  If the item's `FocusNode` is not yet registered (e.g. the widget tree hasn't
  built yet), the focus request is automatically deferred to the next frame via
  `WidgetsBinding.addPostFrameCallback` — callers no longer need to wrap in a
  `postFrameCallback` manually.

- feat(controller): added `dispose()` to `SelectionControllerBase` —
  exposes the underlying `ValueNotifier.dispose()` through the public interface,
  allowing external controllers to be properly cleaned up without requiring a
  cast. Removes all registered `FocusNode` listeners and clears internal maps.

  > **Note:** in 0.2.2, `dispose()` was not part of `SelectionControllerBase`.
  > The underlying `ValueNotifier` did have it, but callers had to cast to
  > `ChangeNotifier` to reach it. This was an oversight — fixed here.

- fix(group): `SelectionGroup` now performs safe cleanup of external controllers
  on `dispose`. When a controller was provided externally (`_ownsController = false`),
  the group no longer disposes it (unchanged), but it now nulls out any callbacks
  that reference the widget's closures (`onFocusedItemChanged`, `moveFocusOnPress`,
  `onItemToggled`) to prevent memory leaks from stale widget references.

## 0.2.2

- feat(controller): exposed `SelectionControllerBase.single()` and `SelectionControllerBase.multi()`
  named factories for external instantiation, allowing controllers to be created and managed
  outside of `SelectionGroup`.

- feat: added `controller` parameter to `SelectionGroup.single()` and `SelectionGroup.multi()` —
  pass an externally created controller to take ownership of its lifecycle.
  When provided, the group will not dispose the controller automatically.

- feat: added `moveFocusOnPress` to `SelectionItem` —
  moves focus in the given `TraversalDirection` when an item is pressed.
  Useful for TV navigation.

- feat: added `applySelectedState` parameter to `SelectionGroup.single()` —
  when `false`, the group manages focus only, without applying `WidgetState.selected`
  to any item. `initialValue` still determines which item receives initial focus.

- perf: `SelectionControllerSingle` now caches the focused value internally,
  replacing O(N) focus lookups in `_moveFocusOnBackPressed` with O(1) map lookups.

## 0.2.1

- feat: added `moveFocusOnBack` to both `SelectionGroup.single()` and `SelectionItem` —
  moves focus in the given `TraversalDirection` when the back button is pressed.
  Useful for TV navigation.

## 0.2.0

- feat: added `SelectionGroup.multi()`: multi-selection support with `maxSelection`,
  `MaxSelectionBehavior.block/dequeue`, `onItemToggled`, `initialItemToFocus`,
  and `onFocusedItemChanged`. Still in early testing, expect rough edges.

- feat: added `SelectionGroup.single()` — same behavior as the original `SelectionGroup`,
  now as a named constructor. The default constructor is deprecated in favor of this.

- fix: `select()` now works correctly on all platforms. The fix introduced in 0.1.2
  to make touch selection work correctly had regressed D-pad and keyboard navigation,
  making the package essentially unusable on TV and desktop.

- fix: `moveFocusOnPress` no longer triggers on focus traversal events. Previously,
  navigating with D-pad or keyboard would incorrectly call `focusInDirection`, causing
  focus to escape the group. Now correctly detects press via `WidgetState.pressed`
  from the item's own `statesController`, requiring no manual parameter passing.

- refactor: introduced `SelectionControllerBase` interface and separate single/multi
  controller implementations. Controllers are now internal — not part of the public API.

- refactor: controllers are now the single source of truth for `WidgetState.selected`.
  Previously the mixin polled the controller via `_handleControllerChange` to update
  each item's state. Now the controller updates all `statesController`s directly and
  surgically — only the affected items are updated on each `select()` call.

- refactor: `_register` now receives the item's `WidgetStatesController`, allowing
  the controller to manage focus, selection state, and press detection internally
  without any logic leaking into the mixin or widget layer.

- refactor: `SelectionMixin` is now a pure connector, registers/unregisters the item
  in `didChangeDependencies` and `dispose`, exposes `select()`, and nothing else.
  All logic lives in the controller.

- refactor: introduced `SelectionMixin` and `SelectionItem` as the new widget layer,
  replacing `SelectionGroupItemMixin` and `SelectionGroupItem`.

- deprecated: `SelectionGroup()` default constructor — use `SelectionGroup.single()`.
- deprecated: `SelectionGroupController` — controllers are now internal.
- deprecated: `SelectionGroupItemMixin` — use `SelectionMixin`.
- deprecated: `SelectionGroupItem` — use `SelectionItem`.
- deprecated: `SelectionGroupRadio` — use `SelectionRadio`.

- note: the `moveFocusOnPress` bug in the legacy API will not be backported.
  Migrate to `SelectionGroup.single()` to get the fix.

- note: the `select()` fix introduced in 0.1.2 is broken in the legacy API.
  Either downgrade to 0.1.1 or migrate to `SelectionGroup.single()`.

## 0.1.2

- fix: `select()` now also requests focus for the selected item. This ensures that on touch platforms, tapping an item moves focus correctly, matching the behavior already present on TV and desktop via directional navigation.

- feat: added `moveFocusOnPress` parameter to `SelectionGroup`. When set to a `TraversalDirection`, pressing an item moves focus in that direction instead of keeping it on the selected item. Useful for sidebar/content layouts on TV.

- refactor: extracted `isSelected()` method into `SelectionGroupController`, centralizing the logic that determines whether `WidgetState.selected` should be applied. The mixin no longer accesses `_maintainSelectionOnFocus` or `_groupHasFocus` directly. No breaking changes, just organization. Going forward, `SelectionGroupController` is treated now as the kernel of the package: core selection and focus logic lives there, and other layers (mixin, widgets) delegate to it.

- docs: added `ROADMAP.md` to the repository. It documents current architectural limitations, planned breaking changes for the next major version (multi-selection, controller exposure, type refactor), and the long-term vision for the package. Intended for contributors and to set expectations about the direction of the project.

## 0.1.1

- fix: improved focus behavior in SelectionGroup by wrapping the subtree in a FocusTraversalGroup with WidgetOrderTraversalPolicy. This ensures that internal navigation (like moving between items) follows the widget tree order, preventing the focus from skipping items or accidentally jumping to external headers.

- feat: added `externalStates` to `SelectionGroupItem` and `SelectionGroupRadio`. When provided, the item enters passive display mode — non-interactive, bypasses internal `statesController`, `focusNode`, and `FilledButton` entirely, and renders using the given states directly.

- docs: Added a critical warning about SelectionGroupItemMixin typing. Users must specify the type in the mixin signature (e.g., with `SelectionGroupItemMixin<MyWidget, String>`) to avoid dynamic type mismatching with the SelectionGroup ancestor.

## 0.1.0

The core has proven to be generic and extensible enough to grow. This release begins the widget layer — and marks the start of real-world stress testing in production.

The ideas behind this package are being proposed to Flutter itself in issue [#183904](https://github.com/flutter/flutter/issues/183904), tagged by the Flutter team as `c: new feature`, `c: proposal`, `f: focus`, `framework`, and `team-framework`.

0.1.x will focus on built-in widgets, potential new constructors (multi-selection), and hardening the core against real production usage.

- feat: add `SelectionGroupRadio` — a ready-to-use, fully themeable radio button built on top of `SelectionGroupItem`. All colors (`overlayColor`, `borderColor`, `dotColor`) are driven by `WidgetStateProperty`, defaulting to transparent so the component is ready to be styled from outside.

## 0.0.10
- feat: add `enabled` parameter to `SelectionGroupItem` — when false, disables the button and applies `WidgetState.disabled` automatically, allowing `disabled` and `selected` to coexist independently.
- docs: rewrite `maintainSelectionOnFocus` section to better explain visual behavior on TV/Desktop.
- docs: added a note about explicit typing (e.g., `SelectionGroup<String>`) to ensure correct value comparison and state updates.

## 0.0.9
- docs: add missing CHANGELOG entry for 0.0.8

## 0.0.8

- Add `maintainSelectionOnFocus` — keeps `WidgetState.selected` visible while the group has focus
- Add `focusInitialItem` — requests focus on the initial item on the first frame

## 0.0.7
- feat: add `SelectionGroupItem` — a ready-to-use widget that integrates with SelectionGroup and handles visual states automatically.

- feat: `SelectionGroupItemMixin.selectionValue` is now nullable, allowing `SelectionGroupItem` to be used outside of a group while maintaining focus and states.

- refactor: modularized project structure with a navigation summary using part and part of for better maintainability.

## 0.0.6

- feat: add `selectOnFocus` flag — set to false to select only on press (e.g. radio buttons on TV)

## 0.0.5

- feat: `onFocusChange` replaced by `onFocusedItemChanged` — now returns the focused item value or `null` when the group loses focus
- feat: focused item is automatically marked as selected
- fix: focus listeners are now properly removed on unregister

## 0.0.4

- feat: add `onFocusChange` callback to `SelectionGroup`
- feat: suppress `WidgetState.selected` on all items while group has focus

## 0.0.3

- fix: update LICENSE to MIT
- fix: update tests

## 0.0.2

- fix: update LICENSE

## 0.0.1

- initial release