part of '../../selection_group.dart';

abstract interface class SelectionControllerBase<T> implements Listenable {
  void _register(T value, FocusNode node);
  void _unregister(T value);
  void select(T value);
  bool isSelected(T value);
}
