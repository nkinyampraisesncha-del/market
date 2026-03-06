import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../services/storage_service.dart';
import '../../utils/validators.dart';
import '../../utils/constants.dart';

class AddListingScreen extends StatefulWidget {
  const AddListingScreen({super.key});

  @override
  State<AddListingScreen> createState() => _AddListingScreenState();
}

class _AddListingScreenState extends State<AddListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _rentalPriceCtrl = TextEditingController();
  final _service = SupabaseService();
  final _storageService = StorageService();

  String _category = AppConstants.categories.first;
  String _condition = AppConstants.conditions.first;
  bool _isRentable = false;
  bool _isSubmitting = false;
  List<XFile> _selectedImages = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _rentalPriceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await _storageService.pickMultipleImages(limit: AppConstants.maxImages);
    setState(() => _selectedImages = images);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;

      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _storageService.uploadListingImages(user.id, _selectedImages);
      }

      await _service.createListing({
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text.trim()),
        'category': _category,
        'condition': _condition,
        'images': imageUrls,
        'seller_id': user.id,
        'university_id': user.universityId,
        'status': 'pending_approval',
        'is_rentable': _isRentable,
        'rental_price_per_day': _isRentable && _rentalPriceCtrl.text.isNotEmpty
            ? double.parse(_rentalPriceCtrl.text.trim())
            : null,
        'view_count': 0,
        'favorite_count': 0,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing submitted for approval!')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create listing: $e')),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Listing'),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => context.pop()),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images
              Text('Photos', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: Row(
                  children: [
                    InkWell(
                      onTap: _pickImages,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outline, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate_outlined, color: colorScheme.primary),
                            Text('Add Photos', style: theme.textTheme.labelSmall),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...(_selectedImages.map((img) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(img.path),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 100, height: 100,
                                color: colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.image),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 4, right: 4,
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedImages.remove(img)),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title', prefixIcon: Icon(Icons.title)),
                validator: Validators.title,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined), alignLabelWithHint: true),
                validator: Validators.description,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price', prefixIcon: Icon(Icons.attach_money), prefixText: '\$'),
                validator: Validators.price,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
                items: AppConstants.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _condition,
                decoration: const InputDecoration(labelText: 'Condition', prefixIcon: Icon(Icons.star_outline)),
                items: AppConstants.conditions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _condition = v!),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                value: _isRentable,
                onChanged: (v) => setState(() => _isRentable = v),
                title: const Text('Available for Rent'),
                subtitle: const Text('Allow buyers to rent this item'),
                contentPadding: EdgeInsets.zero,
              ),
              if (_isRentable) ...[
                const SizedBox(height: 8),
                TextFormField(
                  controller: _rentalPriceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Rental Price per Day', prefixIcon: Icon(Icons.loop), prefixText: '\$'),
                  validator: _isRentable ? Validators.price : null,
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit for Approval'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
