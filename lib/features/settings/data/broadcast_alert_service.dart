import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/supabase_service.dart';

class BroadcastAlert {
  const BroadcastAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.tag,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String tag;
  final DateTime createdAt;

  factory BroadcastAlert.fromMap(Map<String, dynamic> map) {
    return BroadcastAlert(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      tag: map['tag'] as String? ?? 'announcement',
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

final broadcastAlertsProvider =
    FutureProvider.autoDispose<List<BroadcastAlert>>((ref) async {
  try {
    final response = await SupabaseService.instance.client
        .from('broadcast_alerts')
        .select()
        .order('created_at', ascending: false)
        .limit(10);

    final list = response as List<dynamic>;
    return list
        .map((item) => BroadcastAlert.fromMap(item as Map<String, dynamic>))
        .toList();
  } catch (e) {
    debugPrint('Error fetching broadcast alerts: $e');
    return [];
  }
});
