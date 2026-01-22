import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../config/theme.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/reviews_provider.dart';
import '../widgets/review_list_widget.dart';
import '../widgets/add_review_dialog.dart';
import '../utils/auth_guard.dart';

class DetailScreen extends StatelessWidget {
  final Establishment establishment;

  const DetailScreen({super.key, required this.establishment});

  Future<void> _launchWhatsApp() async {
    final url = Uri.parse('https://wa.me/${establishment.phone}?text=Hola%20quiero%20información');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch WhatsApp');
    }
  }

  Future<void> _launchMaps() async {
    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=${establishment.lat},${establishment.lng}');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch Maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: establishment.mainImage,
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              Consumer<AppProvider>(
                builder: (context, provider, _) {
                  final isFav = provider.isFavorite(establishment.id);
                  return IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.white,
                    ),
                    onPressed: () => provider.toggleFavorite(establishment.id),
                  );
                },
              ),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            establishment.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Consumer<ReviewsProvider>(
                            builder: (context, revProvider, _) {
                              final displayRating = revProvider.reviews.isNotEmpty 
                                  ? revProvider.averageRating.toStringAsFixed(1)
                                  : establishment.rating.toStringAsFixed(1);
                              return Row(
                                children: [
                                  const Icon(Icons.star, size: 16, color: Colors.white),
                                  Text(
                                    " $displayRating",
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Address
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppTheme.googleMapsColor),
                        const SizedBox(width: 4),
                        Expanded(child: Text(establishment.address)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Gallery
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: establishment.galleryImages.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: establishment.galleryImages[index],
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.whatsappColor,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.message),
                            label: const Text('WhatsApp'),
                            onPressed: _launchWhatsApp,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.googleMapsColor,
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.map),
                            label: const Text('Cómo llegar'),
                            onPressed: _launchMaps,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Info Grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 3,
                      children: [
                        _InfoItem(icon: Icons.access_time, text: "Abierto hoy"),
                        _InfoItem(icon: Icons.attach_money, text: establishment.priceRange),
                        _InfoItem(icon: Icons.public, text: "Website"),
                        _InfoItem(icon: Icons.phone, text: establishment.phone),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    const Text(
                      "Descripción",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(establishment.description),
                    const SizedBox(height: 24),

                    // Reviews Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Reseñas",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: () async {
                            final authProvider = context.read<AuthProvider>();
                            final canProceed = await AuthGuard.requireAuth(
                              context, 
                              authProvider,
                              message: 'Inicia sesión para compartir tu experiencia.'
                            );
                            
                            if (canProceed && context.mounted) {
                              showDialog(
                                context: context,
                                builder: (context) => AddReviewDialog(establishmentId: establishment.id),
                              );
                            }
                          },
                          icon: const Icon(Icons.add_comment),
                          label: const Text("Escribir reseña"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ReviewListWidget(establishmentId: establishment.id),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
