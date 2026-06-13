import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {

  static Future init() async {

    await Supabase.initialize(
      url: "https://mdazspuxndnmjfjtvrma.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kYXpzcHV4bmRubWpmanR2cm1hIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyMjQyODUsImV4cCI6MjA5NjgwMDI4NX0.fwgzfef_xzBVHK4dfcqnmTFNZnIOAd8y1hoY2G8h0cM",
    );
  }
}