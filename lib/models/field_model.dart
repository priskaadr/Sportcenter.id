class FieldModel {
  final String id;
  final String fieldName;
  final String location;
  final int price;
  final double rating;
  final String description;
  final String facility;
  final String imageUrl;

  FieldModel({
    required this.id,
    required this.fieldName,
    required this.location,
    required this.price,
    required this.rating,
    required this.description,
    required this.facility,
    required this.imageUrl,
  });

  factory FieldModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return FieldModel(
      id: json['id']?.toString() ?? '',

      fieldName:
          json['field_name']?.toString() ?? '',

      location:
          json['location']?.toString() ?? '',

      price:
          json['price'] ?? 0,

      rating:
          (json['rating'] ?? 0).toDouble(),

      description:
          json['description']?.toString() ?? '',

      facility:
          json['facility']?.toString() ?? '',

      imageUrl:
          json['image_url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'field_name': fieldName,
      'location': location,
      'price': price,
      'rating': rating,
      'description': description,
      'facility': facility,
      'image_url': imageUrl,
    };
  }
}