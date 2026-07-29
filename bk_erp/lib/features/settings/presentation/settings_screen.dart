import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/state/app_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _appData = AppData();

  late final TextEditingController _companyNameCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _vatCtrl;
  late final TextEditingController _vatRateCtrl;
  late final TextEditingController _financialYearCtrl;
  late final TextEditingController _cashBalancedCtrl;

  @override
  void initState() {
    super.initState();
    final s = _appData.settings;
    _companyNameCtrl = TextEditingController(text: s.companyName);
    _addressCtrl = TextEditingController(text: s.companyAddress);
    _phoneCtrl = TextEditingController(text: s.companyPhone);
    _emailCtrl = TextEditingController(text: s.companyEmail);
    _vatCtrl = TextEditingController(text: s.companyVatPAN);
    _vatRateCtrl = TextEditingController(text: s.defaultVatRate.toString());
    _financialYearCtrl = TextEditingController(text: s.financialYearStart);
    _cashBalancedCtrl = TextEditingController(text: s.cashOpeningBalance.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _vatCtrl.dispose();
    _vatRateCtrl.dispose();
    _financialYearCtrl.dispose();
    _cashBalancedCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final s = AppSettings(
      companyName: _companyNameCtrl.text,
      companyAddress: _addressCtrl.text,
      companyPhone: _phoneCtrl.text,
      companyEmail: _emailCtrl.text,
      companyVatPAN: _vatCtrl.text,
      defaultVatRate: double.tryParse(_vatRateCtrl.text) ?? 13.0,
      financialYearStart: _financialYearCtrl.text,
      cashOpeningBalance: double.tryParse(_cashBalancedCtrl.text) ?? 0.0,
    );
    _appData.saveSettings(s);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.tableHeaderBg,
            child: const Row(
              children: [
                Icon(Icons.settings, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Settings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.surfaceBorder), borderRadius: BorderRadius.circular(2)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Business Profile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          const SizedBox(height: 2),
                          const Text('These details appear on printed invoices.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          const SizedBox(height: 12),
                          _buildField('Company Name', _companyNameCtrl),
                          const SizedBox(height: 10),
                          _buildField('Address', _addressCtrl),
                          const SizedBox(height: 10),
                          _buildField('Phone Number', _phoneCtrl),
                          const SizedBox(height: 10),
                          _buildField('Company Email', _emailCtrl),
                          const SizedBox(height: 10),
                          _buildField('VAT/PAN Number', _vatCtrl),
                          const SizedBox(height: 20),
                          const Text('Financial Settings', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          const SizedBox(height: 2),
                          const Text('Configure accounting basics.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildField('Default VAT Rate (%)', _vatRateCtrl)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildField('Financial Year Start', _financialYearCtrl)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildField('Cash Opening Balance (Rs)', _cashBalancedCtrl),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _saveSettings,
                              icon: const Icon(Icons.save, size: 16),
                              label: const Text('Save Settings', style: TextStyle(fontSize: 12)),
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.surface, border: Border.all(color: AppColors.surfaceBorder), borderRadius: BorderRadius.circular(2)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Backup & Restore', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          const SizedBox(height: 2),
                          const Text('Keep your data safe by exporting regularly.', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text('Export Backup', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.upload, size: 16),
                              label: const Text('Restore Backup', style: TextStyle(fontSize: 12)),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Status Bar ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: const BoxDecoration(
              color: AppColors.statusBarBg,
              border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
            ),
            child: const Text(
              'Settings  |  Configure your business profile, financial year, and VAT settings.',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11)),
        const SizedBox(height: 3),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 12),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
      ],
    );
  }
}
