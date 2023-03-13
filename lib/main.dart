import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MousePage(),
    );
  }
}

class MousePage extends StatefulWidget {
  const MousePage({super.key});

  @override
  State<MousePage> createState() => _MousePageState();
}

class _MousePageState extends State<MousePage> {
  final wsUrl = Uri.parse('ws://192.168.166.221:26541');
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();

    channel = WebSocketChannel.connect(wsUrl);

    channel.stream.listen((message) {});
  }

  int pointCount = 0;
  int currentAction = -1;

  @override
  Widget build(BuildContext context) {
    return Listener(
      // onPanUpdate: (details) {
      //   channel.sink.add('mouse_move_relative:${details.delta.dx.ceil()},${details.delta.dy.ceil()}');
      //   // print('details -> $details');
      // },
      // onTap: () {
      //   channel.sink.add('ontap:');
      // },
      // onSecondaryTap: () {
      //   print('details');
      //   // channel.sink.add('onsecondarytap:');
      // },
      // onTapDown: (details) {
      //   print(details);
      // },
      // onTapUp: (details) {
      //   print(details);
      //   // channel.sink.add('ontapup:');
      // },
      onPointerDown: (event) {
        currentAction = 0;
        pointCount++;
        print('pointCount -> $pointCount');
        print('buttons -> ${event.pointer}');
        if (pointCount == 2) {
          currentAction = 2;
        }
        print('onPointerDown -> $event ${event.pressure}');
        print('currentAction -> $currentAction');
      },
      onPointerMove: (event) {
        if (currentAction == 2) return;
        currentAction = 1;
        print('onPointerMove -> $event ${event.pressure}');
        // channel.sink.add('mousemove:${event.position.dx.toInt()},${event.position.dy.toInt()}');
        channel.sink.add('mouse_move_relative:${event.delta.dx.toInt()},${event.delta.dy.toInt()}');
      },
      onPointerUp: (event) {
        if (currentAction == 0) {
          channel.sink.add('onlefttap:');
        } else if (currentAction == 2) {
          currentAction = -1;
          channel.sink.add('onrighttap:');
        }
        pointCount--;
        print('onPointerUp -> $event ${event.pressure}');
      },
      // onPanDown: ,
      behavior: HitTestBehavior.translucent,
      child: Container(),
    );
  }
}
