import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:reclaim/core/theme/app_theme.dart';
import 'package:reclaim/core/widgets/responsive_builder.dart';
import 'package:reclaim/core/widgets/responsive_scaffold.dart';
import 'package:reclaim/core/widgets/web_navbar.dart';
import 'package:reclaim/features/ecommerce/models/product.dart';
import 'package:reclaim/features/ecommerce/providers/local_cart_provider.dart';
import 'package:reclaim/features/ecommerce/providers/product_provider.dart';

// ─── Product model ────────────────────────────────────────────────────────────
class _P {
  final String name, category, condition, lab, imageUrl;
  final double price, rating, co2;
  final int stock;
  const _P(this.name, this.category, this.price, this.stock,
      this.rating, this.co2, this.imageUrl, this.condition, this.lab);
}

// ─── All catalogue products ───────────────────────────────────────────────────
const _products = [
  _P('Arduino Uno Rev3',        'Electronic', 449,  5,  4.8, 1.2, 'https://upload.wikimedia.org/wikipedia/commons/3/38/Arduino_Uno_-_R3.jpg', 'Excellent', 'Lab B – Electronics'),
  _P('Copper Wire Spool 1kg',   'Metal',      299,  3,  4.5, 0.8, 'images/copper.png',           'Good',      'Lab A – Chemistry'),
  _P('LED Strip 5m RGB',        'Electronic', 399,  7,  4.7, 0.3, 'images/led-strip.png',        'Like New',  'Workshop'),
  _P('Acrylic Sheet 60x90',     'Plastic',    199,  10, 4.2, 0.6, 'images/acrylic.png',          'Good',      'Design Studio'),
  _P('Steel Rod 1m',            'Metal',      149,  15, 4.0, 2.1, 'images/steelrod.png',         'Excellent', 'Mech Lab'),
  _P('Raspberry Pi 4 (2GB)',    'Electronic', 899,  2,  4.9, 0.9, 'images/rasberrypi.png',       'Like New',  'CS Lab'),
  _P('Borosilicate Flask 500ml','Chemical',   89,   20, 4.3, 0.2, 'images/borosilicateflask.png','Good',      'Chem Lab'),
  _P('Servo Motor SG90',        'Electronic', 129,  12, 4.4, 0.1, 'https://upload.wikimedia.org/wikipedia/commons/d/d1/MG996R_servo.jpg', 'Excellent', 'Robotics Lab'),
  _P('Plywood Sheet 4x8ft',     'Wood',       349,  4,  4.1, 3.5, 'https://upload.wikimedia.org/wikipedia/commons/1/1d/Plywood.jpg', 'Good',      'Workshop'),
  _P('Aluminium Tubing 1m',     'Metal',      219,  8,  4.6, 1.8, 'https://upload.wikimedia.org/wikipedia/commons/e/ef/Extruded_aluminium_section_x3.jpg', 'Like New',  'Aero Lab'),
  _P('ESP32 Dev Board',         'Electronic', 299,  6,  4.8, 0.1, 'https://upload.wikimedia.org/wikipedia/commons/c/c2/ESP32_Dev_Board.jpg', 'Excellent', 'IoT Lab'),
  _P('3D Printer Filament PLA', 'Plastic',    499,  9,  4.5, 0.7, 'https://upload.wikimedia.org/wikipedia/commons/3/3d/PLA_White_filament.jpg', 'Like New',  'Maker Space'),
  _P('Bench Power Supply',      'Electronic', 1299, 1,  4.7, 1.0, 'https://upload.wikimedia.org/wikipedia/commons/9/90/Bench_power_supply.jpg', 'Excellent', 'EE Lab'),
  _P('Soldering Station Kit',   'Electronic', 799,  3,  4.6, 0.5, 'https://upload.wikimedia.org/wikipedia/commons/5/5b/Hakko_936_soldering_station_complete.jpeg', 'Good',      'Workshop'),
  _P('Optical Lens Set',        'Chemical',   599,  5,  4.4, 0.3, 'https://upload.wikimedia.org/wikipedia/commons/3/32/Concave_lens.jpg', 'Like New',  'Physics Lab'),
  _P('Oak Wood Board 60cm',     'Wood',       189,  8,  4.2, 1.2, 'https://upload.wikimedia.org/wikipedia/commons/6/62/Quercus_robur_acorns_in_Tuntorp_1.jpg', 'Good',      'Carpentry Lab'),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class ProductCatalogScreen extends ConsumerStatefulWidget {
  const ProductCatalogScreen({super.key});
  @override
  ConsumerState<ProductCatalogScreen> createState() =>
      _ProductCatalogScreenState();
}

// Map a Supabase Product to the local _P display model
_P _fromProduct(Product p) => _P(
  p.name,
  p.type,
  p.basePrice,
  p.stockQuantity,
  p.rating ?? 4.0,
  p.carbonSaved,
  p.imageUrl ?? '',
  p.condition,
  p.location,
);

class _ProductCatalogScreenState extends ConsumerState<ProductCatalogScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  String? _category;
  String _sortBy = 'newest';
  RangeValues _priceRange = const RangeValues(0, 2000);

  // Starts with static data; replaced by Supabase records once loaded
  List<_P> _allProducts = _products;

  List<_P> get _filtered {
    var list = _allProducts.where((p) {
      final mQ =
          _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase());
      final mC = _category == null || p.category == _category;
      final mP = p.price >= _priceRange.start && p.price <= _priceRange.end;
      return mQ && mC && mP;
    }).toList();
    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.price.compareTo(b.price));
      case 'price_desc':
        list.sort((a, b) => b.price.compareTo(a.price));
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Breakpoints.isMobile(context);
    final cartCount = ref.watch(localCartCountProvider);

    // Keep product list in sync with Supabase; fall back to static data on error/empty
    ref.listen<AsyncValue<List<Product>>>(productsProvider, (_, next) {
      next.whenData((ps) {
        if (ps.isNotEmpty && mounted) {
          setState(() => _allProducts = ps.map(_fromProduct).toList());
        }
      });
    });

    return ResponsiveScaffold(
      currentRoute: '/shop',
      cartItemCount: cartCount,
      mobileAppBar: isMobile
          ? AppBar(
              backgroundColor: AppTheme.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              title: const Text('Shop',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              actions: [
                IconButton(
                  icon: Badge(
                      isLabelVisible: cartCount > 0,
                      label: Text('$cartCount'),
                      child: const Icon(Icons.shopping_bag_outlined)),
                  onPressed: () => context.go('/cart'),
                ),
              ],
            )
          : null,
      body: isMobile ? _buildMobile(context) : _buildDesktop(context),
    );
  }

  // ─── DESKTOP ──────────────────────────────────────────────────────────────
  Widget _buildDesktop(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
        child: Column(children: [
      _buildHero(context),
      Center(
          child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppTheme.contentMaxWidth(w)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 272, child: _buildSidebar(context)),
            const SizedBox(width: 28),
            Expanded(child: _buildGrid(context, desktop: true)),
          ]),
        ),
      )),
      const WebFooter(),
    ]));
  }

  // ─── HERO ─────────────────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context) => Container(
        width: double.infinity,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          colors: [Color(0xFF1B4332), Color(0xFF2D6A4F), Color(0xFF40916C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )),
        child: Stack(children: [
          Positioned(
              top: -60,
              right: -60,
              child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.04)))),
          Center(
              child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 56, vertical: 60),
              child: Row(children: [
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white30)),
                        child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.eco,
                                  size: 14, color: Colors.white70),
                              SizedBox(width: 6),
                              Text('Sustainable Materials Marketplace',
                                  style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500)),
                            ]),
                      ),
                      const SizedBox(height: 22),
                      const Text('Give Materials a\nSecond Life',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 46,
                              fontWeight: FontWeight.w900,
                              height: 1.12,
                              letterSpacing: -1)),
                      const SizedBox(height: 16),
                      const Text(
                          'Shop certified lab surplus — electronics, metals,\nchemicals and more at 60% below retail.',
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              height: 1.65)),
                      const SizedBox(height: 32),
                      _heroSearch(),
                    ])),
                const SizedBox(width: 48),
                Column(children: [
                  _heroBubble('1,200+', 'Materials Listed'),
                  const SizedBox(height: 16),
                  _heroBubble('850 kg', 'CO\u2082 Prevented'),
                  const SizedBox(height: 16),
                  _heroBubble('40+', 'Partner Labs'),
                ]),
              ]),
            ),
          )),
        ]),
      );

  Widget _heroSearch() => Container(
        height: 54,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10))
            ]),
        child: Row(children: [
          const SizedBox(width: 16),
          Icon(Icons.search, color: Colors.grey.shade400, size: 22),
          const SizedBox(width: 10),
          Expanded(
              child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Search materials, components, chemicals...',
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              contentPadding: EdgeInsets.zero,
            ),
            style: const TextStyle(fontSize: 15),
          )),
          Container(
              margin: const EdgeInsets.all(6),
              child: ElevatedButton(
                onPressed: () => setState(() {}),
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                child:
                    const Text('Search', style: TextStyle(color: Colors.white)),
              )),
        ]),
      );

  Widget _heroBubble(String v, String l) => Container(
        width: 150,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withValues(alpha: 0.28), Colors.white.withValues(alpha: 0.12)],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.20), blurRadius: 18, offset: const Offset(0, 7))]),
        child: Column(children: [
          Text(v,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  shadows: [Shadow(color: Colors.black38, blurRadius: 4)])),
          const SizedBox(height: 5),
          Text(l,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center),
        ]),
      );

  // ─── SIDEBAR ──────────────────────────────────────────────────────────────
  Widget _buildSidebar(BuildContext context) {
    const cats = ['Electronic', 'Metal', 'Plastic', 'Chemical', 'Wood'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _sCard('Browse Category', [
        _cTile(null, 'All Categories', Icons.grid_view_rounded),
        ...cats.map((c) => _cTile(c, c, _cIcon(c))),
      ]),
      const SizedBox(height: 14),
      _sCard('Price Range', [
        RangeSlider(
            values: _priceRange,
            min: 0,
            max: 2000,
            divisions: 20,
            activeColor: AppTheme.primaryGreen,
            labels: RangeLabels('Rs.${_priceRange.start.round()}',
                'Rs.${_priceRange.end.round()}'),
            onChanged: (v) => setState(() => _priceRange = v)),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Rs.${_priceRange.start.round()}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
          Text('Rs.${_priceRange.end.round()}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ]),
      ]),
      const SizedBox(height: 14),
      _sCard('Condition', [
        for (final c in ['Like New', 'Excellent', 'Good'])
          CheckboxListTile(
              dense: true,
              value: true,
              title: Text(c, style: const TextStyle(fontSize: 13)),
              activeColor: AppTheme.primaryGreen,
              onChanged: (_) {},
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero),
      ]),
      const SizedBox(height: 14),
      // Eco info card
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)]),
            borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.eco, color: Colors.white, size: 28),
          const SizedBox(height: 10),
          const Text('Every purchase saves CO\u2082',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          const SizedBox(height: 6),
          Text(
              'Materials on Reclaim prevent an average of 1.2 kg CO\u2082 per item from reaching landfill.',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                  height: 1.5)),
        ]),
      ),
    ]);
  }

  Widget _sCard(String title, List<Widget> children) => Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5EFE8)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Text(title,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary))),
          const Divider(height: 1, color: Color(0xFFEAF1EB)),
          Padding(
              padding: const EdgeInsets.all(10),
              child: Column(children: children)),
        ]),
      );

  Widget _cTile(String? val, String label, IconData ic) {
    final sel = _category == val;
    return InkWell(
      onTap: () => setState(() => _category = val),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
            color: sel ? AppTheme.primarySurface : Colors.transparent,
            borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Icon(ic,
              size: 17,
              color:
                  sel ? AppTheme.primaryGreen : Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
                      color: sel
                          ? AppTheme.primaryGreen
                          : AppTheme.textPrimary))),
          if (sel)
            const Icon(Icons.check_circle,
                size: 16, color: AppTheme.primaryGreen),
        ]),
      ),
    );
  }

  IconData _cIcon(String c) => switch (c) {
        'Electronic' => Icons.memory,
        'Metal' => Icons.hardware,
        'Plastic' => Icons.recycling,
        'Chemical' => Icons.science,
        'Wood' => Icons.forest,
        _ => Icons.category,
      };

  // ─── GRID ─────────────────────────────────────────────────────────────────
  Widget _buildGrid(BuildContext context, {required bool desktop}) {
    final products = _filtered;
    final w = MediaQuery.of(context).size.width;
    final cols = desktop ? (w >= 1400 ? 4 : 3) : 2;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        RichText(
            text: TextSpan(children: [
          TextSpan(
              text: '${products.length}',
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppTheme.textPrimary)),
          TextSpan(
              text: ' products found',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ])),
        _sortDD(),
      ]),
      const SizedBox(height: 20),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            childAspectRatio: desktop ? 0.68 : 0.66,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16),
        itemCount: products.length,
        itemBuilder: (_, i) =>
            _ProductCard(p: products[i], desktop: desktop),
      ),
    ]);
  }

  Widget _sortDD() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD4E6DA))),
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          value: _sortBy,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary),
          items: const [
            DropdownMenuItem(value: 'newest', child: Text('Newest First')),
            DropdownMenuItem(
                value: 'price_asc', child: Text('Price: Low \u2192 High')),
            DropdownMenuItem(
                value: 'price_desc', child: Text('Price: High \u2192 Low')),
            DropdownMenuItem(value: 'rating', child: Text('Top Rated')),
          ],
          onChanged: (v) => setState(() => _sortBy = v!),
        )),
      );

  // ─── MOBILE ───────────────────────────────────────────────────────────────
  Widget _buildMobile(BuildContext context) {
    final products = _filtered;
    final cats = [null, 'Electronic', 'Metal', 'Plastic', 'Chemical', 'Wood'];
    final lbls = ['All', 'Electronic', 'Metal', 'Plastic', 'Chemical', 'Wood'];
    return Column(children: [
      Container(
          color: AppTheme.primaryGreen,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              const SizedBox(width: 12),
              Icon(Icons.search, color: Colors.grey.shade400, size: 20),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                    hintText: 'Search materials...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    isDense: true),
                style: const TextStyle(fontSize: 14),
              )),
            ]),
          )),
      SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            itemCount: cats.length,
            itemBuilder: (_, i) {
              final sel = _category == cats[i];
              return GestureDetector(
                onTap: () => setState(() => _category = cats[i]),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: sel ? AppTheme.primaryGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel
                                ? AppTheme.primaryGreen
                                : const Color(0xFFD4E6DA))),
                    child: Center(
                        child: Text(lbls[i],
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: sel
                                    ? Colors.white
                                    : AppTheme.textSecondary)))),
              );
            },
          )),
      Expanded(
          child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10),
        itemCount: products.length,
        itemBuilder: (_, i) =>
            _ProductCard(p: products[i], desktop: false),
      )),
    ]);
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────
class _ProductCard extends ConsumerStatefulWidget {
  final _P p;
  final bool desktop;
  const _ProductCard({required this.p, required this.desktop});
  @override
  ConsumerState<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<_ProductCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  bool _added = false;
  late AnimationController _bump;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _bump = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _bump, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bump.dispose();
    super.dispose();
  }

  Color get _condColor => switch (widget.p.condition) {
        'Like New' => const Color(0xFF2D6A4F),
        'Excellent' => const Color(0xFF1565C0),
        _ => const Color(0xFFE65100),
      };

  void _addToCart() async {
    _bump.forward().then((_) => _bump.reverse());
    ref.read(localCartProvider.notifier).add(LocalCartItem(
          id: widget.p.name,
          name: widget.p.name,
          imageUrl: widget.p.imageUrl,
          price: widget.p.price,
          category: widget.p.category,
          condition: widget.p.condition,
          lab: widget.p.lab,
          rating: widget.p.rating,
          co2: widget.p.co2,
        ));
    setState(() => _added = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Text('${widget.p.name} added to cart!',
                  style: const TextStyle(fontWeight: FontWeight.w600))),
        ]),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: Colors.white,
          onPressed: () => GoRouter.of(context).go('/cart'),
        ),
      ));
    }
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _added = false);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(0.0, _hovered ? -6.0 : 0.0, 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _hovered
                  ? AppTheme.primaryLight
                  : const Color(0xFFE5EFE8),
              width: _hovered ? 1.5 : 1.0),
          boxShadow: [
            BoxShadow(
                color: _hovered
                    ? AppTheme.primaryGreen.withValues(alpha: 0.16)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: _hovered ? 28 : 12,
                offset: Offset(0, _hovered ? 12 : 4))
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Image ──
                Expanded(
                    flex: widget.desktop ? 5 : 4,
                    child: GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        barrierColor: Colors.black54,
                        builder: (_) => _ProductDetailDialog(p: widget.p),
                      ),
                      child: Stack(children: [
                      // Product image
                      Positioned.fill(
                          child: widget.p.imageUrl.startsWith('http')
                              ? Image.network(
                                  widget.p.imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (_, child, prog) => prog == null
                                      ? child
                                      : Container(
                                          color: AppTheme.primarySurface,
                                          child: Center(
                                              child: CircularProgressIndicator(
                                                  value: prog.expectedTotalBytes != null
                                                      ? prog.cumulativeBytesLoaded /
                                                          prog.expectedTotalBytes!
                                                      : null,
                                                  color: AppTheme.primaryGreen,
                                                  strokeWidth: 2))),
                                  errorBuilder: (_, __, ___) => Container(
                                      color: AppTheme.primarySurface,
                                      child: const Center(
                                          child: Icon(
                                              Icons.image_not_supported_outlined,
                                              size: 36,
                                              color: AppTheme.primaryLight))),
                                )
                              : Image.asset(
                                  widget.p.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                      color: AppTheme.primarySurface,
                                      child: const Center(
                                          child: Icon(
                                              Icons.image_not_supported_outlined,
                                              size: 36,
                                              color: AppTheme.primaryLight))),
                                )),

                      // Gradient overlay on hover
                      if (_hovered)
                        Positioned.fill(
                            child: Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                              Colors.transparent,
                              AppTheme.primaryDark.withValues(alpha: 0.35)
                            ])))),
                      // Condition badge
                      Positioned(
                          top: 10,
                          left: 10,
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: _condColor,
                                  borderRadius: BorderRadius.circular(6)),
                              child: Text(widget.p.condition,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700)))),
                      // Eco badge
                      Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                  color:
                                      Colors.white.withValues(alpha: 0.92),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.eco,
                                        size: 10,
                                        color: AppTheme.primaryGreen),
                                    const SizedBox(width: 3),
                                    Text(
                                        '${widget.p.co2}kg CO\u2082',
                                        style: const TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: AppTheme.primaryGreen)),
                                  ]))),
                      // "Added!" overlay
                      if (_added)
                        Positioned.fill(
                            child: Container(
                          color:
                              AppTheme.primaryGreen.withValues(alpha: 0.85),
                          child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.white, size: 36),
                                SizedBox(height: 6),
                                Text('Added to Cart!',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14)),
                              ]),
                        )),
                    ])),  // close Stack children + Stack + GestureDetector
                ),  // close Expanded

                // ── Info ──
                Padding(
                  padding:
                      EdgeInsets.all(widget.desktop ? 14 : 10),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.p.name,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: widget.desktop ? 14 : 13,
                                color: AppTheme.textPrimary,
                                height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 3),
                        Row(children: [
                          Icon(Icons.location_pin,
                              size: 11, color: Colors.grey.shade500),
                          const SizedBox(width: 2),
                          Expanded(
                              child: Text(widget.p.lab,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500),
                                  overflow: TextOverflow.ellipsis)),
                        ]),
                        const SizedBox(height: 8),
                        Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                Icon(Icons.star_rounded,
                                    size: 13,
                                    color: Colors.amber.shade600),
                                const SizedBox(width: 3),
                                Text('${widget.p.rating}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.textPrimary)),
                                const SizedBox(width: 4),
                                Text('(${widget.p.stock})',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade500)),
                              ]),
                              Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                      color: AppTheme.primarySurface,
                                      borderRadius:
                                          BorderRadius.circular(4)),
                                  child: Text(widget.p.category,
                                      style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color:
                                              AppTheme.primaryGreen))),
                            ]),
                        const SizedBox(height: 10),
                        Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                  'Rs.${widget.p.price.toStringAsFixed(0)}',
                                  style: TextStyle(
                                      fontSize:
                                          widget.desktop ? 18 : 16,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primaryGreen)),
                              ScaleTransition(
                                  scale: _scale,
                                  child: GestureDetector(
                                    onTap: _addToCart,
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 150),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                          color: _added
                                              ? AppTheme.primaryDark
                                              : (_hovered
                                                  ? AppTheme.primaryDark
                                                  : AppTheme
                                                      .primaryGreen),
                                          borderRadius:
                                              BorderRadius.circular(9),
                                          boxShadow: [
                                            BoxShadow(
                                                color: AppTheme
                                                    .primaryGreen
                                                    .withValues(
                                                        alpha: 0.35),
                                                blurRadius: 8,
                                                offset:
                                                    const Offset(0, 3))
                                          ]),
                                      child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                                _added
                                                    ? Icons.check
                                                    : Icons
                                                        .add_shopping_cart_outlined,
                                                color: Colors.white,
                                                size: 14),
                                            const SizedBox(width: 5),
                                            Text(
                                                _added ? 'Added' : 'Add',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.w700,
                                                    fontSize: 12)),
                                          ]),
                                    ),
                                  )),
                            ]),
                      ]),
                ),
              ]),
        ),
      ),
    );
  }
}

