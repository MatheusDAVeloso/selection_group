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