import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/models.dart';
import '../services/mock_service.dart';
import '../widgets/glass_card.dart';
import '../config/theme.dart';
import 'establishment_list_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final Category category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  List<SubCategory> _subCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Data is already loaded in AppProvider and stitched into Category model
    _subCategories = widget.category.subCategories;
    _isLoading = false;
  }
/*
  Future<void> _loadSubCategories() async {
     // Removed MockService call
  }
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _subCategories.isEmpty
              ? const Center(child: Text('No hay subcategorías disponibles'))
              : AnimationLimiter(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _subCategories.length,
                    itemBuilder: (context, index) {
                      final sub = _subCategories[index];
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 375),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GlassCard(
                                onTap: () {
                                  // Navigate to filtered establishment list
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EstablishmentListScreen(subCategory: sub),
                                    ),
                                  );
                                },
                                child: ListTile(
                                  leading: Icon(widget.category.icon, color: AppTheme.primaryColor), // Reusing category icon
                                  title: Text(
                                    sub.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
