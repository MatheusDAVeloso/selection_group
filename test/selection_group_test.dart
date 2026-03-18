import 'package:flutter_test/flutter_test.dart';
import 'package:selection_group/selection_group.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('SelectionGroup initialValue sets selected state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SelectionGroup<String>(
          initialValue: 'home',
          child: const SizedBox(),
        ),
      ),
    );

    final controller = SelectionGroup.of<String>(
      tester.element(find.byType(SelectionGroup<String>)),
    );

    expect(controller?.value, 'home');
  });

  testWidgets('SelectionGroupController.select updates value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SelectionGroup<String>(
          initialValue: 'home',
          child: const SizedBox(),
        ),
      ),
    );

    final controller = SelectionGroup.of<String>(
      tester.element(find.byType(SelectionGroup<String>)),
    );

    controller?.select('search');
    expect(controller?.value, 'search');
  });
}