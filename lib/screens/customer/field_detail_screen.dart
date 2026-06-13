import 'package:flutter/material.dart';
import '../../models/field_model.dart';

class FieldDetailScreen extends StatelessWidget {
  final FieldModel field;

  const FieldDetailScreen({
    super.key,
    required this.field,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: CustomScrollView(
        slivers: [

          // APP BAR + IMAGE
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.white,

            leading: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),

            flexibleSpace: FlexibleSpaceBar(
              background: field.imageUrl.isNotEmpty
                  ? Image.network(
                      field.imageUrl,
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      "assets/images/futsal.jpg",
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Row(
                    children: [

                      Expanded(
                        child: Text(
                          field.fieldName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight:
                                FontWeight.bold,
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
                          color: Colors.amber,
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                        child: Text(
                          field.rating.toString(),
                          style: const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [

                      const Icon(
                        Icons.location_on,
                        color: Colors.red,
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: Text(
                          field.location,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Fasilitas",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        field.facility
                            .split(',')
                            .map(
                              (item) => Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color:
                                      Colors.grey
                                          .shade200,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),
                                ),
                                child: Text(
                                  item.trim(),
                                ),
                              ),
                            )
                            .toList(),
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    "Deskripsi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    field.description.isEmpty
                        ? "Belum ada deskripsi lapangan."
                        : field.description,
                    style: const TextStyle(
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding:
                        const EdgeInsets.all(15),

                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                    ),

                    child: Row(
                      children: [

                        const Icon(
                          Icons.attach_money,
                          color: Colors.green,
                        ),

                        const SizedBox(width: 10),

                        const Text(
                          "Harga per jam",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          "Rp ${field.price}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,

        child: SafeArea(
          child: SizedBox(
            height: 55,

            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xffF7C600),
                foregroundColor:
                    Colors.black,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(15),
                ),
              ),

              onPressed: () {

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Menu booking akan dibuat berikutnya",
                    ),
                  ),
                );
              },

              child: const Text(
                "Sewa Sekarang",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}