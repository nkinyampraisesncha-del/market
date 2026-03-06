import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/validators.dart';

class BuyerReportScreen extends StatefulWidget {
  const BuyerReportScreen({super.key});

  @override
  State<BuyerReportScreen> createState() => _BuyerReportScreenState();
}

class _BuyerReportScreenState extends State<BuyerReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionCtrl = TextEditingController();
  String _reportType = 'scam';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isSubmitting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Report'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Report Type', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _reportType,
                decoration: const InputDecoration(labelText: 'Select type'),
                items: const [
                  DropdownMenuItem(value: 'scam', child: Text('Scam / Fraud')),
                  DropdownMenuItem(value: 'fake', child: Text('Fake Item')),
                  DropdownMenuItem(value: 'inappropriate', child: Text('Inappropriate Content')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setState(() => _reportType = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe the issue in detail...',
                  alignLabelWithHint: true,
                ),
                validator: Validators.description,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
