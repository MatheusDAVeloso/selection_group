/// ┌──────────────────────────────────────────────────────────────────────────┐
/// │                          SELECTION GROUP                                 │
/// │                Advanced Focus & Selection Management                     │
/// ├──────────────────────────────────────────────────────────────────────────┤
/// │  Hold Ctrl + LMB to navigate through components                          │
/// │                                                                          │
/// │  Author: MatheusDAVeloso                                                 │
/// │  Package Version: 0.2.3                                                  │
/// │  Repo: https://github.com/MatheusDAVeloso/selection_group                │
/// ├──────────────────────────────────────────────────────────────────────────┤
/// │  ERAS                                                                    │
/// │                                                                          │
/// │  Era 0 (0.0.x) — Core                                                    │
/// │    Idealization, architecture, and initial bug fixes.                    │
/// │    SelectionGroup, SelectionGroupController, SelectionGroupItemMixin,    │
/// │    and SelectionGroupItem established and stabilized.                    │
/// │                                                                          │
/// │  Era 1 (0.x.x) — Widget Layer & Named Constructors                       │
/// │    Expanding the arsenal of ready-to-use widgets.                        │
/// │    SelectionGroup.single() and SelectionGroup.multi() introduced.        │
/// │    SelectionControllerBase interface established.                        │
/// │    Legacy 0.1.x API moved to deprecated/ — functional, not updated.      │
/// │    Real-world stress testing in production.                              │
/// │                                                                          │
/// └──────────────────────────────────────────────────────────────────────────┘

library selection_group;

import 'package:flutter/material.dart';

// --- Deprecated (0.1.x) ---
part 'deprecated/selection_group_legacy.dart';
part 'deprecated/selection_group_controller_legacy.dart';
part 'deprecated/selection_group_item_mixin_legacy.dart';
part 'deprecated/selection_group_item_legacy.dart';
part 'deprecated/selection_group_radio_legacy.dart';

// --- Core ---
part 'src/core/selection_controller_base.dart';
part 'src/core/selection_enum.dart';
part 'src/core/selection_group_base.dart';

// --- Controllers ---
part 'src/controllers/selection_controller_single.dart';
part 'src/controllers/selection_controller_multi.dart';

// --- Mixins ---
part 'src/mixins/selection_mixin.dart';

// --- Widgets ---
part 'src/widgets/selection_item.dart';
part 'src/widgets/selection_radio.dart';

// --- Groups ---
part 'src/groups/selection_group_single.dart';
part 'src/groups/selection_group_multi.dart';

/// ────────────────────────────────────────────────────────────────────────────
