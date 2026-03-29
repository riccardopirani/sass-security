import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

class EmployeeAvatarStorage {
  EmployeeAvatarStorage({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _bucket = 'employee-avatars';

  static const maxBytes = 5 * 1024 * 1024;

  String mimeForExt(String ext) {
    switch (ext.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  /// Returns public URL stored in [security_cg_employees.avatar_url].
  Future<String> upload({
    required String companyId,
    required String employeeId,
    required Uint8List bytes,
    required String ext,
  }) async {
    if (bytes.length > maxBytes) {
      throw StateError('Image too large (max 5 MB)');
    }
    final safeExt = ext.toLowerCase().replaceAll('.', '');
    final path = '$companyId/$employeeId.$safeExt';
    final contentType = mimeForExt(safeExt);

    await _client.storage.from(_bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType,
          ),
        );

    return _client.storage.from(_bucket).getPublicUrl(path);
  }

  Future<void> removeFilesForEmployee(String companyId, String employeeId) async {
    const exts = ['jpg', 'jpeg', 'png', 'webp'];
    final paths = exts.map((e) => '$companyId/$employeeId.$e').toList();
    try {
      await _client.storage.from(_bucket).remove(paths);
    } catch (_) {
      // ignore missing objects
    }
  }
}
