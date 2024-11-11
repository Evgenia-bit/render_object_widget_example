import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Экран с декоратором, который использует [SingleChildRenderObjectWidget].
class HalfDecoratorScreen extends StatelessWidget {
  const HalfDecoratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Декоратор с рамкой \n (SingleChildRenderObjectWidget)',
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
      body: const Center(
        child: SizedBox(
          width: 256,
          height: 256,
          child: _HalfDecorator(
            child: Text(
              'I am decorated',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Декоратор, который рисует рамку вокруг дочернего виджета.
///
/// Используем SingleChildRenderObjectWidget, который имеет дочерний виджет.
class _HalfDecorator extends SingleChildRenderObjectWidget {
  const _HalfDecorator({
    required super.child,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderHalfDecorator();
}

/// RenderObject для [_HalfDecorator].
///
/// Используем mixin RenderObjectWithChildMixin для доступа к дочернему объекту. Также он предоставляет реализации методов attach/detach, которые тоже используются для добавления/удаления дочерних объектов в дерево RenderObject. Альтернативно можно наследоваться от RenderProxyBox (также предоставляет доступ к child).
class _RenderHalfDecorator extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  @override
  void paint(PaintingContext context, Offset offset) {
    context.canvas.drawRect(
        offset & size,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.green);
    final position = Offset(
      (size.width - child!.size.width) / 2,
      (size.height - child!.size.height) / 2,
    );
    context.paintChild(child!, offset + position);
    context.canvas.drawRect(
      offset + position & child!.size,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.yellow
        ..strokeWidth = 2,
    );
  }

  /// Определяет размер, который виджет хотел бы иметь с учетом ограничений от родителя.
  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  /// Устанавливает размер виджета.
  @override
  void performLayout() {
    //дочерний объект ограничиваем размером от 0 до половины нашего размера
    child?.layout(constraints.copyWith(
      minWidth: 0,
      minHeight: 0,
      maxWidth: constraints.maxWidth / 2,
      maxHeight: constraints.maxHeight / 2,
    ));
    //собственный размер - максимально возможный
    size = constraints.biggest;
  }
}
