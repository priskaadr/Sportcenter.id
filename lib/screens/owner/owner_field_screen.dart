import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/field_model.dart';
import 'add_field_screen.dart';

class OwnerFieldScreen extends StatefulWidget {
  const OwnerFieldScreen({super.key});

  @override
  State<OwnerFieldScreen> createState() =>
      _OwnerFieldScreenState();
}

class _OwnerFieldScreenState
    extends State<OwnerFieldScreen> {

  final supabase =
      Supabase.instance.client;

  List<FieldModel> fields = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFields();
  }

  Future<void> loadFields() async {
    try {
      final ownerId =
          supabase.auth.currentUser!.id;

      final response =
          await supabase
              .from('fields')
              .select()
              .eq('owner_id', ownerId)
              .order(
                'created_at',
                ascending: false,
              );

      fields = response
          .map<FieldModel>(
            (json) =>
                FieldModel.fromJson(json),
          )
          .toList();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteField(
      String id) async {
    await supabase
        .from('fields')
        .delete()
        .eq('id', id);

    loadFields();
  }

  Widget buildFieldCard(
      FieldModel field) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        children: [

          Stack(
            children: [

              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(
                  top:
                      Radius.circular(
                    20,
                  ),
                ),
                child: Image.network(
                  field.imageUrl,
                  height: 180,
                  width:
                      double.infinity,
                  fit: BoxFit.cover,

                  errorBuilder:
                      (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return Container(
                      height: 180,
                      color:
                          Colors.grey,
                      child: const Icon(
                        Icons.image,
                        size: 50,
                      ),
                    );
                  },
                ),
              ),

              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        Colors.amber,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    "${field.rating}",
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              )
            ],
          ),

          Padding(
            padding:
                const EdgeInsets.all(
              16,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [

                Text(
                  field.fieldName,
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                    height: 5),

                Row(
                  children: [

                    const Icon(
                      Icons.location_on,
                      size: 18,
                      color:
                          Colors.grey,
                    ),

                    const SizedBox(
                        width: 4),

                    Text(
                      field.location,
                      style:
                          const TextStyle(
                        color:
                            Colors.grey,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                    height: 10),

                Text(
                  "Rp ${field.price}",
                  style:
                      const TextStyle(
                    color:
                        Colors.green,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(
                    height: 15),

                Row(
                  children: [

                    Expanded(
                      child:
                          OutlinedButton.icon(
                        onPressed: () {
                          // edit nanti
                        },
                        icon: const Icon(
                          Icons.edit,
                        ),
                        label:
                            const Text(
                          "Edit",
                        ),
                      ),
                    ),

                    const SizedBox(
                        width: 10),

                    Expanded(
                      child:
                          ElevatedButton.icon(
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              Colors.red,
                        ),
                        onPressed: () {
                          deleteField(
                            field.id,
                          );
                        },
                        icon: const Icon(
                          Icons.delete,
                          color:
                              Colors.white,
                        ),
                        label:
                            const Text(
                          "Hapus",
                          style:
                              TextStyle(
                            color:
                                Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(
        0xffF5F6FA,
      ),

      floatingActionButton:
          FloatingActionButton.extended(
        backgroundColor:
            Colors.amber,

        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddFieldScreen(),
            ),
          );

          loadFields();
        },

        icon:
            const Icon(Icons.add),

        label: const Text(
          "Tambah",
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [

            Container(
              width:
                  double.infinity,
              padding:
                  const EdgeInsets.all(
                20,
              ),

              decoration:
                  const BoxDecoration(
                color:
                    Color(0xff001DFF),

                borderRadius:
                    BorderRadius.only(
                  bottomLeft:
                      Radius.circular(
                    30,
                  ),
                  bottomRight:
                      Radius.circular(
                    30,
                  ),
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [

                  const Text(
                    "Lapangan Saya",
                    style:
                        TextStyle(
                      color:
                          Colors.white,
                      fontSize: 24,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                      height: 8),

                  Text(
                    "${fields.length} Lapangan Terdaftar",
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: isLoading

                  ? const Center(
                      child:
                          CircularProgressIndicator(),
                    )

                  : fields.isEmpty

                      ? const Center(
                          child: Text(
                            "Belum ada lapangan",
                          ),
                        )

                      : RefreshIndicator(
                          onRefresh:
                              loadFields,
                          child:
                              ListView.builder(
                            padding:
                                const EdgeInsets.all(
                              16,
                            ),
                            itemCount:
                                fields.length,
                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              return buildFieldCard(
                                fields[
                                    index],
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}