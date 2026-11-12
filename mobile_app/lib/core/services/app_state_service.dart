import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../shared/models/app_models.dart';

class AppStateService extends ChangeNotifier {
  static final AppStateService instance = AppStateService._internal();
  AppStateService._internal();

  String supabaseUrl = '';
  String supabaseAnonKey = '';
  bool isCloudConnected = false;
  String lastSyncStatus = 'يعمل بالوضع المحلي (اضغط "ربط Supabase" أعلى الشاشة للمزامنة الحية بين الهواتف)';
  Timer? _syncTimer;

  int currentRole = 0;
  bool isAuthenticated = false;
  String currentUserName = 'أحمد محمود';
  String currentUserPhone = '01012345678';
  String selectedCity = 'القاهرة';
  String lastOtp = '1234';

  double customerWallet = 300.0;
  double technicianEarnings = 1450.0;
  String? activeOrderId = 'KH-9041';

  final List<String> egyptCities = const [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'المنصورة',
    'طنطا',
    'الزقازيق',
    'أسيوط',
    'أسوان',
  ];

  final List<String> notifications = [
    'مرحباً بك في خدماتي KHADAMATY مصر - ضمان 30 يوماً على كافة أعمال الصيانة.',
    'الفني م. مصطفى السيد قريب من موقعك في القاهرة (يبعد 1.2 كم).',
  ];

  final List<ServiceItemModel> services = [
    ServiceItemModel(
      id: 'plumbing',
      name: 'سباكة',
      subtitle: 'كشف تسريبات، تأسيس، وصيانة خلاطات ومواتير مياه',
      minPrice: 150,
      maxPrice: 450,
      icon: Icons.plumbing,
      color: const Color(0xFF0F766E),
    ),
    ServiceItemModel(
      id: 'electric',
      name: 'كهرباء',
      subtitle: 'إصلاح قفلات، تركيب نجف، لوحات توزيع، وإنتركم',
      minPrice: 150,
      maxPrice: 500,
      icon: Icons.bolt,
      color: const Color(0xFFD97706),
    ),
    ServiceItemModel(
      id: 'ac',
      name: 'تكييف وتبريد',
      subtitle: 'شحن فريون، غسيل كيميائي، وصيانة تكييفات سبليت ومركزي',
      minPrice: 250,
      maxPrice: 650,
      icon: Icons.ac_unit,
      color: const Color(0xFF0284C7),
    ),
    ServiceItemModel(
      id: 'appliances',
      name: 'أجهزة منزلية',
      subtitle: 'صيانة غسالات أوتوماتيك، ثلاجات، سخانات، وبوتاجازات',
      minPrice: 250,
      maxPrice: 700,
      icon: Icons.kitchen,
      color: const Color(0xFF4F46E5),
    ),
    ServiceItemModel(
      id: 'carpentry',
      name: 'نجارة',
      subtitle: 'صيانة أبواب، تغيير كوالين، ومطابخ وغرف نوم',
      minPrice: 200,
      maxPrice: 600,
      icon: Icons.handyman,
      color: const Color(0xFF78350F),
    ),
    ServiceItemModel(
      id: 'cleaning',
      name: 'نظافة شاملة',
      subtitle: 'تنظيف شقق وفيلات بعد التشطيب وتعقيم بالبخار',
      minPrice: 350,
      maxPrice: 1200,
      icon: Icons.cleaning_services,
      color: const Color(0xFF16A34A),
    ),
  ];

