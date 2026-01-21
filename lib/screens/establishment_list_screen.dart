import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../services/mock_service.dart'; // Can be removed if unused
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';
import '../screens/detail_screen.dart'; 
import 'package:cached_network_image/cached_network_image.dart';

class EstablishmentListScreen extends StatefulWidget {
  final SubCategory subCategory;

  const EstablishmentListScreen({super.key, required this.subCategory});

  @override
  State<EstablishmentListScreen> createState() => _EstablishmentListScreenState();
}

class _EstablishmentListScreenState extends State<EstablishmentListScreen> {
  List<Establishment> _establishments = [];
  bool _isLoading = true;

// ... inside state class

  @override
  void initState() {
    super.initState();
    // Establishments are loaded in provider. We can filter them here or in build.
    // Using addPostFrameCallback to ensure context is available if we use Provider.of
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEstablishments();
    });
  }

  void _loadEstablishments() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    debugPrint("Filtering Est for SubCat ID: '${widget.subCategory.id}' (Name: ${widget.subCategory.name})");
    
    final list = provider.allEstablishments.where((e) {
       final match = e.subCategoryId == widget.subCategory.id;
       if (!match && e.subCategoryId == '1') { 
          // Debugging sample check
          // debugPrint("Mismatch: Est SubCat '${e.subCategoryId}' vs Target '${widget.subCategory.id}'");
       }
       return match;
    }).toList();
    
    debugPrint("Found ${list.length} establishments for this subcategory.");

    if (mounted) {
      setState(() {
        _establishments = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subCategory.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _establishments.isEmpty
              ? const Center(child: Text('No hay lugares en esta categoría.'))
              : AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _establishments.length,
                    itemBuilder: (context, index) {
                      final establishment = _establishments[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: GlassCard(
                                onTap: () {
                                  // Navigate to detail screen
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(
                                      builder: (_) => DetailScreen(establishment: establishment),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                      child: CachedNetworkImage(
                                        imageUrl: establishment.mainImage,
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(color: Colors.grey[300]),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            establishment.name,
                                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.star, color: Colors.amber, size: 16),
                                              Text(' ${establishment.rating}'),
                                              const SizedBox(width: 10),
                                              Text(establishment.priceRange, style: const TextStyle(color: Colors.green)),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            establishment.address,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
