import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  runApp(const MyApp());
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  final wsUrl = Uri.parse('ws://192.168.0.101:26541');
  late WebSocketChannel channel;
  late Socket socket;

  @override
  void initState() {
    super.initState();
    connectSocket();
  }

  Future<void> connectSocket() async {
    socket = await Socket.connect('192.168.0.101', 26541);
  }

  int pointCount = 0;
  int currentAction = -1;
  late Offset pointerDownOffset;
  final list = [];
  Map<int, Offset> map = {};
  @override
  Widget build(BuildContext context) {
    GestureDetector;
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
        map[event.pointer] = event.position;
        print('event.pointer -> ${event.pointer}');
        currentAction = 0;
        pointCount++;
        // print('pointCount -> $pointCount');
        // print('buttons -> ${event.pointer}');
        if (pointCount == 2) {
          currentAction = 2;
        }
        // print('onPointerDown -> $event ${event.pressure}');
        // print('currentAction -> $currentAction');
      },
      onPointerMove: (event) {
        if (pointCount == 2) {
          Offset curOffset = event.position;
          if (((map[event.pointer]! - curOffset).dy).abs() > 6) {
            currentAction = 4;
            socket.add([
              4,
              (map[event.pointer]! - curOffset).dy ~/ 6,
            ]);
            // print('${event.pointer} onPointerMove -> ${(map[event.pointer]! - curOffset).dy}');
            map[event.pointer] = curOffset;
          }
          return;
        }
        Offset curOffset = event.position;
        Offset diff = curOffset - map[event.pointer]!;
        if (diff.dx.abs() > 0.5 || diff.dy.abs() > 0.5) {
          // print('event.distance -> ${event.delta.distance}');
          double muiti = min(10, event.delta.distance);
          muiti = max(2, muiti);
          currentAction = 1;
          socket.add([
            1,
            (diff.dx * muiti).round(),
            (diff.dy * muiti).round(),
          ]);
          map[event.pointer] = curOffset;
        }
        // channel.sink.add('mousemove:${event.position.dx.toInt()},${event.position.dy.toInt()}');
        // channel.sink.add('mouse_move_relative:${event.delta.dx.toInt()},${event.delta.dy.toInt()}');
      },
      onPointerSignal: (event) {},
      onPointerUp: (event) {
        map.remove(event.pointer);
        if (currentAction == 0) {
          // channel.sink.add('onlefttap:');

          socket.add([2]);
        } else if (currentAction == 2) {
          currentAction = -1;
          socket.add([3]);
          // channel.sink.add('onrighttap:');
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
