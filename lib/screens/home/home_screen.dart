import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../widgets/cart_badge.dart';
import '../product_detail/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _bannerController = PageController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _bannerTimer;
  bool _isSearchBarSolid = false;
  int _currentBanner = 0;
  String _searchQuery = '';
  String? _selectedCategory;

  final List<String> _bannerImages = const [
    'https://images.unsplash.com/photo-1498049794561-7780e7231661?w=1200',
    'https://images.unsplash.com/photo-1512436991641-6745cdb1723f?w=1200',
    'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1200',
    'https://images.unsplash.com/photo-1555529669-e69e7aa0ba9a?w=1200',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
    });
    _scrollController.addListener(_onScroll);
    _startBannerAutoPlay();
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _bannerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final makeSolid =
        _scrollController.hasClients && _scrollController.offset > 16;
    if (makeSolid != _isSearchBarSolid) {
      setState(() {
        _isSearchBarSolid = makeSolid;
      });
    }

    if (!_scrollController.hasClients) {
      return;
    }

    if (_selectedCategory != null) {
      return;
    }

    final threshold = _scrollController.position.maxScrollExtent - 300;
    if (_scrollController.position.pixels >= threshold) {
      context.read<ProductProvider>().loadMoreProducts();
    }
  }

  void _startBannerAutoPlay() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_bannerController.hasClients) {
        return;
      }

      final nextPage = (_currentBanner + 1) % _bannerImages.length;
      _bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    });
  }

  List<Product> _filterProducts(List<Product> products) {
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      return products
          .where((product) => product.category == _selectedCategory)
          .take(6)
          .toList();
    }

    if (_searchQuery.trim().isEmpty) {
      return products;
    }

    final keyword = _searchQuery.toLowerCase().trim();
    return products.where((product) {
      return product.title.toLowerCase().contains(keyword) ||
          product.category.toLowerCase().contains(keyword);
    }).toList();
  }

  IconData _iconForCategory(String category) {
    final normalized = category.toLowerCase();
    if (normalized.contains('smartphones') || normalized.contains('laptops')) {
      return Icons.devices_outlined;
    }
    if (normalized.contains('fragrances') || normalized.contains('beauty')) {
      return Icons.spa_outlined;
    }
    if (normalized.contains('groceries') || normalized.contains('kitchen')) {
      return Icons.local_grocery_store_outlined;
    }
    if (normalized.contains('furniture') || normalized.contains('home')) {
      return Icons.chair_outlined;
    }
    if (normalized.contains('tops') ||
        normalized.contains('shirts') ||
        normalized.contains('dress') ||
        normalized.contains('clothing')) {
      return Icons.checkroom_outlined;
    }
    if (normalized.contains('shoes')) return Icons.hiking_outlined;
    if (normalized.contains('bag')) return Icons.shopping_bag_outlined;
    if (normalized.contains('watch')) return Icons.watch_outlined;
    if (normalized.contains('jewellery') || normalized.contains('jewelery')) {
      return Icons.diamond_outlined;
    }
    return Icons.category_outlined;
  }

  String _labelForCategory(String category) {
    return category
        .split('-')
        .where((part) => part.isNotEmpty)
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appBarColor = _isSearchBarSolid
        ? theme.colorScheme.primary
        : Colors.white;
    final titleColor = _isSearchBarSolid ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          final sourceProducts = _selectedCategory == null
              ? provider.products
              : provider.allProducts;
          final filteredProducts = _filterProducts(sourceProducts);
          final categories = provider.categories;

          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: provider.refreshProducts,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  pinned: true,
                  elevation: _isSearchBarSolid ? 2 : 0,
                  expandedHeight: 118,
                  backgroundColor: appBarColor,
                  surfaceTintColor: Colors.transparent,
                  titleSpacing: 12,
                  title: Text(
                    'TH4 - Nhóm 5',
                    style: TextStyle(
                      color: titleColor,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CartBadge(
                        onTap: () => Navigator.pushNamed(context, '/cart'),
                        iconColor: _isSearchBarSolid
                            ? theme.colorScheme.primary
                            : Colors.black87,
                        badgeColor: Colors.red,
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(56),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                            hintText: 'Tìm kiếm sản phẩm',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            hintStyle: TextStyle(color: Colors.grey.shade600),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _BannerSlider(
                    bannerImages: _bannerImages,
                    controller: _bannerController,
                    currentIndex: _currentBanner,
                    onPageChanged: (value) {
                      setState(() {
                        _currentBanner = value;
                      });
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Text(
                      'Danh mục sản phẩm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _CategorySection(
                    categories: categories,
                    selectedCategory: _selectedCategory,
                    iconBuilder: _iconForCategory,
                    labelBuilder: _labelForCategory,
                    onCategoryTap: (category) {
                      final nextCategory = _selectedCategory == category
                          ? null
                          : category;

                      setState(() {
                        _selectedCategory = nextCategory;
                        if (nextCategory != null) {
                          _searchController.clear();
                          _searchQuery = '';
                        }
                      });
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Text(
                      'Gợi ý hôm nay',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (provider.errorMessage != null && provider.products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(provider.errorMessage ?? 'Đã xảy ra lỗi.'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: provider.refreshProducts,
                            child: const Text('Tải lại'),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (filteredProducts.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text('Không tìm thấy sản phẩm phù hợp.'),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid.builder(
                      itemCount: filteredProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.63,
                          ),
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return _ProductCard(product: product);
                      },
                    ),
                  ),
                if (provider.isLoadingMore && _selectedCategory == null)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BannerSlider extends StatelessWidget {
  const _BannerSlider({
    required this.bannerImages,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<String> bannerImages;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: PageView.builder(
                controller: controller,
                itemCount: bannerImages.length,
                onPageChanged: onPageChanged,
                itemBuilder: (context, index) {
                  return Image.network(
                    bannerImages[index],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Container(
                        color: Colors.black12,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.black12,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported_outlined),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              bannerImages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: currentIndex == index ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: currentIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.black26,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryTap,
    required this.iconBuilder,
    required this.labelBuilder,
  });

  final List<String> categories;
  final String? selectedCategory;
  final ValueChanged<String> onCategoryTap;
  final IconData Function(String category) iconBuilder;
  final String Function(String category) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: SizedBox(
        height: 170,
        child: GridView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = category == selectedCategory;

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => onCategoryTap(category),
              child: Ink(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconBuilder(category),
                      size: 26,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labelBuilder(category),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  static const List<String> _tags = ['Mall', 'Yêu thích', 'Giảm 50%'];

  String _soldLabel(int id) {
    final sold = ((id * 137) % 4000) + 80;
    if (sold >= 1000) {
      return 'Đã bán ${(sold / 1000).toStringAsFixed(1)}k';
    }
    return 'Đã bán $sold';
  }

  @override
  Widget build(BuildContext context) {
    final tag = _tags[product.id % _tags.length];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Hero(
                  tag: 'product-image-${product.id}',
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        product.image,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Container(color: Colors.black12),
                              const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ],
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.black12,
                            alignment: Alignment.center,
                            child: const Icon(Icons.broken_image_outlined),
                          );
                        },
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.redAccent,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _soldLabel(product.id),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
