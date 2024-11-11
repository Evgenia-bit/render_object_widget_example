import 'package:flutter/material.dart';
import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// Экран с часами, который использует [LeafRenderObjectWidget].
class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  final clockData = ClockData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Часы \n (LeafRenderObjectWidget)',
          maxLines: 2,
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => setState(() => clockData.offset += const Offset(1, 1)),
                child: const Text('Сдвинуть'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => clockData.size *= 1.1),
                child: const Text('Изменить размер'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => clockData.hour++),
                child: const Text('Прибавить час'),
              ),
              ElevatedButton(
                onPressed: () => setState(() => clockData.minute++),
                child: const Text('Прибавить минуту'),
              ),
              // ignore: prefer_const_constructors
              SizedBox(height: 40),
              LimitedBox(
                maxWidth: 200,
                maxHeight: 200,
                child: Clock(
                  size: clockData.size,
                  offset: clockData.offset,
                  hour: clockData.hour,
                  minute: clockData.minute,
                  onUpdateMinutes: (minutes) {
                    setState(() => clockData.minute = minutes);
                  },
                  onUpdateHours: (hours) {
                    setState(() => clockData.hour = hours);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Виджет часов.
///
/// Используем LeafRenderObjectWidget, так как дочерних виджетов нет.
class Clock extends LeafRenderObjectWidget {
  final Size size;
  final Offset offset;
  final double hour;
  final double minute;
  final ValueSetter<double> onUpdateMinutes;
  final ValueSetter<double> onUpdateHours;

  const Clock({
    required this.size,
    required this.offset,
    required this.hour,
    required this.minute,
    required this.onUpdateMinutes,
    required this.onUpdateHours,
    super.key,
  });

  @override
  RenderObject createRenderObject(BuildContext context) => ClockRenderBox(
        size,
        offset,
        hour,
        minute,
        onUpdateMinutes,
        onUpdateHours,
      );

  /// Вызывается при изменении конфигурации виджета.
  @override
  void updateRenderObject(BuildContext context, covariant RenderObject renderObject) {
    final clockRenderObject = renderObject as ClockRenderBox;
    clockRenderObject
      ..ownSize = size
      ..offset = offset
      ..hour = hour
      ..minute = minute;
  }
}

class ClockRenderBox extends RenderBox implements TickerProvider {
  Size _size;
  Offset _offset;
  double _hour;
  double _minute;
  ValueSetter<double> onUpdateMinutes;
  ValueSetter<double> onUpdateHours;
  AnimationController? _animationController;

  ClockRenderBox(
    this._size,
    this._offset,
    this._hour,
    this._minute,
    this.onUpdateMinutes,
    this.onUpdateHours,
  );

  /// Флаг, влияющий на логику определения размера.
  ///
  /// Если [sizedByParent] возвращает true, то размер может быть получен из свойства size в RenderBox (при изменении также вызывается [performResize]);
  /// Если [sizedByParent] возвращает false, то размер определяется виджетом самостоятельно в методе [computeDryLayout] с использованием ограничений от родителя и сохраняется в size внутри обязательно реализованного метода [performLayout] . Это значение возвращается по умолчанию.
  @override
  get sizedByParent => false;

  /// Определяет размер, который виджет хотел бы иметь с учетом ограничений от родителя.
  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.constrain(_size);

  /// Устанавливает размер виджета.
  @override
  void performLayout() => size = constraints.constrain(_size);

  /// Метод вызывается родительским RenderObject, когда формируется дерево объектов рендеринга.
  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _animationController = AnimationController(
      vsync: this,
      lowerBound: 63,
      upperBound: 255,
      duration: const Duration(seconds: 1),
    );
    _animationController?.repeat();
    _animationController?.addListener(markNeedsPaint);
  }

  /// Вызывается при исключении RenderObject из дерева,
  /// если создавший его виджет был перемещён или  удалён. Он должен выполнить обращение к detach для всех дочерних объектов.
  @override
  void detach() {
    _animationController?.stop();
    super.detach();
  }

  set ownSize(Size newSize) {
    if (newSize != _size) {
      _size = newSize;
      markNeedsPaint();
      markNeedsLayout();
    }
  }

  set offset(Offset offset) {
    if (offset != _offset) {
      _offset = offset;
      markNeedsPaint();
    }
  }

  set hour(double hour) {
    if (hour != _hour) {
      _hour = hour;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  set minute(double minute) {
    if (minute != _minute) {
      _minute = minute;
      markNeedsPaint();
      markNeedsSemanticsUpdate();
    }
  }

  /// Отрисовка объекта.
  @override
  void paint(PaintingContext context, Offset offset) {
    final center = size.center(offset + _offset);
    final radius = size.shortestSide / 2;
    final hourToRads = _hour / 12 * 2 * pi;
    final minsToRads = _minute / 60 * 2 * pi;
    final paintHours = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 5
      ..color = Colors.white;
    final paintMins = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 2
      ..color = Colors.grey;

    context.pushOpacity(center, _animationController?.value.toInt() ?? 255, (context, offset) {
      context.canvas.drawLine(
        offset,
        offset +
            Offset(
              radius / 2 * cos(pi / 2 - hourToRads),
              -radius / 2 * sin(pi / 2 - hourToRads),
            ),
        paintHours,
      );
      context.canvas.drawLine(
        offset,
        offset +
            Offset(
              radius * cos(pi / 2 - minsToRads),
              -radius * sin(pi / 2 - minsToRads),
            ),
        paintMins,
      );
    });
  }

  /// Вызывается при событии касания или перемещения курсора.
  ///
  /// [hitTest] принимает позицию касания в относительных координатах основного слоя RenderObject. В результате выполнения [hitTest] может быть возвращено true, если нужно остановить обработку события прикосновения, или false, чтобы передать это сообщение другим RenderObject, расположенным в той же области экрана.
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!(Offset.zero & size).contains(position)) return false;
    result.add(BoxHitTestEntry(this, position));
    return true;
  }

  /// Обработка события касания.
  @override
  void handleEvent(PointerEvent event, covariant BoxHitTestEntry entry) {
    final center = size / 2;
    final position = entry.localPosition;
    double angle = atan2(position.dx - center.width, position.dy - center.height) + pi;
    if (angle > 2 * pi) {
      angle = angle - 2 * pi;
    }
    final minutes = (2 * pi - angle) / (2 * pi) * 60;
    onUpdateMinutes(minutes);
  }

  Ticker? _ticker;

  @override
  Ticker createTicker(TickerCallback onTick) {
    _ticker ??= Ticker(onTick);
    return _ticker!;
  }
}

class ClockData {
  Offset offset = Offset.zero;
  Size size = const Size.square(128);
  double hour = 0;
  double minute = 0;
}
