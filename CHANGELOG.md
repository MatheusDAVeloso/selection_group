## 0.2.0

- feat: added `SelectionGroup.multi()` — multi-selection support with `maxSelection`, 
`MaxSelectionBehavior.block/dequeue`, `onItemToggled`, `initialItemToFocus`, 
and `onFocusedItemChanged`.

- feat: added `SelectionGroup.single()` — same behavior as the original `SelectionGroup`, 
now as a named constructor. The default constructor is deprecated in favor of this.

- fix: `moveFocusOnPress` no longer triggers on focus events. Previously, navigating 
with D-pad or keyboard would incorrectly call `focusInDirection`, causing focus to escape 
the group. Now only triggers on press via `fromPress` parameter internally.

- refactor: introduced `SelectionControllerBase` interface, `SelectionControllerSingle`, 
and `SelectionControllerMulti`. Controllers are now internal — not part of the public API.

- refactor: introduced `SelectionMixin` and `SelectionItem` as the new widget layer, 
replacing `SelectionGroupItemMixin` and `SelectionGroupItem`.

- deprecated: `SelectionGroup()` default constructor — use `SelectionGroup.single()`.
- deprecated: `SelectionGroupController` — controllers are now internal.
- deprecated: `SelectionGroupItemMixin` — use `SelectionMixin`.
- deprecated: `SelectionGroupItem` — use `SelectionItem`.
- deprecated: `SelectionGroupRadio` — use `SelectionRadio`.

- note: `moveFocusOnPress` bug exists in the legacy API and will not be backported. 
Migrate to `SelectionGroup.single()` to get the fix.

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