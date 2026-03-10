import 'package:flutter/material.dart';
import 'walletDetails.dart';
import 'wallet_ffi.dart';

class RestoreWalletPage extends StatefulWidget {
  const RestoreWalletPage({super.key});

  @override
  State<RestoreWalletPage> createState() => _RestoreWalletPageState();
}

class _RestoreWalletPageState extends State<RestoreWalletPage> {
  final _nameController = TextEditingController();
  final _seedsController = TextEditingController();
  bool _isLoading = false;
  bool _obscureSeeds = true;

  void _submit() async {
    final name = _nameController.text.trim();
    final seeds = _seedsController.text.trim();

    if (name.isEmpty) {
      _showError('Please enter a wallet name.');
      return;
    }

    final wordCount = seeds.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
    if (seeds.isEmpty || wordCount != 25) {
      _showError('Please enter exactly 25 seed words.');
      return;
    }


    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    // Call C++ wallet generator via FFI
    Map<String, String> walletData;
    try {
      walletData = WalletFfi().restoreWallet(seeds);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Failed to generate wallet: $e');
      return;
    }

    final address = walletData['address'] ?? '';
    final finalSeeds = walletData['seeds'] ?? '';
    final spend_pub = walletData['spend_pub'] ?? '';
    final view_pub = walletData['view_pub'] ?? '';
    final private_spend_key = walletData['private_spend_key'] ?? '';
    final private_view_key = walletData['private_view_key'] ?? '';

    if(finalSeeds != seeds){
      setState(() => _isLoading = false);
      _showError('Failed to restore wallet');
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WalletDetailsPage(
          name: name,
          address: address,
          seeds: seeds,
          spend_pub: spend_pub,
          view_pub: view_pub,
          private_spend_key: private_spend_key,
          private_view_key: private_view_key,
        ),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Restore Wallet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0D0D1A), Color(0xFF1A0A2E), Color(0xFF0A1628)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildHeaderCard(),
                const SizedBox(height: 32),
                _buildLabel('Wallet Name'),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _nameController,
                  hint: 'e.g. My Restored Wallet',
                  icon: Icons.badge_outlined,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLabel('Seed Phrase (25 words)'),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _obscureSeeds = !_obscureSeeds),
                      child: Icon(
                        _obscureSeeds
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF00E5FF),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSeedsField(),
                const SizedBox(height: 8),
                Text(
                  'Enter your 25 words separated by spaces.',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 12),
                ),
                const SizedBox(height: 32),
                _buildRestoreButton(),
                // const SizedBox(height: 20),
                // _buildWarningCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00E5FF).withOpacity(0.10),
            const Color(0xFF00E5FF).withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.restore_rounded,
                color: Color(0xFF00E5FF), size: 28),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Restore Wallet',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                SizedBox(height: 4),
                Text('Recover your wallet using a 25-word seed phrase.',
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Icon(icon, color: const Color(0xFF00E5FF)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildSeedsField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _seedsController,
        maxLines: _obscureSeeds ? 4 : 6,
        obscureText: false,
        style: TextStyle(
          color: _obscureSeeds ? Colors.white.withOpacity(0.4) : Colors.white,
          fontSize: 14,
          letterSpacing: _obscureSeeds ? 4 : 0,
        ),
        decoration: InputDecoration(
          hintText: 'word1 word2 word3 ... word25',
          hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.25),
              fontSize: 14,
              letterSpacing: 0),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: Icon(Icons.key_outlined, color: const Color(0xFF00E5FF)),
          ),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildRestoreButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submit,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF00E5FF).withOpacity(0.85),
              const Color(0xFF0098AA),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restore_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Restore Wallet',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildWarningCard() {
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
              'Never share your seed phrase with anyone. Keep it safe and offline.',
              style: TextStyle(color: Colors.orange.withOpacity(0.9), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}