import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import 'forms/category_form.dart';
import 'forms/subcategory_form.dart';
import 'forms/establishment_form.dart';
import 'forms/banner_form.dart';

class AdminPanel extends StatelessWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Panel Administrativo'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Categorías'),
              Tab(text: 'Subcategorías'),
              Tab(text: 'Lugares'),
              Tab(text: 'Banners'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _CategoriesManager(),
            _SubCategoriesManager(),
            _EstablishmentsManager(),
            _BannersManager(),
          ],
        ),
      ),
    );
  }
}

class _CategoriesManager extends StatelessWidget {
  const _CategoriesManager();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: provider.categories.length,
        itemBuilder: (context, index) {
          final cat = provider.categories[index];
          return ListTile(
            leading: Icon(cat.icon),
            title: Text(cat.name),
            subtitle: Text('${cat.subCategories.length} subcategorías'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue), 
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryForm(category: cat)));
                  }
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red), 
                  onPressed: () {
                    // Confirm dialog? For now direct
                    provider.deleteCategory(cat.id);
                  }
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SubCategoriesManager extends StatelessWidget {
  const _SubCategoriesManager();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    // Flatten subcategories for display
    final List<Map<String, dynamic>> flatSubs = [];
    for (var cat in provider.categories) {
      for (var sub in cat.subCategories) {
        flatSubs.add({'sub': sub, 'parentName': cat.name, 'parent': cat});
      }
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const SubCategoryForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: flatSubs.length,
        itemBuilder: (context, index) {
          final item = flatSubs[index];
          final SubCategory sub = item['sub'];
          final String parentName = item['parentName'];
          
          return ListTile(
            title: Text(sub.name),
            subtitle: Text('En: $parentName'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                 IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue), 
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => SubCategoryForm(subCategory: sub)));
                  }
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red), 
                  onPressed: () {
                    provider.deleteSubCategory(sub.id, sub.parentId);
                  }
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EstablishmentsManager extends StatelessWidget {
  const _EstablishmentsManager();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final establishments = provider.allEstablishments;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const EstablishmentForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: establishments.length, 
        itemBuilder: (context, index) {
          final est = establishments[index];
          // Find category name for context
          final cat = provider.categories.firstWhere((c) => c.id == est.categoryId, orElse: () => Category(id: '', name: 'Unknown', icon: Icons.error));
          
          return ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                est.mainImage, 
                width: 50, 
                height: 50, 
                fit: BoxFit.cover, 
                errorBuilder: (c,e,s) => const Icon(Icons.error),
              ),
            ),
            title: Text(est.name),
            subtitle: Text('$cat.name | ${est.rating} ★'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                 IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue), 
                  onPressed: () {
                     Navigator.push(context, MaterialPageRoute(builder: (_) => EstablishmentForm(establishment: est)));
                  }
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red), 
                  onPressed: () {
                    provider.deleteEstablishment(est.id);
                  }
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BannersManager extends StatelessWidget {
  const _BannersManager();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           Navigator.push(context, MaterialPageRoute(builder: (_) => const BannerForm()));
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: provider.banners.length,
        itemBuilder: (context, index) {
          final banner = provider.banners[index];
          return ListTile(
            leading: Image.network(banner.imageUrl, width: 100, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.image)),
            title: Text(banner.title),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red), 
              onPressed: () {
                provider.deleteBanner(banner.id);
              }
            ),
          );
        },
      ),
    );
  }
}
