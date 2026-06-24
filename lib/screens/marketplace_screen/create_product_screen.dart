import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_colors.dart';

class CreateListingScreen extends StatefulWidget {
  const CreateListingScreen({super.key});

  @override
  State<CreateListingScreen> createState() => _CreateListingScreenState();
}

class _CreateListingScreenState extends State<CreateListingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController       = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController       = TextEditingController();
  final _locationController    = TextEditingController();

  String _selectedCategory  = 'Electronics';
  String _selectedCondition = 'Like New';
  bool   _negotiable        = true;
  bool   _allowResell       = false;
  bool   _isSubmitting      = false;

  final _marginController = TextEditingController();

  final List<XFile> _images = [];
  final ImagePicker _picker = ImagePicker();

  static const _categories = ['Electronics', 'Vehicles', 'Furniture', 'Fashion', 'Other'];
  static const _conditions = ['Like New', 'Good', 'Used'];
  static const int _maxImages = 10;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _marginController.dispose();
    super.dispose();
  }

  // ── Image picking ──────────────────────────────────────────────

  Future<void> _pickImages() async {
    final remaining = _maxImages - _images.length;
    if (remaining <= 0) { _showSnack('Maximum $_maxImages images allowed'); return; }
    final picked = await _picker.pickMultiImage(imageQuality: 85, limit: remaining);
    if (picked.isNotEmpty) setState(() => _images.addAll(picked));
  }

  void _removeImage(int index) => setState(() => _images.removeAt(index));

  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _images.removeAt(oldIndex);
      _images.insert(newIndex, item);
    });
  }

  // ── Submit (local only for now) ────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) { _showSnack('Please add at least one photo'); return; }

    setState(() => _isSubmitting = true);

    // Simulate a brief delay (remove when API is ready)
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      setState(() => _isSubmitting = false);
      _showSnack('Listing published! 🎉', success: true);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.pop(context, true);
    }
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? const Color(0xFF4CAF50) : Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Build ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Theme.of(context).brightness,
        ),
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left,
              color: AppColors.primaryText(context), size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'New Listing',
          style: TextStyle(
              color: AppColors.primaryText(context),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [

            // ── Photos ─────────────────────────────────────────
            _sectionLabel(context, 'Photos',
                trailing: '${_images.length}/$_maxImages'),
            const SizedBox(height: 10),
            _buildPhotoRow(context),
            const SizedBox(height: 5),
            Text(
              'First photo is your cover · drag to reorder',
              style: TextStyle(
                  fontSize: 11, color: AppColors.mutedText(context)),
            ),

            // ── Basic Info ─────────────────────────────────────
            const SizedBox(height: 24),
            _sectionLabel(context, 'Basic Info'),
            const SizedBox(height: 10),
            _buildField(
              context,
              controller: _titleController,
              label: 'Title',
              hint: 'e.g. iPhone 13 Pro Max 256GB',
              icon: Iconsax.tag,
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            _buildField(
              context,
              controller: _descriptionController,
              label: 'Description',
              hint: 'Brand, age, reason for selling, included accessories...',
              icon: Iconsax.document_text,
              maxLines: 4,
            ),

            // ── Pricing ────────────────────────────────────────
            const SizedBox(height: 24),
            _sectionLabel(context, 'Pricing'),
            const SizedBox(height: 10),
            _buildField(
              context,
              controller: _priceController,
              label: 'Price (₹)',
              hint: '0',
              icon: Iconsax.wallet,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}'))
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Price is required';
                if (double.tryParse(v) == null) return 'Enter a valid price';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildToggle(
              context,
              icon: Iconsax.discount_shape,
              label: 'Negotiable',
              subtitle: 'Allow buyers to make offers',
              value: _negotiable,
              onChanged: (v) => setState(() => _negotiable = v),
            ),
            const SizedBox(height: 12),
            _buildToggle(
              context,
              icon: Iconsax.refresh,
              label: 'Allow Resell',
              subtitle: 'Let others resell this product for a margin',
              value: _allowResell,
              onChanged: (v) => setState(() => _allowResell = v),
            ),
            if (_allowResell) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBackground(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLine(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reseller margin (%)',
                      style: TextStyle(
                        color: AppColors.primaryText(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Profit percentage resellers earn when they sell your item',
                      style: TextStyle(
                        color: AppColors.secondaryText(context),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _marginController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: 'e.g. 15',
                        suffixText: '%',
                        filled: true,
                        fillColor: AppColors.primaryBackground(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (v) {
                        if (!_allowResell) return null;
                        if (v == null || v.isEmpty) {
                          return 'Enter margin percentage';
                        }
                        final n = int.tryParse(v);
                        if (n == null || n < 1 || n > 100) {
                          return 'Enter 1–100';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],

            // ── Details ────────────────────────────────────────
            const SizedBox(height: 24),
            _sectionLabel(context, 'Details'),
            const SizedBox(height: 10),
            _buildDropdown(
              context,
              label: 'Category',
              icon: Iconsax.category,
              value: _selectedCategory,
              items: _categories,
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 12),
            _buildConditionPicker(context),

            // ── Location ───────────────────────────────────────
            const SizedBox(height: 24),
            _sectionLabel(context, 'Location'),
            const SizedBox(height: 10),
            _buildField(
              context,
              controller: _locationController,
              label: 'Location',
              hint: 'e.g. Guwahati, Assam',
              icon: Iconsax.location,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  // ── Photo Row ──────────────────────────────────────────────────

  Widget _buildPhotoRow(BuildContext context) {
    return SizedBox(
      height: 106,
      child: ReorderableListView(
        scrollDirection: Axis.horizontal,
        buildDefaultDragHandles: false,
        onReorder: _reorderImages,
        header: _images.length < _maxImages ? _addPhotoBtn(context) : null,
        children: List.generate(_images.length, (i) {
          return ReorderableDragStartListener(
            key: ValueKey(_images[i].path),
            index: i,
            child: _imageThumbnail(context, i),
          );
        }),
      ),
    );
  }

  Widget _addPhotoBtn(BuildContext context) {
    return GestureDetector(
      onTap: _pickImages,
      child: Container(
        width: 100,
        height: 100,
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.buttonColor(context).withOpacity(0.35)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.camera,
                size: 26, color: AppColors.buttonColor(context)),
            const SizedBox(height: 4),
            Text(
              'Add Photo',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.buttonColor(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageThumbnail(BuildContext context, int index) {
    return Stack(
      key: ValueKey(_images[index].path),
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(_images[index].path), fit: BoxFit.cover),
          ),
        ),
        // Cover badge
        if (index == 0)
          Positioned(
            bottom: 6,
            left: 4,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.buttonColor(context),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Cover',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        // Remove button
        Positioned(
          top: 4,
          right: 12,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }

  // ── Condition Picker ───────────────────────────────────────────

  Widget _buildConditionPicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.star,
                size: 15, color: AppColors.secondaryText(context)),
            const SizedBox(width: 6),
            Text('Condition',
                style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText(context))),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: _conditions.map((c) {
            final selected = _selectedCondition == c;
            Color bg, fg, border;
            switch (c) {
              case 'Like New':
                bg     = selected ? Colors.green.withOpacity(0.15) : AppColors.secondaryBackground(context);
                fg     = selected ? Colors.green.shade700 : AppColors.secondaryText(context);
                border = selected ? Colors.green.shade400 : AppColors.borderLine(context);
                break;
              case 'Good':
                bg     = selected ? Colors.orange.withOpacity(0.15) : AppColors.secondaryBackground(context);
                fg     = selected ? Colors.orange.shade800 : AppColors.secondaryText(context);
                border = selected ? Colors.orange.shade400 : AppColors.borderLine(context);
                break;
              default:
                bg     = selected ? Colors.red.withOpacity(0.1) : AppColors.secondaryBackground(context);
                fg     = selected ? Colors.red.shade700 : AppColors.secondaryText(context);
                border = selected ? Colors.red.shade300 : AppColors.borderLine(context);
            }
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedCondition = c),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(
                      right: c != _conditions.last ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: border),
                  ),
                  child: Text(c,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: fg)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ── Reusable Widgets ───────────────────────────────────────────

  Widget _sectionLabel(BuildContext context, String label,
      {String? trailing}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryText(context),
            letterSpacing: 0.4,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 6),
          Text(trailing,
              style: TextStyle(
                  fontSize: 12, color: AppColors.mutedText(context))),
        ],
      ],
    );
  }

  Widget _buildField(
      BuildContext context, {
        required TextEditingController controller,
        required String label,
        required String hint,
        required IconData icon,
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        List<TextInputFormatter>? inputFormatters,
        String? Function(String?)? validator,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLine(context)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        style: TextStyle(
            color: AppColors.primaryText(context), fontSize: 14),
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(
              color: AppColors.mutedText(context), fontSize: 13),
          hintStyle: TextStyle(
              color: AppColors.mutedText(context), fontSize: 13),
          prefixIcon:
          Icon(icon, size: 18, color: AppColors.mutedText(context)),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          errorStyle: const TextStyle(fontSize: 11),
        ),
      ),
    );
  }

  Widget _buildDropdown(
      BuildContext context, {
        required String label,
        required IconData icon,
        required String value,
        required List<String> items,
        required ValueChanged<String?> onChanged,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLine(context)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              color: AppColors.mutedText(context), fontSize: 13),
          prefixIcon:
          Icon(icon, size: 18, color: AppColors.mutedText(context)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        dropdownColor: AppColors.secondaryBackground(context),
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.mutedText(context)),
        style: TextStyle(
            color: AppColors.primaryText(context), fontSize: 14),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
      ),
    );
  }

  Widget _buildToggle(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String subtitle,
        required bool value,
        required ValueChanged<bool> onChanged,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLine(context)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        secondary:
        Icon(icon, size: 20, color: AppColors.mutedText(context)),
        title: Text(label,
            style: TextStyle(
                fontSize: 14, color: AppColors.primaryText(context))),
        subtitle: Text(subtitle,
            style: TextStyle(
                fontSize: 11, color: AppColors.mutedText(context))),
        activeColor: AppColors.buttonColor(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Bottom Bar ─────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground(context),
        border: Border(
            top: BorderSide(color: AppColors.borderLine(context))),
      ),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.buttonColor(context),
          foregroundColor: AppColors.buttonTextColor(context),
          disabledBackgroundColor:
          AppColors.buttonColor(context).withOpacity(0.5),
          padding: const EdgeInsets.symmetric(vertical: 20),
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
        child: _isSubmitting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
              color: Colors.white, strokeWidth: 2.5),
        )
            : const Text('Publish Listing',
            style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    );
  }
}