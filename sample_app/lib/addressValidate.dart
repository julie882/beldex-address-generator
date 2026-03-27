import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'wallet_ffi.dart';

class AddressValidatePage extends StatefulWidget {
  const AddressValidatePage({super.key});

  @override
  State<AddressValidatePage> createState() => _AddressValidatePageState();
}

class _AddressValidatePageState extends State<AddressValidatePage> {
  final _addressController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _validationResult;

  void _submit() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _showError('Please enter a Beldex address to validate.');
      return;
    }

    setState(() {
      _isLoading = true;
      _validationResult = null;
    });
    
    await Future.delayed(const Duration(milliseconds: 300)); // slight UI delay

    try {
      final result = WalletFfi().validateAddress(address);
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _validationResult = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError('Failed to validate address: $e');
    }
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

  Widget _buildResultPanel() {
    if (_validationResult == null) return const SizedBox.shrink();

    final isValid = _validationResult!['isValid'] == true;
    final spendPub = _validationResult!['spend_pub']?.toString() ?? '';
    final viewPub = _validationResult!['view_pub']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.withOpacity(0.05) : Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isValid ? Colors.green.withOpacity(0.4) : Colors.red.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid ? Icons.check_circle_rounded : Icons.error_rounded,
                color: isValid ? Colors.greenAccent : Colors.redAccent,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                isValid ? 'Valid Address' : 'Invalid Address',
                style: TextStyle(
                  color: isValid ? Colors.greenAccent : Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          if (isValid) ...[
            const SizedBox(height: 20),
            _buildSectionLabel('Network'),
            const SizedBox(height: 8),
            Text(
              _validationResult!['network']?.toString() ?? 'Unknown',
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            _buildSectionLabel('Spend Public Key'),
            const SizedBox(height: 8),
            _buildCopyCard(
              context,
              value: spendPub,
              icon: Icons.key_rounded,
              onCopy: () => _copyToClipboard(context, spendPub, 'Spend Public Key'),
            ),
            const SizedBox(height: 16),
            _buildSectionLabel('View Public Key'),
            const SizedBox(height: 8),
            _buildCopyCard(
              context,
              value: viewPub,
              icon: Icons.visibility_rounded,
              onCopy: () => _copyToClipboard(context, viewPub, 'View Public Key'),
            ),
          ]
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
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
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Validate Address',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        height: double.infinity,
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
                const Text(
                  'Beldex Address',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  controller: _addressController,
                  hint: 'Enter Beldex address here...',
                  icon: Icons.qr_code_scanner_rounded,
                ),
                const SizedBox(height: 24),
                _buildValidateButton(),
                _buildResultPanel(),
                const SizedBox(height: 40),
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
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00E5FF).withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
              color: Color(0xFF00E5FF),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Validate Beldex Address',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Check if an address is valid and extract its public keys.',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
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
        maxLines: 4,
        minLines: 2,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(bottom: 24.0), // align top
            child: Icon(icon, color: const Color(0xFF00E5FF)),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildValidateButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _submit,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00E5FF).withOpacity(0.4),
            width: 1.5,
          ),
        ),
        child: Center(
          child:
              _isLoading
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF00E5FF),
                    ),
                  )
                  : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_rounded, color: Color(0xFF00E5FF)),
                      SizedBox(width: 8),
                      Text(
                        'Validate Address',
                        style: TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
