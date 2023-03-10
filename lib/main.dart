import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  String hexToDec(String hex) => (hex.splitByLength(2).split(' ')..removeLast())
      .map((e) => int.tryParse('0x$e'))
      .join(' ');

  void readKit() async {
    await FlutterNfcKit.poll();
    final r = await FlutterNfcKit.transceive('22233b589e43080104e0000f');
    Logs.add(r.splitByLength(2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Logs(),
      ),
      bottomSheet: InkWell(
        onTap: readKit,
        child: Ink(
          height: 60,
          color: Colors.blue[300],
          child: const Center(
            child: Text(
              'Отсканировать',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}

class Logs extends StatelessWidget {
  Logs({super.key});

  static final _stream = StreamController<String>.broadcast(sync: true);

  static void add(String data) {
    print(data);
    _stream.add('$data\n');
  }

  static Stream<String> logsStream() => _stream.stream;

  String data = 'Empty logs\n';

  @override
  Widget build(BuildContext context) {
    return Ink(
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<String>(
        stream: Logs.logsStream(),
        builder: (_, snap) {
          data += '${snap.data ?? ''}\n';
          return SingleChildScrollView(
            child: Text(data),
          );
        },
      ),
    );
  }
}

extension S1 on NFCTag {
  String get st {
    final props = [
      type,
      standard,
      id,
      atqa,
      sak,
      historicalBytes,
      hiLayerResponse,
      protocolInfo,
      applicationData,
      manufacturer,
      systemCode,
      dsfId,
      ndefAvailable,
      ndefType,
      ndefCapacity,
      ndefWritable,
      ndefCanMakeReadOnly,
      webUSBCustomProbeData,
    ];
    return props.join('\n');
  }
}

extension on String {
  String splitByLength(int length) => toUpperCase()
      .replaceAllMapped(RegExp(r'.{2}'), (match) => '${match.group(0)} ');
}
