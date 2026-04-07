part of '../../selection_group.dart';

/// Defines what happens when [SelectionGroup.multi] reaches its [maxSelection] limit.
enum MaxSelectionBehavior {
  /// Prevents selecting more items until one is deselected.
  block,

  /// Removes the oldest selected item to make room for the new one.
  dequeue,
}