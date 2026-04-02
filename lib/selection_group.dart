/// ┌──────────────────────────────────────────────────────────────────────────┐
/// │                          SELECTION GROUP                                 │
/// │                Advanced Focus & Selection Management                     │
/// ├──────────────────────────────────────────────────────────────────────────┤
/// │  Hold Ctrl + LMB to navigate through components                          │
/// │                                                                          │
/// │  Author: MatheusDAVeloso                                                 │
/// │  Package Version: 0.1.2                                                  │
/// │  Repo: https://github.com/MatheusDAVeloso/selection_group                │
/// ├──────────────────────────────────────────────────────────────────────────┤
/// │  ERAS                                                                    │
/// │                                                                          │
/// │  Era 0 (0.0.x) — Core                                                    │
/// │    Idealization, architecture, and initial bug fixes.                    │
/// │    SelectionGroup, SelectionGroupController, SelectionGroupItemMixin,    │
/// │    and SelectionGroupItem established and stabilized.                    │
/// │                                                                          │
/// │  Era 1 (0.1.x) — Widget Layer                                            │
/// │    Expanding the arsenal of ready-to-use widgets.                        │
/// │    Potential new constructors (multi-selection).                         │
/// │    Real-world stress testing in production.                              │
/// |                                                                          |
/// │  Era Refactor — Breaking Changes                                         │
/// │    Full architectural refactor. ValueNotifier<T?> → ValueNotifier<Set<T>>│
/// │    Single selection becomes a constrained case of multi (maxSelection:1).│
/// │    Controller exposure, onSelectionChanged, and potential rename of      │
/// │    SelectionGroupController → SelectionGroupEngine.                      │
/// │    See ROADMAP.md at docs folder for full details.                       │
/// └──────────────────────────────────────────────────────────────────────────┘
library selection_group;

import 'package:flutter/material.dart';

// --- Core Components ---
part 'src/selection_group_controller.dart';
part 'src/selection_group_widget.dart';
part 'src/selection_group_item_mixin.dart';

// --- Ready-to-use components ---
part 'src/selection_group_item.dart';
part 'src/selection_group_radio.dart';

/// ────────────────────────────────────────────────────────────────────────────