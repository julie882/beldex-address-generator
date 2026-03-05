import 'package:flutter/material.dart';
import 'walletDetails.dart';

class RestoreWalletPage extends StatefulWidget {
  const RestoreWalletPage({super.key});

  @override
  State<RestoreWalletPage> createState() => _RestoreWalletPageState();
}

class _RestoreWalletPageState extends State<RestoreWalletPage> {
  final _nameController = TextEditingController();
  final _seedsController = TextEditingController();

  void _submit() {
    final name = _nameController.text;
    final seeds = _seedsController.text;
    if (name.isNotEmpty && seeds.isNotEmpty) {
      // Dummy address for the restored wallet
      final address = "0x" + List.generate(40, (index) => ((index + 1) % 16).toRadixString(16)).join();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WalletDetailsPage(
            name: name,
            address: address,
            seeds: seeds,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _seedsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Restore Wallet")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _seedsController,
              decoration: const InputDecoration(
                labelText: "25 Seeds (space separated)",
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Restore"),
            ),
          ],
        ),
      ),
    );
  }
}