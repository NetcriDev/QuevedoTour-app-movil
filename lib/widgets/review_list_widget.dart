import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reviews_provider.dart';
import 'review_item_widget.dart';

class ReviewListWidget extends StatefulWidget {
  final String establishmentId;

  const ReviewListWidget({super.key, required this.establishmentId});

  @override
  State<ReviewListWidget> createState() => _ReviewListWidgetState();
}

class _ReviewListWidgetState extends State<ReviewListWidget> {
  @override
  void initState() {
    super.initState();
    // Load reviews when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReviewsProvider>().loadReviews(widget.establishmentId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.reviews.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.errorMessage != null && provider.reviews.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                   Text(provider.errorMessage!),
                   const SizedBox(height: 8),
                   ElevatedButton(
                     onPressed: () => provider.loadReviews(widget.establishmentId),
                     child: const Text('Reintentar'),
                   ),
                ],
              ),
            ),
          );
        }

        if (provider.reviews.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No hay reseñas todavía. ¡Sé el primero en opinar!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        return Column(
          children: [
            ...provider.reviews.map((review) => ReviewItemWidget(review: review)),
            if (provider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
          ],
        );
      },
    );
  }
}
