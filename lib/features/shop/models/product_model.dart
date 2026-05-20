class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final List<String> sizes;
  final String? category;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.sizes,
    this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'sizes': sizes,
      'category': category,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      sizes: List<String>.from(map['sizes'] ?? []),
      category: map['category'],
    );
  }

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? imageUrl,
    String? description,
    List<String>? sizes,
    String? category,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      sizes: sizes ?? this.sizes,
      category: category ?? this.category,
    );
  }
}