  final List<TechnicianItemModel> technicians = [
    TechnicianItemModel(
      id: 'TECH-1',
      name: 'م. مصطفى السيد',
      specialty: 'تكييف وتبريد',
      city: 'القاهرة',
      phone: '01066554433',
      distanceKm: 1.2,
      rating: 4.9,
      completedJobs: 128,
      isVerified: true,
      isOnline: true,
    ),
    TechnicianItemModel(
      id: 'TECH-2',
      name: 'م. حسن عبد السلام',
      specialty: 'سباكة',
      city: 'القاهرة',
      phone: '01022334455',
      distanceKm: 2.4,
      rating: 4.8,
      completedJobs: 94,
      isVerified: true,
      isOnline: true,
    ),
    TechnicianItemModel(
      id: 'TECH-3',
      name: 'م. إبراهيم عادل',
      specialty: 'كهرباء',
      city: 'المنصورة',
      phone: '01099881122',
      distanceKm: 0.9,
      rating: 4.7,
      completedJobs: 63,
      isVerified: false,
      isOnline: true,
    ),
  ];

  final List<OrderItemModel> orders = [
    OrderItemModel(
      id: 'KH-9041',
      serviceName: 'تكييف وتبريد',
      description: 'التكييف لا يبرد ويحتاج شحن فريون وتنظيف الوحدة الداخلية والخارجية',
      attachedPhotos: ['صورة_الوحدة_الداخلية.jpg', 'صورة_عداد_الفريون.jpg'],
      city: 'القاهرة',
      address: 'مدينة نصر - شارع عباس العقاد - برج التطبيقيين الدور 5',
      mapCoordinates: '30.0561 N, 31.3301 E (تم التحديد على خرائط جوجل)',
      appointmentSlot: 'اليوم - الفترة المسائية (04:00 م - 07:00 م)',
      assignmentMode: 'تلقائي حسب الأقرب جغرافياً',
      customerName: 'أحمد محمود',
      customerPhone: '01012345678',
      pinCode: '4829',
      paymentMethod: 'بطاقة بنكية (Paymob)',
      statusIndex: 1,
      price: 450,
      technicianId: 'TECH-1',
      technicianName: 'م. مصطفى السيد (يبعد 1.2 كم)',
      technicianPhone: '01066554433',
      isPaid: false,
      chatMessages: [
        'النظام: تم تعيين م. مصطفى السيد تلقائياً كأقرب فني معتمد لموقعك.',
        'م. مصطفى السيد: أهلاً بحضرتك يا فندم، تم قبول الطلب وسأتحرك إليك في الموعد.',
      ],
    ),
  ];

  Map<String, String> get _headers => {
        'apikey': supabaseAnonKey.trim(),
        'Authorization': 'Bearer ${supabaseAnonKey.trim()}',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  String get _cleanBaseUrl => supabaseUrl.trim().replaceAll(RegExp(r'/$'), '');

  Future<bool> connectSupabase(String url, String key) {
    return configureSupabaseConnection(url, key);
  }

  Future<bool> configureSupabaseConnection(String url, String key) async {
    supabaseUrl = url.trim();
    supabaseAnonKey = key.trim();
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      isCloudConnected = false;
      lastSyncStatus = 'لم يتم إدخال بيانات السحابة بعد';
      notifyListeners();
      return false;
    }
    final ok = await syncFromSupabase();
    if (ok) {
      startRealtimePolling();
    }
    return ok;
  }

