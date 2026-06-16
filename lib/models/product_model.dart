class ProductModel {
  final String id;
  final String name;
  final String image;
  final int price;
  final int stock;
  final String description;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.stock,
    required this.description,
    required this.category,
  });

  factory ProductModel.fromFirestore(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      price: data['price'] ?? 0,
      stock: data['stock'] ?? 0,
      description: data['description'] ?? '',
      category: data['category'] ?? '',
    );
  }
}
