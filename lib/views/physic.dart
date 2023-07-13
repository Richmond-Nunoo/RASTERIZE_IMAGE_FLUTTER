import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class MyCustomWidget extends StatefulWidget {
  const MyCustomWidget({super.key});

  @override
  MyCustomWidgetState createState() => MyCustomWidgetState();
}

class MyCustomWidgetState extends State<MyCustomWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade500,
        appBar: AppBar(
          title: const Text("Test App"),
          centerTitle: true,
          elevation: 0,
        ),
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            children: [
              DraggableCard(
                  child: Container(
                height: 150,
                width: 80,
                color: Colors.green,
                child: const Center(
                  child: Text("Card 0"),
                ),
              )),
              const DraggableCard(
                child: SizedBox(
                  height: 150,
                  width: 80,
                  child: Card(
                    color: Colors.blue,
                    child: Center(child: Text("Card 1")),
                  ),
                ),
              ),
              const DraggableCard(
                child: SizedBox(
                  height: 150,
                  width: 80,
                  child: Card(
                    color: Colors.blue,
                    child: Center(child: Text("Card 1")),
                  ),
                ),
              ),
              const DraggableCard(
                child: SizedBox(
                  height: 150,
                  width: 80,
                  child: Card(
                    color: Colors.blue,
                    child: Center(child: Text("Card 1")),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

class DraggableCard extends StatefulWidget {
  final Widget child;

  const DraggableCard({super.key, required this.child});

  @override
  DraggableCardState createState() => DraggableCardState();
}

class DraggableCardState extends State<DraggableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  var _dragAlignment = Alignment.bottomCenter;

  late Animation<Alignment> _animation;

  final _spring = const SpringDescription(
    mass: 7,
    stiffness: 1200,
    damping: 0.7,
  );

  double _normalizeVelocity(Offset velocity, Size size) {
    final normalizedVelocity = Offset(
      velocity.dx / size.width,
      velocity.dy / size.height,
    );
    return -normalizedVelocity.distance;
  }

  void _runAnimation(Offset velocity, Size size) {
    _animation = _controller.drive(
      AlignmentTween(
        begin: _dragAlignment,
        end: Alignment.bottomCenter,
      ),
    );

    final simulation =
        SpringSimulation(_spring, 0.0, 1.0, _normalizeVelocity(velocity, size));

    _controller.animateWith(simulation);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..addListener(() => setState(() => _dragAlignment = _animation.value));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onPanStart: (details) => _controller.stop(canceled: true),
      onPanUpdate: (details) => setState(
        () => _dragAlignment += Alignment(
          details.delta.dx / (size.width / 2),
          details.delta.dy / (size.height / 2),
        ),
      ),
      onPanEnd: (details) =>
          _runAnimation(details.velocity.pixelsPerSecond, size),
      child: Align(
        alignment: _dragAlignment,
        child: Card(
          child: widget.child,
        ),
      ),
    );
  }
}
