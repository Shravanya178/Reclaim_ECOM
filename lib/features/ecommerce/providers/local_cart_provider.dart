import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Local Cart Item Model ────────────────────────────────────────────────────
class LocalCartItem {
  final String id; // unique key = product name
  final String name;
  final String imageUrl;
  final double price;
  final String category;
  final String condition;
  final String lab;
  final double rating;
  final double co2;
  int quantity;

  LocalCartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.condition,
    required this.lab,
    required this.rating,
    required this.co2,
    this.quantity = 1,
  });

  LocalCartItem copyWith({int? quantity}) => LocalCartItem(
    id: id, name: name, imageUrl: imageUrl, price: price,
    category: category, condition: condition, lab: lab,
    rating: rating, co2: co2, quantity: quantity ?? this.quantity,
  );
}

// ─── Cart Notifier ────────────────────────────────────────────────────────────
class LocalCartNotifier extends StateNotifier<List<LocalCartItem>> {
  LocalCartNotifier() : super([]);

  void add(LocalCartItem item) {
    final idx = state.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      final updated = List<LocalCartItem>.from(state);
      updated[idx] = updated[idx].copyWith(quantity: updated[idx].quantity + item.quantity);
      state = updated;
    } else {
      state = [...state, item];
    }
  }

  void remove(String id) {
    state = state.where((i) => i.id != id).toList();
  }

  void updateQty(String id, int qty) {
    if (qty <= 0) { remove(id); return; }
    state = state.map((i) => i.id == id ? i.copyWith(quantity: qty) : i).toList();
  }

  void clear() => state = [];
}

// ─── Providers ────────────────────────────────────────────────────────────────
final localCartProvider = StateNotifierProvider<LocalCartNotifier, List<LocalCartItem>>(
  (ref) => LocalCartNotifier(),
);

final localCartCountProvider = Provider<int>((ref) {
  return ref.watch(localCartProvider).fold(0, (sum, i) => sum + i.quantity);
});

final localCartTotalProvider = Provider<double>((ref) {
  return ref.watch(localCartProvider).fold(0.0, (sum, i) => sum + i.price * i.quantity);
});
