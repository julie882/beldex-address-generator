import 'package:flutter/material.dart';
import 'walletDetails.dart';

class CreateWalletPage extends StatefulWidget {
  const CreateWalletPage({super.key});

  @override
  State<CreateWalletPage> createState() => _CreateWalletPageState();
}

class _CreateWalletPageState extends State<CreateWalletPage> {
  final _nameController = TextEditingController();

  void _submit() {
    final name = _nameController.text;
    if (name.isNotEmpty) {
      // Generating a dummy address and 25 words seeds for the new wallet
      final address = "0x" + List.generate(40, (index) => (index % 16).toRadixString(16)).join();
      final seeds = List.generate(25, (index) => "word${index + 1}").join(" ");

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Wallet")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text("Create"),
            ),
          ],
        ),
      ),
    );
  }
}