  void startRealtimePolling() {
    _syncTimer?.cancel();
    syncFromSupabase();
    _syncTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      syncFromSupabase();
    });
  }

  Future<bool> syncFromSupabase() async {
    if (supabaseUrl.trim().isEmpty || supabaseAnonKey.trim().isEmpty) return false;
    try {
      final ordersUri = Uri.parse('$_cleanBaseUrl/rest/v1/orders?select=*&order=created_at.desc');
      final res = await http.get(ordersUri, headers: _headers).timeout(const Duration(seconds: 6));

      if (res.statusCode >= 200 && res.statusCode < 300) {
        final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes)) as List<dynamic>;
        if (data.isNotEmpty) {
          orders
            ..clear()
            ..addAll(data.map((item) => OrderItemModel.fromSupabaseJson(item as Map<String, dynamic>)));
          activeOrderId ??= orders.first.id;
        }
        isCloudConnected = true;
        lastSyncStatus = 'متصل بسحابة Supabase حياً (${orders.length} طلبات متزامنة)';
      } else {
        isCloudConnected = false;
        lastSyncStatus = 'تنبيه سحابة Supabase: كود ${res.statusCode} (تأكد من تشغيل كود SQL)';
      }

      final notifUri = Uri.parse('$_cleanBaseUrl/rest/v1/notifications?select=*&order=id.desc&limit=8');
      final notifRes = await http.get(notifUri, headers: _headers).timeout(const Duration(seconds: 5));
      if (notifRes.statusCode >= 200 && notifRes.statusCode < 300) {
        final List<dynamic> nData = jsonDecode(utf8.decode(notifRes.bodyBytes)) as List<dynamic>;
        if (nData.isNotEmpty) {
          notifications
            ..clear()
            ..addAll(nData.map((n) => (n['message'] ?? '').toString()).where((s) => s.isNotEmpty));
        }
      }
      notifyListeners();
      return isCloudConnected;
    } catch (e) {
      isCloudConnected = false;
      lastSyncStatus = 'تعذر الاتصال بالسحابة حالياً - يعمل بالذاكرة المحلية';
      notifyListeners();
      return false;
    }
  }

  Future<void> _pushOrderToSupabase(OrderItemModel order, {bool isUpdate = false}) async {
    if (supabaseUrl.trim().isEmpty || supabaseAnonKey.trim().isEmpty) return;
    try {
      if (isUpdate) {
        final uri = Uri.parse('$_cleanBaseUrl/rest/v1/orders?id=eq.${order.id}');
        await http.patch(uri, headers: _headers, body: jsonEncode(order.toSupabaseJson()));
      } else {
        final uri = Uri.parse('$_cleanBaseUrl/rest/v1/orders');
        await http.post(uri, headers: _headers, body: jsonEncode(order.toSupabaseJson()));
      }
      await syncFromSupabase();
    } catch (_) {}
  }

  Future<void> _pushNotificationToSupabase(String message) async {
    notifications.insert(0, message);
    notifyListeners();
    if (supabaseUrl.trim().isEmpty || supabaseAnonKey.trim().isEmpty) return;
    try {
      final uri = Uri.parse('$_cleanBaseUrl/rest/v1/notifications');
      await http.post(uri, headers: _headers, body: jsonEncode({'message': message}));
    } catch (_) {}
  }

  void setRole(int role) {
    currentRole = role;
    notifyListeners();
  }

  void setCity(String city) {
    selectedCity = city;
    notifyListeners();
  }

  String sendOtp(String phone, String name, int role) {
    currentUserPhone = phone;
    currentUserName = name.trim().isEmpty ? 'عميل خدماتي' : name.trim();
    currentRole = role;
    lastOtp = '1234';
    _pushNotificationToSupabase('رمز التحقق OTP للدخول إلى حسابك ($phone) هو: 1234');
    return lastOtp;
  }

  bool verifyOtp(String code) {
    if (code.trim() == '1234' || code.trim() == lastOtp) {
      isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  OrderItemModel createOrder({
    required String serviceName,
    required String description,
    required List<String> photos,
    required String address,
    required String mapCoords,
    required String appointmentSlot,
    required String assignmentMode,
    required String paymentMethod,
    required int price,
    String? manualTechId,
  }) {
    final String pin = (1000 + (DateTime.now().millisecond % 8999)).toString();
    final String id = 'KH-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    TechnicianItemModel chosenTech = technicians.first;
    if (manualTechId != null) {
      for (final t in technicians) {
        if (t.id == manualTechId) chosenTech = t;
      }
    } else {
      for (final t in technicians) {
        if (t.specialty == serviceName && t.isVerified) {
          chosenTech = t;
          break;
        }
      }
    }

    final order = OrderItemModel(
      id: id,
      serviceName: serviceName,
      description: description.trim().isEmpty ? 'طلب صيانة وفحص شامل ($serviceName)' : description.trim(),
      attachedPhotos: photos.isEmpty ? ['صورة_العطل_1.jpg'] : photos,
      city: selectedCity,
      address: address.trim().isEmpty ? '$selectedCity - العنوان المسجل على الخريطة' : address.trim(),
      mapCoordinates: mapCoords,
      appointmentSlot: appointmentSlot,
      assignmentMode: assignmentMode,
      customerName: currentUserName,
      customerPhone: currentUserPhone,
      pinCode: pin,
      paymentMethod: paymentMethod,
      statusIndex: 0,
      price: price,
      technicianId: chosenTech.id,
      technicianName: '${chosenTech.name} (يبعد ${chosenTech.distanceKm} كم)',
      technicianPhone: chosenTech.phone,
    );

    orders.insert(0, order);
    activeOrderId = order.id;
    notifyListeners();

    _pushOrderToSupabase(order, isUpdate: false);
    _pushNotificationToSupabase('طلب جديد #$id ($serviceName) في $selectedCity - موجه للفني ${chosenTech.name}');
    return order;
  }

  void advanceOrderStatus(String orderId, {int? targetStatus}) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final order = orders[idx];
    final next = targetStatus ?? (order.statusIndex + 1).clamp(0, 4);
    order.statusIndex = next;

    if (next == 1) {
      order.chatMessages.add('الفني: تم قبول الطلب وجاري التجهيز للتحرك.');
    } else if (next == 2) {
      order.chatMessages.add('الفني: أنا في الطريق إليك الآن عبر موقع الخريطة المحدد.');
    } else if (next == 3) {
      order.chatMessages.add('الفني: وصلت للموقع وتم مطابقة كود PIN (${order.pinCode}) وبدء العمل.');
    } else if (next == 4) {
      order.isPaid = true;
      technicianEarnings += (order.price * 0.85);
      order.chatMessages.add('النظام: اكتمل الطلب بنجاح وتم إصدار الفاتورة وشهادة الضمان لمدة 30 يوماً.');
    }
    notifyListeners();
    _pushOrderToSupabase(order, isUpdate: true);
    _pushNotificationToSupabase('تحديث سحابي للطلب #${order.id}: الحالة الآن (${order.statusText})');
  }

  void rejectOrderByTechnician(String orderId) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    orders[idx].technicianName = 'جاري إعادة التعيين التلقائي لأقرب فني بديل...';
    orders[idx].statusIndex = 0;
    notifyListeners();
    _pushOrderToSupabase(orders[idx], isUpdate: true);
    _pushNotificationToSupabase('تم تحويل الطلب #$orderId تلقائياً لأقرب فني متاح آخر.');
  }

  void sendChatMessage(String orderId, String sender, String text) {
    if (text.trim().isEmpty) return;
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    orders[idx].chatMessages.add('$sender: ${text.trim()}');
    notifyListeners();
    _pushOrderToSupabase(orders[idx], isUpdate: true);
  }

  void submitReview(String orderId, int stars, String comment) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    orders[idx].customerRating = stars;
    orders[idx].customerReview = comment.trim().isEmpty ? 'خدمة ممتازة وسريعة' : comment.trim();
    notifyListeners();
    _pushOrderToSupabase(orders[idx], isUpdate: true);
    _pushNotificationToSupabase('تقييم جديد للطلب #$orderId: $stars نجوم');
  }

  void updateServicePrice(String serviceId, int newMin, int newMax) {
    final idx = services.indexWhere((s) => s.id == serviceId);
    if (idx != -1) {
      services[idx].minPrice = newMin;
      services[idx].maxPrice = newMax;
      notifyListeners();
    }
  }

  void toggleTechnicianVerification(String techId) {
    final idx = technicians.indexWhere((t) => t.id == techId);
    if (idx != -1) {
      technicians[idx].isVerified = !technicians[idx].isVerified;
      notifyListeners();
    }
  }

  OrderItemModel get activeOrder {
    if (activeOrderId != null) {
      for (final o in orders) {
        if (o.id == activeOrderId) return o;
      }
    }
    return orders.first;
  }
}