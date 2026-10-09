import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Flutter POS',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
      ),
      home: const PointOfSaleScreen(),
    );
  }
}

// Data model representing the product inventory
class Product {
  final String id;
  final String name;
  final double price;
  final IconData icon;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.icon,
  });
}

class PointOfSaleScreen extends StatefulWidget {
  const PointOfSaleScreen({super.key});

  @override
  State<PointOfSaleScreen> createState() => _PointOfSaleScreenState();
}

class _PointOfSaleScreenState extends State<PointOfSaleScreen> {
  // 1. Available Product Menu
  final List<Product> _products = const [
    Product(id: '1', name: 'Coffee', price: 3.50, icon: Icons.coffee),
    Product(id: '2', name: 'Croissant', price: 2.75, icon: Icons.bakery_dining),
    Product(id: '3', name: 'Sandwich', price: 6.25, icon: Icons.lunch_dining),
    Product(id: '4', name: 'Soda', price: 1.80, icon: Icons.local_drink),
    Product(id: '5', name: 'Muffin', price: 3.00, icon: Icons.cake),
  ];

  // 2. Order Cart Tracking (Product ID -> Quantity Selected)
  final Map<String, int> _cart = {};

  // Method to increment quantity when an item button is pressed
  void _addItem(String productId) {
    setState(() {
      _cart[productId] = (_cart[productId] ?? 0) + 1;
    });
  }

  // Method to decrement quantity
  void _removeItem(String productId) {
    setState(() {
      if (_cart.containsKey(productId)) {
        if (_cart[productId] == 1) {
          _cart.remove(productId);
        } else {
          _cart[productId] = _cart[productId]! - 1;
        }
      }
    });
  }

  // Clear current bill
  void _clearOrder() {
    setState(() {
      _cart.clear();
    });
  }

  // Helper calculation to sum up all selected items
  double _calculateTotal() {
    double total = 0.0;
    _cart.forEach((productId, quantity) {
      final product = _products.firstWhere((p) => p.id == productId);
      total += product.price * quantity;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final double totalCost = _calculateTotal();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Point of Sale (POS)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear Order',
            onPressed: _clearOrder,
          )
        ],
      ),
      body: Column(
        children: [
          // TOP HALF: Grid Menu of Items to Press
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(12.0),
              color: Colors.grey[100],
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // Three item shortcut buttons per row
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  final currentQty = _cart[product.id] ?? 0;

                  return Card(
                    elevation: currentQty > 0 ? 4 : 1,
                    color: currentQty > 0 ? Colors.teal[50] : Colors.white,
                    shape: RoundedByBorderSideStyle(currentQty > 0),
                    child: InkWell(
                      onTap: () => _addItem(product.id),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Badge(
                              label: Text('$currentQty'),
                              isLabelVisible: currentQty > 0,
                              backgroundColor: Colors.teal,
                              child: Icon(product.icon, size: 36, color: Colors.teal[800]),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          const Divider(height: 1, thickness: 2),

          // BOTTOM HALF: Live Bill of Materials (BOM)
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: _cart.isEmpty
                  ? const Center(
                      child: Text(
                        'No items selected.\nTap on menu items above to begin a bill.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView(
                      children: [
                        const Text(
                          'Bill of Materials',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ..._cart.entries.map((entry) {
                          final product = _products.firstWhere((p) => p.id == entry.key);
                          final qty = entry.value;
                          final subtotal = product.price * qty;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    '${product.name} x$qty',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20, color: Colors.red),
                                  onPressed: () => _removeItem(product.id),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20, color: Colors.green),
                                  onPressed: () => _addItem(product.id),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '\$${subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
            ),
          ),

          // CHECKOUT BANNER: Running Total Summary
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('TOTAL DUE', style: TextStyle(fontSize: 12, color: Colors.grey, letterSpacing: 1)),
                      Text(
                        '\$${totalCost.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _cart.isEmpty
                        ? null
                        : () {
                          ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text('Order Processed Successfully! Total: ${totalCost.toStringAsFixed(2)}'),
backgroundColor: Colors.teal,
),
);
_clearOrder();
},
icon: const Icon(Icons.point_of_sale),
label: const Text('Charge', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
),
],
),
),
)
],
),
);
}
// Custom helper border logic for selected visual cards
RoundedRectangleBorder RoundedByBorderSideStyle(bool isSelected) {
return RoundedRectangleBorder(
borderRadius: BorderRadius.circular(12),
side: BorderSide(
color: isSelected ? Colors.teal : Colors.transparent,
width: 2,
),
);
}
}
