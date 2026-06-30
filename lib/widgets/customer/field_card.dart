import 'package:flutter/material.dart';

import '../../models/field_model.dart';

class FieldCard extends StatelessWidget {
  final FieldModel field;
  final VoidCallback onTap;

  const FieldCard({
    super.key,
    required this.field,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 220,

        margin: const EdgeInsets.only(right: 18),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(22),

          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            //--------------------------------
            // FOTO
            //--------------------------------

            Stack(
              children: [

                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(22),
                  ),

                  child: field.imageUrl.isNotEmpty
                      ? Image.network(
                          field.imageUrl,
                          height: 145,
                          width: double.infinity,
                          fit: BoxFit.cover,

                          errorBuilder:
                              (context, error, stackTrace) {
                            return Container(
                              height: 145,
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 45,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          height: 145,
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              size: 45,
                            ),
                          ),
                        ),
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [

                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),

                        const SizedBox(width: 3),

                        Text(
                          field.rating.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            //--------------------------------
            // ISI CARD
            //--------------------------------

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      field.fieldName,

                      maxLines: 1,

                      overflow: TextOverflow.ellipsis,

                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Row(
                      children: [

                        const Icon(
                          Icons.location_on,
                          size: 15,
                          color: Colors.red,
                        ),

                        const SizedBox(width: 4),

                        Expanded(
                          child: Text(
                            field.location,

                            maxLines: 1,

                            overflow:
                                TextOverflow.ellipsis,

                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,

                            borderRadius:
                                BorderRadius.circular(15),
                          ),

                          child: const Text(
                            "Futsal",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.green.shade50,

                            borderRadius:
                                BorderRadius.circular(15),
                          ),

                          child: Text(
                            "${field.facility.length} Fasilitas",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [

                        Expanded(
                          child: Text(
                            "Rp ${field.price}",

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Color(0xff001DFF),
                            ),
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(8),

                          decoration: BoxDecoration(
                            color: const Color(0xff001DFF),

                            borderRadius:
                                BorderRadius.circular(14),
                          ),

                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}