import 'dart:convert';

import '../../shared/models/app_models.dart';

const String khMetaMarker = '@@KH_META@@';

const int _orderIdMax = 30;
const int _cityMax = 60;
const int _scheduleMax = 80;
const int _assignmentMax = 30;
const int _statusMax = 30;
const int _pinMax = 6;
const int _notificationTitleMax = 150;

String? normalizeSupabaseUrl(String raw) {
  var text = raw.trim();
  if (text.isEmpty) return null;
  if (!text.contains('://')) text = 'https://$text';
  final uri = Uri.tryParse(text);
  if (uri == null || uri.host.isEmpty) return null;
  if (uri.scheme != 'https' && uri.scheme != 'http') return null;
  if (uri.scheme == 'http' && uri.host != 'localhost' && uri.host != '127.0.0.1') return null;

  var path = uri.path;
  if (path.endsWith('/')) path = path.substring(0, path.length - 1);
  if (path.endsWith('/rest/v1')) {
    path = path.substring(0, path.length - '/rest/v1'.length);
  }
  final normalized = uri.replace(path: path, query: '', fragment: '').removeFragment();
  final value = normalized.toString();
  return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}

String? orderSyncError(OrderItemModel order) {
  final id = order.id.trim();
  if (id.isEmpty) return 'معرّف الطلب فارغ';
  if (id.length > _orderIdMax) return 'معرّف الطلب أطول من $_orderIdMax حرفاً';
  if (order.pinCode.trim().length > _pinMax) return 'رمز PIN أطول من $_pinMax';
  if (order.statusText.length > _statusMax) return 'حالة الطلب أطول من $_statusMax';
  if (assignmentColumn(order.assignmentMode).length > _assignmentMax) {
    return 'طريقة التعيين أطول من $_assignmentMax';
  }
  return null;
}

String assignmentColumn(String mode) {
  final value = mode.trim();
  if (value == 'manual' || value.contains('يدوي')) return 'manual';
  return 'auto_nearest';
}

Map<String, dynamic> orderToRow(OrderItemModel order) {
  final pin = order.pinCode.trim().isEmpty ? '0000' : order.pinCode.trim();
  final citySource = order.city.trim().isEmpty ? 'القاهرة' : order.city.trim();
  final scheduleSource = order.appointmentSlot.trim().isEmpty ? 'غير محدد' : order.appointmentSlot.trim();
  final address = order.address.trim().isEmpty ? 'غير محدد' : order.address.trim();
  final meta = <String, dynamic>{
    'serviceName': order.serviceName,
    'description': order.description,
    'mapCoordinates': order.mapCoordinates,
    'appointmentSlot': order.appointmentSlot,
    'assignmentMode': order.assignmentMode,
    'customerName': order.customerName,
    'customerPhone': order.customerPhone,
    'paymentMethod': order.paymentMethod,
    'technicianId': order.technicianId,
    'technicianName': order.technicianName,
    'technicianPhone': order.technicianPhone,
    'isPaid': order.isPaid,
    'customerRating': order.customerRating,
    'customerReview': order.customerReview,
    'chatMessages': order.chatMessages,
    'statusIndex': order.statusIndex,
    'city': order.city,
    'address': order.address,
    'pinCode': order.pinCode,
  };
  final row = <String, dynamic>{
    'id': order.id.trim(),
    'description': '${order.description.trim()}\n$khMetaMarker\n${jsonEncode(meta)}',
    'photos_urls': order.attachedPhotos,
    'city': _clip(citySource, _cityMax),
    'address': address,
    'scheduled_at': _clip(scheduleSource, _scheduleMax),
    'assignment_mode': assignmentColumn(order.assignmentMode),
    'status': _clip(order.statusText, _statusMax),
    'pin_code': pin,
    'total_price': order.price,
  };
  _putCoordinate(row, 'lat', order.mapCoordinates, 0);
  _putCoordinate(row, 'lng', order.mapCoordinates, 1);
  return row;
}

