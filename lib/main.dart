import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'package:nfc_manager/nfc_manager.dart';

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

  void readKit() {
    FlutterNfcKit.poll().then((tag) {
      Logs.add(tag, 'KIT');
    });
  }

  void readManager() {
    NfcManager.instance.startSession(
      onDiscovered: (tag) async {
        Logs.add(tag, 'MAN');
      },
    );
  }

  void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.85,
        child: Logs(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                readKit();
                show(context);
              },
              child: const Text('Flutter NFC Kit'),
            ),
            ElevatedButton(
              onPressed: () {
                readManager();
                show(context);
              },
              child: const Text('NFC Manager'),
            ),
          ],
        ),
      ),
      bottomSheet: InkWell(
        onTap: () => show(context),
        child: Ink(
          color: Colors.blue[200],
          height: 60,
          child: const Center(
            child: Text('Logs'),
          ),
        ),
      ),
    );
  }
}

class Logs extends StatelessWidget {
  Logs({super.key});

  static final _stream = StreamController<String>.broadcast(sync: true);

  static void add(dynamic tag, String source) {
    late final String st;
    if (tag is NFCTag) st = tag.st;
    if (tag is NfcTag) st = tag.st;
    print('$source: $st');
    _stream.add('$source: $st');
  }

  static Stream<String> logsStream() => _stream.stream;

  String data = 'Empty logs';

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

extension S2 on NfcTag {
  String get st {
    final props = [
      handle,
      const JsonEncoder.withIndent('  ').convert(data),
    ];
    return props.join('\n');
  }
}