// ─── Product Detail Dialog ────────────────────────────────────────────────────
class _ProductDetailDialog extends ConsumerWidget {
  final _P p;
  const _ProductDetailDialog({required this.p, super.key});

  static const Map<String, List<(String, String, String)>> _history = {
    'Electronic': [
      ('Smart Greenhouse Monitor', 'IoT & Automation Club', 'Jan 2025'),
      ('Arduino-based Spectrometer', 'Physics Research Dept.', 'Sep 2024'),
      ('Campus EV Charge Station', 'Sustainability Initiative', 'Jun 2024'),
    ],
    'Metal': [
      ('CNC Machine Retrofit', 'Mechanical Eng. Dept.', 'Feb 2025'),
      ('Lab Safety Enclosure', 'Campus Safety Division', 'Oct 2024'),
      ('Carbon Capture Prototype', 'Environmental Eng.', 'Jul 2024'),
    ],
    'Chemical': [
      ('Water Quality Analysis Kit', 'Environmental Science', 'Mar 2025'),
      ('pH Testing Station', 'Chemistry Lab A', 'Nov 2024'),
      ('Polymer Synthesis Study', 'Material Science Dept.', 'Aug 2024'),
    ],
    'Plastic': [
      ('Biodegradable Packaging Proto', 'Eco Design Club', 'Feb 2025'),
      ('Robotic Arm Casing', 'Robotics Club', 'Dec 2024'),
      ('Recycled Art Installation', 'Campus Art Week', 'Sep 2024'),
    ],
    'Wood': [
      ('Library Study Pods', 'Campus Spaces Team', 'Jan 2025'),
      ('Exhibition Display Stand', 'Annual Science Fair', 'Oct 2024'),
      ('Seed Germination Lab Setup', 'Botany Research Lab', 'Jun 2024'),
    ],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final condColor = switch (p.condition) {
      'Like New' => const Color(0xFF2D6A4F),
      'Excellent' => const Color(0xFF1565C0),
      _ => const Color(0xFFE65100),
    };
    final projects = _history[p.category] ?? _history['Electronic']!;
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;
    final isWide = sw > 640;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      insetPadding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 660, maxHeight: sh * 0.88),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // ── Image header ────────────────────────────────────────────────────
          Stack(children: [
            SizedBox(
              height: 220, width: double.infinity,
              child: p.imageUrl.startsWith('http')
                  ? Image.network(p.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.primarySurface,
                        child: const Icon(Icons.image_not_supported_outlined, size: 60, color: AppTheme.primaryLight)))
                  : Image.asset(p.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppTheme.primarySurface,
                        child: const Icon(Icons.image_not_supported_outlined, size: 60, color: AppTheme.primaryLight))),
            ),
            // gradient overlay
            Positioned.fill(child: Container(
              decoration: const BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0xDD1B4332)])))),
            // close button
            Positioned(top: 12, right: 12, child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(width: 34, height: 34,
                decoration: const BoxDecoration(color: Colors.black38, shape: BoxShape.circle),
                child: const Icon(Icons.close, color: Colors.white, size: 18)))),
            // top badges
            Positioned(top: 12, left: 14, child: Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: condColor, borderRadius: BorderRadius.circular(6)),
                child: Text(p.condition, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700))),
              const SizedBox(width: 6),
              Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(6)),
                child: Text(p.category, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600))),
            ])),
            // name + lab overlay at bottom
            Positioned(bottom: 14, left: 16, right: 56, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 20,
                fontWeight: FontWeight.w800, height: 1.2,
                shadows: [Shadow(color: Colors.black54, blurRadius: 8)])),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on, size: 13, color: Colors.white70),
                const SizedBox(width: 3),
                Text(p.lab, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ])),
          ]),

          // ── Scrollable body ──────────────────────────────────────────────────
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // price + rating
              Row(children: [
                Text('Rs.${p.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.primaryGreen)),
                const Spacer(),
                Row(children: [
                  Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 18),
                  const SizedBox(width: 4),
                  Text('${p.rating}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(width: 6),
                  Text('(${p.stock} in stock)', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ]),
              ]),
              const SizedBox(height: 16),

              // eco impact card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B4332), Color(0xFF2D6A4F)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Container(width: 40, height: 40,
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                    child: const Icon(Icons.eco, color: Colors.white, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Eco Impact', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                    Text('Saves ${p.co2} kg CO₂ compared to buying new',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                  ])),
                  Column(children: [
                    Text('${p.co2}', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                    const Text('kg CO₂', style: TextStyle(color: Colors.white60, fontSize: 10)),
                  ]),
                ]),
              ),
              const SizedBox(height: 16),

              // spec tiles
              Row(children: [
                Expanded(child: _specTile(Icons.inventory_2_outlined, 'Condition', p.condition)),
                const SizedBox(width: 10),
                Expanded(child: _specTile(Icons.category_outlined, 'Type', p.category)),
                const SizedBox(width: 10),
                Expanded(child: _specTile(Icons.science_outlined, 'From Lab', p.lab.split('–').last.trim())),
              ]),
              const SizedBox(height: 22),

              // project history
              Row(children: [
                const Icon(Icons.history_edu_outlined, size: 18, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                const Text('Previously Used In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
              ]),
              const SizedBox(height: 4),
              Text('This material was reused in these campus projects',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 14),
              ...projects.indexed.map((e) => _projectTile(e.$1, e.$2)),
              const SizedBox(height: 12),
            ]),
          )),

          // ── Footer CTA ────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE5EFE8))),
              color: Colors.white),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Rs.${p.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.primaryGreen)),
                Text('${p.stock} available · Free campus delivery',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ])),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(localCartProvider.notifier).add(LocalCartItem(
                    id: p.name, name: p.name, imageUrl: p.imageUrl, price: p.price,
                    category: p.category, condition: p.condition, lab: p.lab,
                    rating: p.rating, co2: p.co2,
                  ));
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Row(children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${p.name} added!', style: const TextStyle(fontWeight: FontWeight.w600))),
                    ]),
                    backgroundColor: AppTheme.primaryGreen,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    duration: const Duration(seconds: 2),
                  ));
                },
                icon: const Icon(Icons.add_shopping_cart_outlined, size: 16),
                label: const Text('Add to Cart', style: TextStyle(fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 3, shadowColor: AppTheme.primaryGreen.withValues(alpha: 0.4)),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _specTile(IconData ic, String label, String value) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(10)),
    child: Column(children: [
      Icon(ic, color: AppTheme.primaryGreen, size: 20),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryDark),
        textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
    ]),
  );

  Widget _projectTile(int idx, (String, String, String) proj) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE5EFE8)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Row(children: [
      Container(width: 36, height: 36,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.primaryGreen, AppTheme.primaryLight]),
          borderRadius: BorderRadius.circular(9)),
        child: Center(child: Text('${idx + 1}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(proj.$1, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimary)),
        const SizedBox(height: 3),
        Row(children: [
          Icon(Icons.laptop_outlined, size: 11, color: Colors.grey.shade400),
          const SizedBox(width: 4),
          Flexible(child: Text(proj.$2, style: TextStyle(fontSize: 11, color: Colors.grey.shade500), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Container(width: 3, height: 3, decoration: BoxDecoration(color: Colors.grey.shade400, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(proj.$3, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
        ]),
      ])),
      const Icon(Icons.verified_outlined, size: 16, color: AppTheme.primaryGreen),
    ]),
  );
}
