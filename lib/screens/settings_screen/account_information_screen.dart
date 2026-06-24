import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// AccountInformationScreen
// ─────────────────────────────────────────────────────────────────────────────
class AccountInformationScreen extends StatelessWidget {
  const AccountInformationScreen({super.key});

  // ── Mock data (replace with real user/auth model) ─────────────────────────
  static const _email = 'kshitiz@example.com';
  static const _phone = '+91 98765 43210';
  static const _dob = 'August 14, 2000';
  static const _gender = 'Male';
  static const _username = 'kshitiz.sharma';
  static const _accountType = 'Creator';
  static const _joinedAt = 'March 12, 2023';
  static const _accountId = 'USR-00482910';
  static const _emailVerified = true;
  static const _phoneVerified = false;

  void _copy(BuildContext ctx, String value, String label) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('$label copied'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showEditSheet(BuildContext ctx, String fieldLabel, String current,
      {TextInputType keyboardType = TextInputType.text}) {
    final ctrl = TextEditingController(text: current);
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: AppColors.primaryBackground(ctx),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.borderLine(ctx),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Edit $fieldLabel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText(ctx),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: keyboardType,
              style: TextStyle(color: AppColors.primaryText(ctx)),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.secondaryBackground(ctx),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter $fieldLabel',
                hintStyle: TextStyle(color: AppColors.secondaryText(ctx)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonColor(ctx),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext ctx) async {
    await showDatePicker(
      context: ctx,
      initialDate: DateTime(2000, 8, 14),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
  }

  void _showGenderSheet(BuildContext ctx) {
    const options = ['Male', 'Female', 'Non-binary', 'Prefer not to say'];
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.primaryBackground(ctx),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.borderLine(ctx),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select Gender',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(ctx),
                  ),
                ),
              ),
            ),
            ...options.map(
                  (g) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                title: Text(
                  g,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primaryText(ctx),
                    fontWeight: g == _gender ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                trailing: g == _gender
                    ? Icon(Icons.check_rounded,
                    color: AppColors.buttonColor(ctx), size: 18)
                    : null,
                onTap: () => Navigator.pop(ctx),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: AppColors.primaryText(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Account Information',
          style: TextStyle(
            color: AppColors.primaryText(context),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [

          // ── Account ──────────────────────────────────────────────────────
          _SectionHeader(label: 'Account'),
          _AccountTile(
            icon: Iconsax.profile_tick,
            label: 'Username',
            value: '@$_username',
            onEdit: () => _showEditSheet(context, 'Username', _username),
          ),
          _ReadOnlyTile(
            icon: Iconsax.crown,
            label: 'Account type',
            value: _accountType,
            valueColor: const Color(0xFF3B6D11),
            valueBg: const Color(0xFFEAF3DE),
          ),
          _ReadOnlyTile(
            icon: Iconsax.calendar,
            label: 'Date joined',
            value: _joinedAt,
          ),
          _ReadOnlyTile(
            icon: Iconsax.tag_user,
            label: 'Account ID',
            value: _accountId,
            onLongPress: () => _copy(context, _accountId, 'Account ID'),
          ),

          const SizedBox(height: 24),

          // ── Personal ─────────────────────────────────────────────────────
          _SectionHeader(label: 'Personal'),
          _AccountTile(
            icon: Iconsax.cake,
            label: 'Date of birth',
            value: _dob,
            onEdit: () => _showDatePicker(context),
          ),
          _AccountTile(
            icon: Iconsax.people,
            label: 'Gender',
            value: _gender,
            onEdit: () => _showGenderSheet(context),
          ),

          const SizedBox(height: 24),

          // ── Contact ──────────────────────────────────────────────────────
          _SectionHeader(label: 'Contact'),
          _AccountTile(
            icon: Iconsax.sms,
            label: 'Email address',
            value: _email,
            statusChip: _emailVerified ? _VerifiedChip() : _UnverifiedChip(),
            onEdit: () => _showEditSheet(context, 'Email address', _email,
                keyboardType: TextInputType.emailAddress),
            onLongPress: () => _copy(context, _email, 'Email'),
          ),
          _AccountTile(
            icon: Iconsax.call,
            label: 'Phone number',
            value: _phone,
            statusChip: _phoneVerified ? _VerifiedChip() : _UnverifiedChip(),
            onEdit: () => _showEditSheet(context, 'Phone number', _phone,
                keyboardType: TextInputType.phone),
            onLongPress: () => _copy(context, _phone, 'Phone number'),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.secondaryText(context),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Editable Account Tile
// ─────────────────────────────────────────────────────────────────────────────
class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? statusChip;
  final VoidCallback? onEdit;
  final VoidCallback? onLongPress;

  const _AccountTile({
    required this.icon,
    required this.label,
    required this.value,
    this.statusChip,
    this.onEdit,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLine(context), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.secondaryText(context)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.secondaryText(context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primaryText(context),
                          ),
                        ),
                      ),
                      if (statusChip != null) ...[
                        const SizedBox(width: 8),
                        statusChip!,
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (onEdit != null)
              GestureDetector(
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Iconsax.edit_2,
                    size: 16,
                    color: AppColors.secondaryText(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Read-Only Tile
// ─────────────────────────────────────────────────────────────────────────────
class _ReadOnlyTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? valueBg;
  final VoidCallback? onLongPress;

  const _ReadOnlyTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.valueBg,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderLine(context), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.secondaryText(context)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryText(context),
                ),
              ),
            ),
            if (valueBg != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: valueBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? AppColors.secondaryText(context),
                  ),
                ),
              )
            else
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  color: valueColor ?? AppColors.secondaryText(context),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status chips
// ─────────────────────────────────────────────────────────────────────────────
class _VerifiedChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3DE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 10, color: Color(0xFF3B6D11)),
          SizedBox(width: 3),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B6D11),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnverifiedChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Not verified',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFFE87D2B),
        ),
      ),
    );
  }
}