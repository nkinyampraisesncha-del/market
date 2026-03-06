import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/validators.dart';

class ReviewScreen extends StatefulWidget {
  final String orderId;
  const ReviewScreen({super.key, required this.orderId});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _service = SupabaseService();
  final _commentCtrl = TextEditingController();
  double _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;
      await _service.createReview({
        'product_id': '', 'reviewer_id': user.id, 'reviewer_name': user.name,
        'reviewee_id': '', 'order_id': widget.orderId, 'rating': _rating,
        'comment': _commentCtrl.text.trim(), 'is_seller_review': true,
        'created_at': DateTime.now().toIso8601String(),
      });
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review submitted!'))); context.pop(); }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    } finally { setState(() => _isSubmitting = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leave a Review'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.star_rate_outlined, size: 64),
            const SizedBox(height: 16),
            Text('How was your experience?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => IconButton(
                icon: Icon(i < _rating ? Icons.star : Icons.star_outline, size: 36),
                color: Colors.amber,
                onPressed: () => setState(() => _rating = i + 1.0),
              )),
            ),
            const SizedBox(height: 16),
            TextFormField(controller: _commentCtrl, maxLines: 4, decoration: const InputDecoration(labelText: 'Comment (optional)', hintText: 'Share your experience...', alignLabelWithHint: true)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
