import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static Future<String> getUserRole() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) return 'student';

    final res = await supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    return res['role'] as String;
  }
}
