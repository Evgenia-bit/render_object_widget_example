import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Экран с шахматной доской, которая использует [SlottedMultiChildRenderObjectWidget].
class ChessboardScreen extends StatelessWidget {
  const ChessboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = [
      _ChessboardItemData(background: Colors.green, text: 'Item1'),
      _ChessboardItemData(background: Colors.pink, text: 'Item2-long'),
      _ChessboardItemData(background: Colors.red, text: 'Item3-very-long'),
      _ChessboardItemData(background: Colors.deepPurpleAccent, text: 'Item4-very-very-long'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Шахматная доска\n (SlottedMultiChildRenderObjectWidget)',
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        child: _ChessboardContainer(
          children: items
              .map(
                (e) => _ChessboardItem(
                  background: e.background,
                  child: Text(
                    e.text,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// Конфигурация ячейки шахматной доски.
class _ChessboardItemData {
  final Color background;
  final String text;

  const _ChessboardItemData({
    required this.background,
    required this.text,
  });
}

/// Контейнер для шахматной доски.
///
/// Реализует SlottedMultiChildRenderObjectWidget для создания виджета с несколькими дочерними объектами.
class _ChessboardContainer extends SlottedMultiChildRenderObjectWidget<int, RenderChessboardItem> {
  final List<Widget> children;

  const _ChessboardContainer({required this.children});

  /// Извлечь дочерний виджет по известному идентификатору слота
  @override
  Widget? childForSlot(int slot) => children[slot];

  @override
  SlottedContainerRenderObjectMixin<int, RenderChessboardItem> createRenderObject(
          BuildContext context) =>
      _RenderChessboardContainer();

  @override
  Iterable<int> get slots => List.generate(children.length, (index) => index);
}

/// Объект рендеринга для контейнера шахматной доски.
///
/// SlottedContainerRenderObjectMixin предоставляет доступ к дочерним элементам и принимает тип слота и RenderObject для элемента.
class _RenderChessboardContainer extends RenderBox
    with SlottedContainerRenderObjectMixin<int, RenderChessboardItem> {
  @override
  void paint(PaintingContext context, Offset offset) {
    //заполнение фона
    context.canvas.drawRect(
        offset & size,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.blueAccent);
    if (maxSizes != null) {
      double y = 0;
      for (final (idx, c) in children.indexed) {
        double x = 0;
        bool even = (idx ~/ 2) % 2 == 0;
        final pos = (idx % 2) * 2 + (even ? 0 : 1);
        for (int i = 0; i < pos; i++) {
          x += maxSizes![i % 2];
        }
        //отрисовка вложенного объекта
        context.paintChild(c, offset + Offset(x, y));
        if (idx % 2 == 1) {
          y += maxSizes![even ? 0 : 1];
        }
      }
    }
  }

  List<double>? maxSizes;

  @override
  void performLayout() {
    size = constraints.biggest;
    const presetHeight = 128.0;
    maxSizes = List.generate(2, (index) => 0.0);
    for (final (idx, c) in children.indexed) {
      final row = (idx ~/ 2) % 2;
      final eval = c.getMaxIntrinsicWidth(presetHeight);
      maxSizes![row] = max(maxSizes![row], eval);
    }
    //позиционируем по квадратам
    for (final (idx, c) in children.indexed) {
      final row = (idx ~/ 2) % 2;
      c.layout(
        BoxConstraints.tightFor(
          width: maxSizes![row],
          height: maxSizes![row],
        ),
      );
    }
  }
}

/// Виджет ячейки шахматной доски.
class _ChessboardItem extends SingleChildRenderObjectWidget {
  final Color background;

  const _ChessboardItem({
    required this.background,
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => RenderChessboardItem(background);
}

/// Объект рендеринга для ячейки шахматной доски.
///
/// Наследуемся от RenderProxyBox, чтобы иметь доступ к child.
class RenderChessboardItem extends RenderProxyBox {
  final Color background;

  RenderChessboardItem(this.background);

  /// getMaxIntrinsicWidth/ Height и getMinIntrinsicWidth/Height используются для определения предпочтительных границ размера RenderObject и позволяют установить наименьшую и наибольшую возможную ширину для заданной высоты и аналогично для высоты с заданной шириной. Использование этих методов позволяет предварительно оценить ожидаемый размер RenderObject без вызова performLayout — его не следует вызывать более одного раза в кадр, в то время как сами эти методы можно вызывать многократно.
  @override
  double getMaxIntrinsicHeight(double width) {
    super.getMaxIntrinsicHeight(width);
    return child!.getMaxIntrinsicHeight(width);
  }

  @override
  double getMinIntrinsicHeight(double width) {
    super.getMinIntrinsicHeight(width);
    return child!.getMinIntrinsicHeight(width);
  }

  @override
  double getMaxIntrinsicWidth(double height) {
    super.getMaxIntrinsicWidth(height);
    return child!.getMaxIntrinsicWidth(height);
  }

  @override
  double getMinIntrinsicWidth(double height) {
    super.getMinIntrinsicWidth(height);
    return child!.getMinIntrinsicWidth(height);
  }

  /// Установить размер RenderObject.
  @override
  void performLayout() {
    child!.layout(constraints);
    size = constraints.biggest;
  }

  /// Отрисовать объект.
  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(offset & size,
        Paint()..color = (child!.parentData as _BackgroundColorParentData).background);
    context.paintChild(child!, offset);
  }

  /// Передать данные родительскому RenderObject.
  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! ParentData) {
      child.parentData = _BackgroundColorParentData(background);
    }
  }
}

/// Данные, которые передаются родительскому объекту.
class _BackgroundColorParentData extends ParentData {
  Color background;

  _BackgroundColorParentData(this.background);
}
