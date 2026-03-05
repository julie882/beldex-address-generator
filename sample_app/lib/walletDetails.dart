import 'package:flutter/material.dart';

class WalletDetailsPage extends StatelessWidget {
  final String name;
  final String address;
  final String seeds;

  const WalletDetailsPage({
    super.key,
    required this.name,
    required this.address,
    required this.seeds,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Wallet Details")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("name: $name", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("address: $address", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("seeds: $seeds", style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}