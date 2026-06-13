import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/field_model.dart';

class FieldService {
  final supabase = Supabase.instance.client;

  Future<List<FieldModel>> getFields() async {
  try {
      final response =
          await supabase
              .from('fields')
              .select();
      print("FIELDS:");
      print(response);
      return response
          .map<FieldModel>(
            (json) => FieldModel.fromJson(json),
          )
          .toList();
    } catch (e) {
    
      print(e);
      throw Exception(
        'Gagal mengambil data lapangan: $e',
      );
    }
  }
}