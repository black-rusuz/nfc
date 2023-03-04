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
    FlutterNfcKit.poll().then(Logs.logsStream);
  }

  void readManager() {
    NfcManager.instance.startSession(
      onDiscovered: (tag) async => Logs.logsStream(tag),
    );
  }

  void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.7,
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
  const Logs({super.key});

  static Stream<String> logsStream(value) async* {
    yield value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Ink(
      padding: const EdgeInsets.all(20),
      child: StreamBuilder<String>(
        builder: (_, snap) {
          return SingleChildScrollView(
            child: Text(snap.data ?? 'Logs empty'),
          );
        },
      ),
    );
  }
}
