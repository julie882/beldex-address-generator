import 'package:flutter/material.dart';

import 'createWallet.dart';
import 'restoreWallet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter macOS Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  void createWallet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateWalletPage()),
    );
  }

  void restoreWallet() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RestoreWalletPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter macOS Sample App"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: createWallet,
              child: const Text("create-wallet"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: restoreWallet,
              child: const Text("Restore-wallet"),
            ),
          ],
        ),
      ),
    );
  }
}
