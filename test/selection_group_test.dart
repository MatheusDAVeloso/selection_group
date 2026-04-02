import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:selection_group/selection_group.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

/// Wraps [child] in a [MaterialApp] with a [FocusTraversalGroup] so that
/// keyboard traversal works in tests.
Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

/// A minimal [SelectionItem] host that exposes its [State] for assertions.
class _Item<T> extends StatefulWidget {
  const _Item({super.key, required this.value});
  final T value;
  @override
  State<_Item<T>> createState() => _ItemState<T>();
}

class _ItemState<T> extends State<_Item<T>> with SelectionMixin<_Item<T>, T> {
  @override
  T? get selectionValue => widget.value;

  @override
  Widget build(BuildContext context) => Focus(
        focusNode: focusNode,
        child: GestureDetector(
          onTap: select,
          child: ValueListenableBuilder(
            valueListenable: statesController,
            builder: (_, states, __) => Container(
              key: ValueKey('item_${widget.value}'),
              color: states.contains(WidgetState.selected) ? Colors.blue : Colors.grey,
            ),
          ),
        ),
      );
}

// ─── SelectionGroup.single ───────────────────────────────────────────────────

void main() {
  group('SelectionGroup.single', () {
    testWidgets('initialValue sets selected state', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          initialValue: 'home',
          child: const Column(
            children: [
              _Item<String>(value: 'home'),
              _Item<String>(value: 'search'),
            ],
          ),
        ),
      ));

      final controller = SelectionGroup.of<String>(
        tester.element(find.byType(_Item<String>).first),
      );

      expect(controller?.isSelected('home'), isTrue);
      expect(controller?.isSelected('search'), isFalse);
    });

    testWidgets('select() updates value', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          initialValue: 'home',
          child: const Column(
            children: [
              _Item<String>(value: 'home'),
              _Item<String>(value: 'search'),
            ],
          ),
        ),
      ));

      final controller = SelectionGroup.of<String>(
        tester.element(find.byType(_Item<String>).first),
      );

      controller?.select('search');
      await tester.pump();

      expect(controller?.isSelected('search'), isTrue);
      expect(controller?.isSelected('home'), isFalse);
    });

    testWidgets('onFocusedItemChanged is called when focus changes', (tester) async {
      String? focused;

      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          initialValue: 'home',
          onFocusedItemChanged: (value) => focused = value,
          child: const Column(
            children: [
              _Item<String>(key: Key('home'), value: 'home'),
              _Item<String>(key: Key('search'), value: 'search'),
            ],
          ),
        ),
      ));

      final homeState = tester.state<_ItemState<String>>(find.byKey(const Key('home')));
      homeState.focusNode.requestFocus();
      await tester.pump();

      expect(focused, 'home');
    });

    testWidgets('selectOnFocus: true selects item on focus', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          selectOnFocus: true,
          child: const Column(
            children: [
              _Item<String>(key: Key('home'), value: 'home'),
              _Item<String>(key: Key('search'), value: 'search'),
            ],
          ),
        ),
      ));

      final searchState = tester.state<_ItemState<String>>(find.byKey(const Key('search')));
      searchState.focusNode.requestFocus();
      await tester.pump();

      final controller = SelectionGroup.of<String>(
        tester.element(find.byKey(const Key('search'))),
      );

      expect(controller?.isSelected('search'), isTrue);
    });

    testWidgets('selectOnFocus: false does not select item on focus', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          initialValue: 'home',
          selectOnFocus: false,
          child: const Column(
            children: [
              _Item<String>(key: Key('home'), value: 'home'),
              _Item<String>(key: Key('search'), value: 'search'),
            ],
          ),
        ),
      ));

      final searchState = tester.state<_ItemState<String>>(find.byKey(const Key('search')));
      searchState.focusNode.requestFocus();
      await tester.pump();

      final controller = SelectionGroup.of<String>(
        tester.element(find.byKey(const Key('search'))),
      );

      expect(controller?.isSelected('home'), isTrue);
      expect(controller?.isSelected('search'), isFalse);
    });

    testWidgets('maintainSelectionOnFocus: false suppresses selected while group has focus', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          initialValue: 'home',
          selectOnFocus: false,
          maintainSelectionOnFocus: false,
          child: const Column(
            children: [
              _Item<String>(key: Key('home'), value: 'home'),
              _Item<String>(key: Key('search'), value: 'search'),
            ],
          ),
        ),
      ));

      final homeState = tester.state<_ItemState<String>>(find.byKey(const Key('home')));
      homeState.focusNode.requestFocus();
      await tester.pump();

      final controller = SelectionGroup.of<String>(
        tester.element(find.byKey(const Key('home'))),
      );

      // group has focus → selected is suppressed
      expect(controller?.isSelected('home'), isFalse);
    });

    testWidgets('maintainSelectionOnFocus: true keeps selected while group has focus', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          initialValue: 'home',
          selectOnFocus: false,
          maintainSelectionOnFocus: true,
          child: const Column(
            children: [
              _Item<String>(key: Key('home'), value: 'home'),
              _Item<String>(key: Key('search'), value: 'search'),
            ],
          ),
        ),
      ));

      final homeState = tester.state<_ItemState<String>>(find.byKey(const Key('home')));
      homeState.focusNode.requestFocus();
      await tester.pump();

      final controller = SelectionGroup.of<String>(
        tester.element(find.byKey(const Key('home'))),
      );

      expect(controller?.isSelected('home'), isTrue);
    });

    testWidgets('focusInitialItem focuses initial item on first frame', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          initialValue: 'home',
          focusInitialItem: true,
          child: const Column(
            children: [
              _Item<String>(key: Key('home'), value: 'home'),
              _Item<String>(key: Key('search'), value: 'search'),
            ],
          ),
        ),
      ));

      await tester.pump();

      final homeState = tester.state<_ItemState<String>>(find.byKey(const Key('home')));
      expect(homeState.focusNode.hasFocus, isTrue);
    });

    testWidgets('of() returns null outside a SelectionGroup', (tester) async {
      await tester.pumpWidget(_app(
        const _Item<String>(value: 'home'),
      ));

      final controller = SelectionGroup.of<String>(
        tester.element(find.byType(_Item<String>)),
      );

      expect(controller, isNull);
    });
  });

  // ─── SelectionGroup.multi ──────────────────────────────────────────────────

  group('SelectionGroup.multi', () {
    testWidgets('initialValues sets selected state', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.multi(
          initialValues: const {'a', 'b'},
          child: const Column(
            children: [
              _Item<String>(value: 'a'),
              _Item<String>(value: 'b'),
              _Item<String>(value: 'c'),
            ],
          ),
        ),
      ));

      final controller = SelectionGroup.of<String>(
        tester.element(find.byType(_Item<String>).first),
      );

      expect(controller?.isSelected('a'), isTrue);
      expect(controller?.isSelected('b'), isTrue);
      expect(controller?.isSelected('c'), isFalse);
    });

    testWidgets('select() adds item', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.multi(
          child: const Column(
            children: [
              _Item<String>(value: 'a'),
              _Item<String>(value: 'b'),
            ],
          ),
        ),
      ));

      final controller = SelectionGroup.of<String>(
        tester.element(find.byType(_Item<String>).first),
      );

      controller?.select('a');
      await tester.pump();

      expect(controller?.isSelected('a'), isTrue);
    });

    testWidgets('select() on selected item removes it (toggle)', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.multi(
          initialValues: const {'a'},
          child: const Column(
            children: [
              _Item<String>(value: 'a'),
            ],
          ),
        ),
      ));

      final controller = SelectionGroup.of<String>(
        tester.element(find.byType(_Item<String>).first),
      );

      controller?.select('a');
      await tester.pump();

      expect(controller?.isSelected('a'), isFalse);
    });

    testWidgets('maxSelection with block prevents new selection', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.multi(
          initialValues: const {'a', 'b'},
          maxSelection: 2,
          maxSelectionBehavior: MaxSelectionBehavior.block,
          child: const Column(
            children: [
              _Item<String>(value: 'a'),
              _Item<String>(value: 'b'),
              _Item<String>(value: 'c'),
            ],
          ),
        ),
      ));

      final controller = SelectionGroup.of<String>(
        tester.element(find.byType(_Item<String>).first),
      );

      controller?.select('c');
      await tester.pump();

      expect(controller?.isSelected('c'), isFalse);
      expect(controller?.isSelected('a'), isTrue);
      expect(controller?.isSelected('b'), isTrue);
    });

    testWidgets('maxSelection with dequeue removes oldest item', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.multi(
          initialValues: const {'a', 'b'},
          maxSelection: 2,
          maxSelectionBehavior: MaxSelectionBehavior.dequeue,
          child: const Column(
            children: [
              _Item<String>(value: 'a'),
              _Item<String>(value: 'b'),
              _Item<String>(value: 'c'),
            ],
          ),
        ),
      ));

      final controller = SelectionGroup.of<String>(
        tester.element(find.byType(_Item<String>).first),
      );

      controller?.select('c');
      await tester.pump();

      expect(controller?.isSelected('c'), isTrue);
      expect(controller?.isSelected('a'), isFalse);
      expect(controller?.isSelected('b'), isTrue);
    });

    testWidgets('onItemToggled called with true when item is selected', (tester) async {
      String? toggledItem;
      bool? toggledState;

      await tester.pumpWidget(_app(
        SelectionGroup<String>.multi(
          onItemToggled: (item, isSelected) {
            toggledItem = item;
            toggledState = isSelected;
          },
          child: const Column(
            children: [
              _Item<String>(value: 'a'),
            ],
          ),
        ),
      ));

      final controller = SelectionGroup.of<String>(
        tester.element(find.byType(_Item<String>).first),
      );

      controller?.select('a');
      await tester.pump();

      expect(toggledItem, 'a');
      expect(toggledState, isTrue);
    });

    testWidgets('onItemToggled called with false when item is deselected', (tester) async {
      String? toggledItem;
      bool? toggledState;

      await tester.pumpWidget(_app(
        SelectionGroup<String>.multi(
          initialValues: const {'a'},
          onItemToggled: (item, isSelected) {
            toggledItem = item;
            toggledState = isSelected;
          },
          child: const Column(
            children: [
              _Item<String>(value: 'a'),
            ],
          ),
        ),
      ));

      final controller = SelectionGroup.of<String>(
        tester.element(find.byType(_Item<String>).first),
      );

      controller?.select('a');
      await tester.pump();

      expect(toggledItem, 'a');
      expect(toggledState, isFalse);
    });

    testWidgets('initialItemToFocus focuses correct item on first frame', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.multi(
          initialItemToFocus: 'b',
          child: const Column(
            children: [
              _Item<String>(key: Key('a'), value: 'a'),
              _Item<String>(key: Key('b'), value: 'b'),
            ],
          ),
        ),
      ));

      await tester.pump();

      final bState = tester.state<_ItemState<String>>(find.byKey(const Key('b')));
      expect(bState.focusNode.hasFocus, isTrue);
    });
  });

  // ─── SelectionMixin ────────────────────────────────────────────────────────

  group('SelectionMixin', () {
    testWidgets('registers in controller on mount', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          initialValue: 'a',
          child: const _Item<String>(key: Key('a'), value: 'a'),
        ),
      ));

      final controller = SelectionGroup.of<String>(
        tester.element(find.byKey(const Key('a'))),
      );

      expect(controller?.isSelected('a'), isTrue);
    });

    testWidgets('statesController receives WidgetState.selected when selected', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          initialValue: 'a',
          child: const _Item<String>(key: Key('a'), value: 'a'),
        ),
      ));

      final state = tester.state<_ItemState<String>>(find.byKey(const Key('a')));

      expect(state.statesController.value.contains(WidgetState.selected), isTrue);
    });

    testWidgets('statesController removes WidgetState.selected when deselected', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          initialValue: 'a',
          child: const Column(
            children: [
              _Item<String>(key: Key('a'), value: 'a'),
              _Item<String>(key: Key('b'), value: 'b'),
            ],
          ),
        ),
      ));

      final controller = SelectionGroup.of<String>(
        tester.element(find.byKey(const Key('a'))),
      );

      controller?.select('b');
      await tester.pump();

      final aState = tester.state<_ItemState<String>>(find.byKey(const Key('a')));
      expect(aState.statesController.value.contains(WidgetState.selected), isFalse);
    });

    testWidgets('select() is no-op outside a SelectionGroup', (tester) async {
      await tester.pumpWidget(_app(
        const _Item<String>(key: Key('a'), value: 'a'),
      ));

      final state = tester.state<_ItemState<String>>(find.byKey(const Key('a')));

      // should not throw
      expect(() => state.select(), returnsNormally);
      expect(state.statesController.value.contains(WidgetState.selected), isFalse);
    });

    testWidgets('unregisters from controller on unmount', (tester) async {
      bool mounted = true;

      await tester.pumpWidget(_app(
        StatefulBuilder(
          builder: (_, setState) => SelectionGroup<String>.single(
            child: Column(
              children: [
                if (mounted) const _Item<String>(key: Key('a'), value: 'a'),
                GestureDetector(
                  onTap: () => setState(() => mounted = false),
                  child: const SizedBox(key: Key('toggle')),
                ),
              ],
            ),
          ),
        ),
      ));

      await tester.tap(find.byKey(const Key('toggle')));
      await tester.pump();

      // should not throw after unmount
      expect(find.byKey(const Key('a')), findsNothing);
    });
  });

  // ─── SelectionItem ─────────────────────────────────────────────────────────

  group('SelectionItem', () {
    testWidgets('pressing calls select()', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          child: SelectionItem<String>(
            key: const Key('item'),
            value: 'a',
            builder: (_, states) => const Text('A'),
          ),
        ),
      ));

      await tester.tap(find.byKey(const Key('item')));
      await tester.pump();

      final controller = SelectionGroup.of<String>(
        tester.element(find.byKey(const Key('item'))),
      );

      expect(controller?.isSelected('a'), isTrue);
    });

    testWidgets('enabled: false disables the button', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          child: SelectionItem<String>(
            key: const Key('item'),
            value: 'a',
            enabled: false,
            builder: (_, states) => const Text('A'),
          ),
        ),
      ));

      await tester.tap(find.byKey(const Key('item')));
      await tester.pump();

      final controller = SelectionGroup.of<String>(
        tester.element(find.byKey(const Key('item'))),
      );

      expect(controller?.isSelected('a'), isFalse);
    });

    testWidgets('onPressed is called after select()', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          child: SelectionItem<String>(
            key: const Key('item'),
            value: 'a',
            onPressed: () => pressed = true,
            builder: (_, states) => const Text('A'),
          ),
        ),
      ));

      await tester.tap(find.byKey(const Key('item')));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('externalStates enters passive mode', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          child: SelectionItem<String>(
            key: const Key('item'),
            value: 'a',
            externalStates: const {WidgetState.selected},
            onPressed: () => pressed = true,
            builder: (_, states) => Text(
              states.contains(WidgetState.selected) ? 'selected' : 'idle',
            ),
          ),
        ),
      ));

      // renders with externalStates
      expect(find.text('selected'), findsOneWidget);

      // non-interactive — tap should not trigger onPressed
      await tester.tap(find.byKey(const Key('item')));
      await tester.pump();

      expect(pressed, isFalse);
    });
  });

  // ─── SelectionRadio ────────────────────────────────────────────────────────

  group('SelectionRadio', () {
    testWidgets('renders correctly and reflects selected state', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          initialValue: 'a',
          child: SelectionRadio<String>(
            key: const Key('radio'),
            value: 'a',
            dotColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected) ? Colors.blue : Colors.transparent,
            ),
          ),
        ),
      ));

      expect(find.byKey(const Key('radio')), findsOneWidget);
    });

    testWidgets('externalStates delegates to SelectionItem passive mode', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          child: const SelectionRadio<String>(
            key: Key('radio'),
            value: 'a',
            externalStates: {WidgetState.selected},
          ),
        ),
      ));

      // non-interactive
      await tester.tap(find.byKey(const Key('radio')));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('enabled: false prevents selection on tap', (tester) async {
      await tester.pumpWidget(_app(
        SelectionGroup<String>.single(
          child: const SelectionRadio<String>(
            key: Key('radio'),
            value: 'a',
            enabled: false,
          ),
        ),
      ));

      await tester.tap(find.byKey(const Key('radio')));
      await tester.pump();

      final controller = SelectionGroup.of<String>(
        tester.element(find.byKey(const Key('radio'))),
      );

      expect(controller?.isSelected('a'), isFalse);
    });
  });
}
