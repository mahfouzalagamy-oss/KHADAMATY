import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../shared/models/app_models.dart';
import 'supabase_codec.dart';

class SupabaseCallResult {
  final bool ok;
  final String message;

  const SupabaseCallResult({required this.ok, required this.message});
}

class SupabaseSyncResult {
  final bool ok;
  final String message;
  final List<OrderItemModel> orders;
  final List<String> notifications;

  const SupabaseSyncResult({
    required this.ok,
    required this.message,
    required this.orders,
    required this.notifications,
  });

  factory SupabaseSyncResult.failure(
    String message,
    List<OrderItemModel> orders,
    List<String> notifications,
  ) {
    return SupabaseSyncResult(ok: false, message: message, orders: orders, notifications: notifications);
  }
}

class SyncHttpException implements Exception {
  final String message;
  SyncHttpException(this.message);
}

class SupabaseSyncService {
  SupabaseSyncService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<SupabaseCallResult> probe({
    required String projectUrl,
    required String anonKey,
  }) async {
    final base = normalizeSupabaseUrl(projectUrl);
    final key = anonKey.trim();
    if (base == null) {
      return const SupabaseCallResult(
        ok: false,
        message: 'رابط مشروع Supabase غير صالح. مثال: https://xxxx.supabase.co',
      );
    }
    if (key.length < 20) {
      return const SupabaseCallResult(
        ok: false,
        message: 'مفتاح anon غير مكتمل. الصقه كاملاً من إعدادات المشروع.',
      );
    }

    final ordersError = await _probeTable(base, key, 'orders');
    if (ordersError != null) {
      return SupabaseCallResult(ok: false, message: 'جدول orders: $ordersError');
    }
    final notesError = await _probeTable(base, key, 'notifications');
    if (notesError != null) {
      return SupabaseCallResult(ok: false, message: 'جدول notifications: $notesError');
    }
    return const SupabaseCallResult(ok: true, message: 'تم الربط بـ Supabase.');
  }

  Future<SupabaseSyncResult> sync({
    required String projectUrl,
    required String anonKey,
    required List<OrderItemModel> orders,
    required List<String> notifications,
  }) async {
    final base = normalizeSupabaseUrl(projectUrl);
    final key = anonKey.trim();
    if (base == null) {
      return SupabaseSyncResult.failure(
        'رابط مشروع Supabase غير صالح. مثال: https://xxxx.supabase.co',
        orders,
        notifications,
      );
    }
    if (key.length < 20) {
      return SupabaseSyncResult.failure(
        'مفتاح anon غير مكتمل. الصقه كاملاً من إعدادات المشروع.',
        orders,
        notifications,
      );
    }

    final List<dynamic> orderRows;
    final List<dynamic> noteRows;
    try {
      orderRows = await _guard(() => _readList(base, key, 'orders', limit: 1000));
    } on SyncHttpException catch (error) {
      return SupabaseSyncResult.failure('جدول orders: ${error.message}', orders, notifications);
    }
    try {
      noteRows = await _guard(() => _readList(base, key, 'notifications', limit: 1000));
    } on SyncHttpException catch (error) {
      return SupabaseSyncResult.failure('جدول notifications: ${error.message}', orders, notifications);
    }

    final remoteOrders = <OrderItemModel>[];
    for (final row in orderRows) {
      final parsed = orderFromRow(row);
      if (parsed != null) remoteOrders.add(parsed);
    }
    final mergedOrders = mergeOrders(local: orders, remote: remoteOrders);
    final remoteNotes = <String>[];
    for (final row in noteRows) {
      if (row is! Map) continue;
      final body = row['body']?.toString().trim() ?? '';
      final title = row['title']?.toString().trim() ?? '';
      final text = body.isNotEmpty ? body : title;
      if (text.isNotEmpty) remoteNotes.add(text);
    }
    final notePlan = mergeNotifications(local: notifications, remoteBodies: remoteNotes);

    final payload = <Map<String, dynamic>>[];
    final skipped = <String>[];
    for (final order in mergedOrders) {
      final problem = orderSyncError(order);
      if (problem != null) {
        skipped.add('${order.id}: $problem');
        continue;
      }
      payload.add(orderToRow(order));
    }

    if (payload.isNotEmpty) {
      try {
        await _guard(() => _write(base, key, 'orders?on_conflict=id', payload));
      } on SyncHttpException catch (error) {
        return SupabaseSyncResult.failure('جدول orders: ${error.message}', orders, notifications);
      }
    }
    if (notePlan.inserts.isNotEmpty) {
      try {
        await _guard(() => _write(base, key, 'notifications', notePlan.inserts));
      } on SyncHttpException catch (error) {
        return SupabaseSyncResult.failure('جدول notifications: ${error.message}', orders, notifications);
      }
    }

    final buffer = StringBuffer(
      'تمت مزامنة ${mergedOrders.length} طلباً و ${notePlan.merged.length} إشعاراً.',
    );
    if (orderRows.length >= 1000 || noteRows.length >= 1000) {
      buffer.write(' تم جلب 1000 سجل كحد أقصى.');
    }
    if (skipped.isNotEmpty) {
      buffer.write(' تعذر رفع: ${skipped.join('، ')}.');
    }
    return SupabaseSyncResult(
      ok: true,
      message: buffer.toString(),
      orders: mergedOrders,
      notifications: notePlan.merged,
    );
  }