OrderItemModel? orderFromRow(dynamic raw) {
  try {
    if (raw is! Map) return null;
    final row = <String, dynamic>{};
    raw.forEach((key, value) => row[key.toString()] = value);
    final id = row['id']?.toString().trim() ?? '';
    if (id.isEmpty) return null;

    final descriptionRaw = row['description']?.toString() ?? '';
    final meta = _metaFromDescription(descriptionRaw);
    final statusColumn = row['status']?.toString().trim() ?? '';
    final statusIndex = _statusIndex(meta, statusColumn);
    final chats = _stringList(meta?['chatMessages']);

    return OrderItemModel(
      id: id,
      serviceName: _metaText(meta, 'serviceName', 'خدمة'),
      description: meta == null ? descriptionRaw.trim() : _metaText(meta, 'description', _visibleDescription(descriptionRaw)),
      attachedPhotos: _stringList(row['photos_urls']),
      city: _metaText(meta, 'city', _columnText(row['city'], 'القاهرة')),
      address: _metaText(meta, 'address', _columnText(row['address'], 'غير محدد')),
      mapCoordinates: _metaText(meta, 'mapCoordinates', _coordinatesFromColumns(row)),
      appointmentSlot: _metaText(meta, 'appointmentSlot', _columnText(row['scheduled_at'], 'غير محدد')),
      assignmentMode: _assignmentLabel(row['assignment_mode']?.toString() ?? '', meta?['assignmentMode']?.toString()),
      customerName: _metaText(meta, 'customerName', 'عميل'),
      customerPhone: _metaText(meta, 'customerPhone', ''),
      pinCode: _metaText(meta, 'pinCode', _columnText(row['pin_code'], '0000')),
      paymentMethod: _metaText(meta, 'paymentMethod', 'غير محدد'),
      statusIndex: statusIndex,
      price: _price(row['total_price']),
      technicianId: _metaText(meta, 'technicianId', ''),
      technicianName: _metaText(meta, 'technicianName', 'غير معيّن'),
      technicianPhone: _metaText(meta, 'technicianPhone', ''),
      isPaid: meta != null && meta.containsKey('isPaid') ? meta['isPaid'] == true : statusIndex == 4,
      customerRating: _rating(meta?['customerRating']),
      customerReview: meta?['customerReview']?.toString(),
      chatMessages: meta == null ? null : chats,
    );
  } catch (_) {
    return null;
  }
}

List<OrderItemModel> mergeOrders({
  required List<OrderItemModel> local,
  required List<OrderItemModel> remote,
}) {
  final merged = <OrderItemModel>[...local];
  for (final order in remote) {
    if (merged.every((existing) => existing.id != order.id)) {
      merged.add(order);
    }
  }
  return merged;
}

Map<String, dynamic>? notificationToRow(String body) {
  final text = body.trim();
  if (text.isEmpty) return null;
  final title = text.length <= _notificationTitleMax ? text : text.substring(0, _notificationTitleMax);
  return {
    'title': title,
    'body': text,
    'is_read': false,
  };
}

class NotificationMerge {
  final List<String> merged;
  final List<Map<String, dynamic>> inserts;

  const NotificationMerge({required this.merged, required this.inserts});
}

NotificationMerge mergeNotifications({
  required List<String> local,
  required List<String> remoteBodies,
}) {
  final localNotes = _uniqueNotes(local);
  final remoteNotes = _uniqueNotes(remoteBodies);
  final remoteSet = remoteNotes.toSet();
  final merged = <String>[...localNotes];
  for (final note in remoteNotes) {
    if (!merged.contains(note)) merged.add(note);
  }
  final inserts = <Map<String, dynamic>>[];
  for (final note in localNotes) {
    if (remoteSet.contains(note)) continue;
    final row = notificationToRow(note);
    if (row != null) inserts.add(row);
  }
  return NotificationMerge(merged: merged, inserts: inserts);
}

