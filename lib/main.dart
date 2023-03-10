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

  double decToNormalView(int number) {
    final string = number.toString();
    double result = double.parse(string);
    if (string.length > 2) {
      final s = '${string.substring(0, 2)}.${string.substring(2)}';
      result = double.parse(s);
    }
    return result;
  }

  List<String> hexTo4Digits(String hex) => hex
      .replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ')
      .split(' ')
    ..removeLast();

  Map<String, List>hexTo2Columns(List<String> hexes) {
    List oddList = [];
    List evenList = [];

    for (int i = 0; i < hexes.length; i++) {
      if (i.isEven) {
        evenList.add(hexes[i]);
      } else if (i.isOdd) {
        oddList.add(hexes[i]);
      }
    }

    return {
      'even': evenList,
      'odd': oddList,
    };
  }

  List<String> hexToLines(String hex) {
    final columns = hexTo2Columns(hexTo4Digits(hex));
    final even = columns['even'] ?? [];
    final odd = columns['odd'] ?? [];
    final lines = <String>[];

    for (int i = 0; i < even.length; i++) {
      String line = '';
      final temp = int.tryParse(even[i], radix: 16) ?? 0;
      final wet = int.tryParse(odd[i], radix: 16) ?? 0;

      line += decToNormalView(temp).toString();
      line += '\t';
      line += decToNormalView(wet).toString();

      lines.add(line);
    }
    return lines;
  }

  void readKit() async {
    await FlutterNfcKit.poll();
    final r = await FlutterNfcKit.transceive('22233b589e43080104e0000f');
    final lines = hexToLines(r);
    Logs.add(lines.join('\n'));
    // Logs.add(r.splitByLength());
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