  Future<String?> _probeTable(String base, String anonKey, String table) async {
    try {
      await _guard(() => _readList(base, anonKey, table, limit: 1));
      return null;
    } on SyncHttpException catch (error) {
      return error.message;
    }
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on SyncHttpException {
      rethrow;
    } on TimeoutException {
      throw SyncHttpException('انتهت مهلة الاتصال بـ Supabase.');
    } on FormatException {
      throw SyncHttpException('استجابة Supabase غير مفهومة.');
    } catch (error) {
      final text = error.toString();
      if (text.contains('SocketException') || text.contains('ClientException') || text.contains('Failed host lookup')) {
        throw SyncHttpException('تعذر الوصول إلى خادم Supabase. تحقق من الرابط والاتصال.');
      }
      throw SyncHttpException('تعذر الاتصال بـ Supabase.');
    }
  }

  Future<List<dynamic>> _readList(
    String base,
    String anonKey,
    String table, {
    required int limit,
  }) async {
    final response = await _client
        .get(
          Uri.parse('$base/rest/v1/$table?select=*&limit=$limit'),
          headers: _headers(anonKey),
        )
        .timeout(const Duration(seconds: 20));
    final error = _httpError(response);
    if (error != null) throw SyncHttpException(error);
    if (response.body.trim().isEmpty) return const [];
    final decoded = jsonDecode(response.body);
    if (decoded is List) return decoded;
    throw SyncHttpException('استجابة غير متوقعة من Supabase.');
  }

  Future<void> _write(
    String base,
    String anonKey,
    String pathAndQuery,
    List<Map<String, dynamic>> rows,
  ) async {
    final response = await _client
        .post(
          Uri.parse('$base/rest/v1/$pathAndQuery'),
          headers: {
            ..._headers(anonKey, write: true),
            'Prefer': 'resolution=merge-duplicates,return=minimal',
          },
          body: jsonEncode(rows),
        )
        .timeout(const Duration(seconds: 20));
    final error = _httpError(response);
    if (error != null) throw SyncHttpException(error);
  }

  Map<String, String> _headers(String anonKey, {bool write = false}) {
    return {
      'apikey': anonKey,
      'Authorization': 'Bearer $anonKey',
      'Accept': 'application/json',
      if (write) 'Content-Type': 'application/json; charset=utf-8',
    };
  }

  String? _httpError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return null;
    return explainSupabaseFailure(response.statusCode, response.body);
  }
}
