import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:serial/serial.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _inputController = TextEditingController();
  SerialPort? _port;
  final _received = <String>[];

  Future<void> _openPort() async {
    final port = await window.navigator.serial.requestPort();
    await port.open(baudRate: 9600);

    _port = port;
  }

  Future<void> _writeToPort(String data) async {
    if (_port == null) {
      return;
    }

    final writer = _port!.writable.writer;

    await writer.ready;
    await writer.write(Uint8List.fromList(data.codeUnits));

    await writer.ready;
    await writer.close();
  }

  Future<void> _readFromPort() async {
    if (_port == null) {
      return;
    }

    final reader = _port!.readable.reader;

    while (true) {
      final result = await reader.read();
      final text = String.fromCharCodes(result.value);

      setState(() {
        _received.add(text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Serial'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Card(
                  elevation: 4,
                  child: ListView.builder(
                    itemCount: _received.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          _received[index],
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openPort,
                child: const Text('Open Port'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _inputController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '请输入要传递的信息',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final inputText = _inputController.text;
                  _writeToPort(inputText);
                },
                child: const Text('Send'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _readFromPort,
                child: const Text('Receive'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}