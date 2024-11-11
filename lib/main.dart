import 'package:flutter/material.dart';
import 'package:render_object_widget_example/chessboard_screen.dart';
import 'package:render_object_widget_example/clock_screen.dart';
import 'package:render_object_widget_example/half_decorator_screen.dart';

class _RoutePaths {
  static const home = '/';
  static const clock = '/clock';
  static const chessboard = '/chessboard';
  static const halfDecorator = '/half_decorator';
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      routes: {
        _RoutePaths.home: (context) => const _HomeScreen(),
        _RoutePaths.clock: (context) => const ClockScreen(),
        _RoutePaths.chessboard: (context) => const ChessboardScreen(),
        _RoutePaths.halfDecorator: (context) => const HalfDecoratorScreen(),
      },
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Примеры RenderObjectWidget'),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HomeButton(
                title: 'Часы (LeafRenderObjectWidget)',
                route: _RoutePaths.clock,
              ),
              SizedBox(height: 20),
              _HomeButton(
                title: 'Шахматная доска (SlottedMultiChildRenderObjectWidget)',
                route: _RoutePaths.chessboard,
              ),
              SizedBox(height: 20),
              _HomeButton(
                title: 'Half decorator (SingleChildRenderObjectWidget)',
                route: _RoutePaths.halfDecorator,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  const _HomeButton({
    required this.title,
    required this.route,
  });

  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.of(context).pushNamed(route),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