String explainSupabaseFailure(int status, String body) {
  final lower = body.toLowerCase();
  if (status == 401 || lower.contains('jwt') || lower.contains('invalid api key')) {
    return 'مفتاح anon غير مقبول. انسخه من إعدادات API في Supabase ثم أعد الربط.';
  }
  if (lower.contains('row-level security') || lower.contains('42501') || lower.contains('permission denied')) {
    return 'جدول محمي بسياسة RLS أو بدون صلاحية للدور anon. نفّذ قسم الصلاحيات في آخر schema.sql على orders و notifications.';
  }
  if (status == 404 || lower.contains('pgrst205') || lower.contains('could not find the table') || lower.contains('does not exist')) {
    return 'الجدول غير موجود في مشروع Supabase. أنشئ orders و notifications من schema.sql.';
  }
  if (lower.contains('value too long')) {
    return 'قيمة أطول من عمود الجدول ولم تُقبل.';
  }
  if (lower.contains('invalid input syntax') || lower.contains('22p02')) {
    return 'نوع بيانات غير متوافق مع أعمدة الجدول.';
  }
  if (lower.contains('foreign key') || lower.contains('23503')) {
    return 'رفض الجدول مرجعاً أجنبياً. المزامنة لا ترسل معرّفات الفني أو العميل النصية.';
  }
  final snippet = body.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (snippet.isEmpty) return 'تعذر تنفيذ الطلب على Supabase (HTTP $status).';
  final clipped = snippet.length > 180 ? snippet.substring(0, 180) : snippet;
  return 'تعذر تنفيذ الطلب على Supabase (HTTP $status): $clipped';
}

Map<String, dynamic>? _metaFromDescription(String raw) {
  final index = raw.lastIndexOf(khMetaMarker);
  if (index < 0) return null;
  final payload = raw.substring(index + khMetaMarker.length).trim();
  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }
  } catch (_) {}
  return null;
}

String _visibleDescription(String raw) {
  final index = raw.lastIndexOf(khMetaMarker);
  if (index < 0) return raw.trim();
  return raw.substring(0, index).trim();
}

String _metaText(Map<String, dynamic>? meta, String key, String fallback) {
  if (meta == null || !meta.containsKey(key) || meta[key] == null) return fallback;
  final text = meta[key].toString();
  return text.trim().isEmpty ? fallback : text;
}

String _columnText(dynamic value, String fallback) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

int _statusIndex(Map<String, dynamic>? meta, String statusColumn) {
  final raw = meta?['statusIndex'];
  if (raw is int && raw >= 0 && raw <= 4) return raw;
  if (raw is num && raw >= 0 && raw <= 4) return raw.toInt();
  final fromLabel = OrderItemModel.statusLabels.indexOf(statusColumn);
  return fromLabel >= 0 ? fromLabel : 0;
}

int? _rating(dynamic raw) {
  if (raw is int && raw >= 1 && raw <= 5) return raw;
  if (raw is num && raw >= 1 && raw <= 5) return raw.toInt();
  return null;
}

int _price(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return num.tryParse(value?.toString() ?? '')?.round() ?? 0;
}

List<String> _stringList(dynamic value) {
  if (value is! List) return <String>[];
  return value.map((item) => item.toString()).where((item) => item.trim().isNotEmpty).toList();
}

String _assignmentLabel(String stored, String? fromMeta) {
  final meta = fromMeta?.trim() ?? '';
  if (meta.isNotEmpty) return meta;
  if (stored == 'manual' || stored.contains('يدوي')) return 'اختيار فني يدوي';
  if (stored == 'auto_nearest' || stored.contains('تلقائي') || stored.isEmpty) {
    return 'تلقائي حسب الأقرب جغرافياً';
  }
  return stored;
}

String _coordinatesFromColumns(Map<String, dynamic> row) {
  final lat = _asDouble(row['lat']);
  final lng = _asDouble(row['lng']);
  if (lat == null || lng == null) return '';
  return '$lat, $lng';
}

double? _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

void _putCoordinate(Map<String, dynamic> row, String key, String coordinates, int index) {
  final matches = RegExp(r'-?\d+(?:\.\d+)?').allMatches(coordinates).toList();
  if (matches.length <= index) return;
  final value = double.tryParse(matches[index].group(0)!);
  if (value == null || value.isNaN || value.abs() >= 1000) return;
  row[key] = double.parse(value.toStringAsFixed(6));
}

String _clip(String value, int max) {
  if (value.length <= max) return value;
  return value.substring(0, max);
}

List<String> _uniqueNotes(List<String> items) {
  final seen = <String>{};
  final notes = <String>[];
  for (final item in items) {
    final text = item.trim();
    if (text.isEmpty || !seen.add(text)) continue;
    notes.add(text);
  }
  return notes;
}
