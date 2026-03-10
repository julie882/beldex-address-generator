import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WalletDetailsPage extends StatelessWidget {
  final String name;
  final String address;
  final String seeds;
  final String spend_pub;
  final String view_pub;
  final String private_spend_key;
  final String private_view_key;

  const WalletDetailsPage({
    super.key,
    required this.name,
    required this.address,
    required this.seeds,
    required this.spend_pub,
    required this.view_pub,
    required this.private_spend_key,
    required this.private_view_key,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied!'),
        backgroundColor: const Color(0xFF7C4DFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seedWords = seeds.trim().split(RegExp(r'\s+'));

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Wallet Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withOpacity(0.4)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.green, size: 16),
                  SizedBox(width: 4),
                  Text('Active',
                      style: TextStyle(color: Colors.green, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D0D1A), Color(0xFF1A0A2E), Color(0xFF0A1628)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet identity card
              _buildIdentityCard(),
              const SizedBox(height: 24),
              // Address card
              _buildSectionLabel('Wallet Address'),
              const SizedBox(height: 10),
              _buildCopyCard(
                context,
                value: address,
                icon: Icons.wallet_rounded,
                onCopy: () => _copyToClipboard(context, address, 'Address'),
              ),
              const SizedBox(height: 24),
              // Seed phrase section
              _buildSectionLabel('Seed Phrase'),
              const SizedBox(height: 10),
              _buildSeedGrid(seedWords),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _copyToClipboard(context, seeds, 'Seed phrase'),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.copy_rounded,
                          color: Color(0xFF7C4DFF), size: 18),
                      SizedBox(width: 8),
                      Text('Copy All Seeds',
                          style: TextStyle(
                              color: Color(0xFF7C4DFF),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Keys section
              _buildSectionLabel('Keys'),
              const SizedBox(height: 10),
              _buildSectionLabel('Spend Public Key'),
              _buildCopyCard(
                context,
                value: spend_pub,
                icon: Icons.wallet_rounded,
                onCopy: () => _copyToClipboard(context, spend_pub, 'Spend Public Key'),
              ),
              const SizedBox(height: 10),
              _buildSectionLabel('View Public Key'),
              _buildCopyCard(
                context,
                value: view_pub,
                icon: Icons.wallet_rounded,
                onCopy: () => _copyToClipboard(context, view_pub, 'View Public Key'),
              ),
              const SizedBox(height: 10),
              _buildSectionLabel('Private Spend Key'),
              _buildCopyCard(
                context,
                value: private_spend_key,
                icon: Icons.wallet_rounded,
                onCopy: () => _copyToClipboard(context, private_spend_key, 'Private Spend Key'),
              ),
              const SizedBox(height: 10),
              _buildSectionLabel('Private View Key'),
              _buildCopyCard(
                context,
                value: private_view_key,
                icon: Icons.wallet_rounded,
                onCopy: () => _copyToClipboard(context, private_view_key, 'Private View Key'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF5C35CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Beldex Wallet',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: Colors.white.withOpacity(0.15),
          ),
          const SizedBox(height: 16),
          Text(
            '${(seeds.trim().split(RegExp(r'\s+')).length)} words seed phrase secured',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
          color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildCopyCard(
    BuildContext context, {
    required String value,
    required IconData icon,
    required VoidCallback onCopy,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7C4DFF), size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded,
                color: Color(0xFF7C4DFF), size: 20),
            onPressed: onCopy,
          ),
        ],
      ),
    );
  }

  Widget _buildSeedGrid(List<String> words) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(words.length, (i) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF7C4DFF).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: const Color(0xFF7C4DFF).withOpacity(0.25)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${i + 1}.',
                  style: TextStyle(
                      color: const Color(0xFF7C4DFF).withOpacity(0.7),
                      fontSize: 11),
                ),
                const SizedBox(width: 4),
                Text(
                  words[i],
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBackupWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Write down your seed phrase and store it in a safe place. It is the only way to recover your wallet.',
              style:
                  TextStyle(color: Colors.orange.withOpacity(0.9), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}