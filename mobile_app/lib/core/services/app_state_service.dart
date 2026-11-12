import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../shared/models/app_models.dart';

class AppStateService extends ChangeNotifier {
  static final AppStateService instance = AppStateService._internal();

  AppStateService._internal() {
    Future.microtask(() => startRealtimePolling());
  }

  String supabaseUrl = 'https://dccgwosimmcwfwcffghd.supabase.co';
  String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRjY2d3b3NpbW1jd2Z3Y2ZmZ2hkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTQ0OTY3MTMsImV4cCI6MjExMDA3MjcxM30.7w6V6RGpil3vZnDqyIE7G4X2IdaP6A4qu-akg0RRk-c';
  String geminiApiKey = '';
  bool isCloudConnected = false;
  String lastSyncStatus = 'جاري الاتصال التلقائي بسحابة Supabase...';
  Timer? _syncTimer;

  // 0: العميل | 1: الفني | 2: الشركات | 3: الإدارة والمراجع
  int currentRole = 0;
  bool isAuthenticated = false;
  String currentUserName = 'أحمد محمود';
  String currentUserPhone = '01012345678';
  String selectedCity = 'القاهرة';
  String lastOtp = '1234';

  double customerWallet = 350.0;
  double totalCashbackEarned = 45.0;
  double technicianEarnings = 1850.0;
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
    'الدوحة - قطر',
    'الريان - قطر',
    'لوسيل - قطر',
    'الوكرة - قطر',
  ];

  final List<String> notifications = [
    'مرحباً بك في النسخة المتكاملة لمنصة خدماتي • صيانة (العميل • الفني • الشركات • الإدارة).',
    'درع الكاش باك مفعل: احصل على 10% استرداد نقدي فوري وضمان 30 يوماً عند الدفع الإلكتروني.',
    'كتالوج أسعار قطع الغيار الرسمي متاح الآن لمنع أي تلاعب بالأسعار.',
  ];

  final List<ServiceItemModel> services = [
    ServiceItemModel(
      id: 'ac',
      name: 'تكييف وتبريد',
      subtitle: 'شحن فريون أصلي، غسيل كيميائي، وصيانة سبليت ومركزي',
      minPrice: 250,
      maxPrice: 650,
      inspectionFee: 50,
      icon: Icons.ac_unit,
      color: const Color(0xFF0284C7),
    ),
    ServiceItemModel(
      id: 'plumbing',
      name: 'سباكة',
      subtitle: 'كشف تسريبات بالضغط، خلاطات، ومواتير وفلاتر مياه',
      minPrice: 150,
      maxPrice: 450,
      inspectionFee: 50,
      icon: Icons.plumbing,
      color: const Color(0xFF0C2D48),
    ),
    ServiceItemModel(
      id: 'electric',
      name: 'كهرباء',
      subtitle: 'إصلاح قفلات، لوحات توزيع، نجف، وإنتركم ذكي',
      minPrice: 150,
      maxPrice: 500,
      inspectionFee: 50,
      icon: Icons.bolt,
      color: const Color(0xFFFF6B00),
    ),
    ServiceItemModel(
      id: 'appliances',
      name: 'أجهزة منزلية',
      subtitle: 'صيانة غسالات أوتوماتيك، ثلاجات، سخانات، وبوتاجازات',
      minPrice: 250,
      maxPrice: 700,
      inspectionFee: 50,
      icon: Icons.kitchen,
      color: const Color(0xFF4F46E5),
    ),
    ServiceItemModel(
      id: 'carpentry',
      name: 'نجارة وأقفال',
      subtitle: 'فتح وصيانة أبواب مصفحة، تغيير كوالين، ومطابخ',
      minPrice: 200,
      maxPrice: 600,
      inspectionFee: 50,
      icon: Icons.handyman,
      color: const Color(0xFF78350F),
    ),
    ServiceItemModel(
      id: 'cleaning',
      name: 'نظافة وتعقيم',
      subtitle: 'تنظيف شامل بعد التشطيب، خزانات مياه، وتعقيم بالبخار',
      minPrice: 350,
      maxPrice: 1200,
      inspectionFee: 50,
      icon: Icons.cleaning_services,
      color: const Color(0xFF16A34A),
    ),
  ];

  // كتالوج أسعار قطع الغيار الرسمي لمنع تلاعب الفنيين بالأسعار
  final List<SparePartItemModel> sparePartsCatalog = [
    SparePartItemModel(id: 'SP-1', name: 'شحن غاز فريون أمريكي أصلي R410A (كامل)', category: 'تكييف وتبريد', brand: 'Honeywell USA', officialPrice: 450, warrantyMonths: 6),
    SparePartItemModel(id: 'SP-2', name: 'كابستور تكييف 45/50 ميكروفاراد كوري', category: 'تكييف وتبريد', brand: 'Samwha Original', officialPrice: 180, warrantyMonths: 12),
    SparePartItemModel(id: 'SP-3', name: 'مروحة وحدة خارجية للتكييف 1.5 - 2.25 حصان', category: 'تكييف وتبريد', brand: 'Sharp / Carrier OEM', officialPrice: 520, warrantyMonths: 12),
    SparePartItemModel(id: 'SP-4', name: 'قلب خلاط مياه سيراميك ألماني 40 مم', category: 'سباكة', brand: 'Grohe / Ideal Standard', officialPrice: 160, warrantyMonths: 12),
    SparePartItemModel(id: 'SP-5', name: 'أوتوماتيك موتور مياه إيطالي أصلي (فلوماك)', category: 'سباكة', brand: 'Calpeda Italy', officialPrice: 380, warrantyMonths: 12),
    SparePartItemModel(id: 'SP-6', name: 'طقم شمعات فلتر مياه 7 مراحل حيوي', category: 'سباكة', brand: 'Tank / Aqua Pro', officialPrice: 290, warrantyMonths: 6),
    SparePartItemModel(id: 'SP-7', name: 'قاطع كهرباء أوتوماتيك فرعي 32 أمبير', category: 'كهرباء', brand: 'Schneider Electric', officialPrice: 175, warrantyMonths: 24),
    SparePartItemModel(id: 'SP-8', name: 'مفتاح حماية من التسريب الأرضي (Earth Leakage)', category: 'كهرباء', brand: 'ABB Original', officialPrice: 620, warrantyMonths: 24),
    SparePartItemModel(id: 'SP-9', name: 'طلمبة طرد غسالة أوتوماتيك أصلية', category: 'أجهزة منزلية', brand: 'LG / Zanussi OEM', officialPrice: 340, warrantyMonths: 12),
    SparePartItemModel(id: 'SP-10', name: 'هيتر سخان مياه نحاسي + ثرموستات أمان', category: 'أجهزة منزلية', brand: 'Ariston / Olympic', officialPrice: 280, warrantyMonths: 12),
    SparePartItemModel(id: 'SP-11', name: 'قلب كالون باب مصفح كمبيوتر ضد الكسر', category: 'نجارة وأقفال', brand: 'Yale / Cisa Security', officialPrice: 390, warrantyMonths: 24),
  ];

  // جواز السفر الصياني للمنزل (Home Maintenance Passport)
  final List<HomeApplianceModel> homeAppliances = [
    HomeApplianceModel(
      id: 'APP-1',
      name: 'تكييف سبليت إنفرتر 1.5 حصان',
      brand: 'Sharp العربي',
      locationRoom: 'غرفة المعيشة',
      lastMaintenanceDate: '2026-10-15',
      nextReminderDate: '2027-04-15 (قبل الصيف)',
      healthScore: 95,
      warrantyStatus: 'مشمول بضمان صيانة الذهبي',
    ),
    HomeApplianceModel(
      id: 'APP-2',
      name: 'موتور رفع مياه 1 حصان + فلوماك',
      brand: 'Calpeda إيطالي',
      locationRoom: 'منور العقار',
      lastMaintenanceDate: '2026-08-20',
      nextReminderDate: '2027-02-20',
      healthScore: 88,
      warrantyStatus: 'فحص دوري قادم خلال 90 يوماً',
    ),
    HomeApplianceModel(
      id: 'APP-3',
      name: 'غسالة ملابس ديجيتال 8 كجم',
      brand: 'LG Direct Drive',
      locationRoom: 'المطبخ',
      lastMaintenanceDate: '2026-09-10',
      nextReminderDate: '2027-03-10',
      healthScore: 92,
      warrantyStatus: 'ساري تحت الضمان الذهبي',
    ),
  ];

  // الشركات والمقاولون المعتمدون (بوابة الشركات)
  final List<CompanyItemModel> companies = [
    CompanyItemModel(
      id: 'COMP-1',
      name: 'شركة الرواد الهندسية للتكييف والصيانة المتكاملة',
      specialty: 'تكييف وتبريد • عقود سنوية',
      city: 'القاهرة',
      commercialReg: 'CR-884120',
      taxCard: 'TX-552-910-441',
      techniciansCount: 18,
      activeAmcContracts: 34,
      rating: 4.9,
      isVerified: true,
    ),
    CompanyItemModel(
      id: 'COMP-2',
      name: 'مؤسسة الدوحة والخليج للخدمات الفنية والكهرباء',
      specialty: 'كهرباء • سباكة • طوارئ 24/7',
      city: 'الدوحة - قطر',
      commercialReg: 'CR-441902',
      taxCard: 'TX-901-334-112',
      techniciansCount: 25,
      activeAmcContracts: 52,
      rating: 4.8,
      isVerified: true,
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
      nationalId: '29104150104421',
      idFrontPhoto: 'بطاقة_مصطفى_أمامي.jpg',
      idBackPhoto: 'بطاقة_مصطفى_خلفي.jpg',
      certificatePhoto: 'شهادة_مزاولة_تكييف.jpg',
      experienceYears: 8,
      walletNumber: '01066554433',
      companyAffiliation: 'شركة الرواد الهندسية للتكييف',
      rating: 4.9,
      completedJobs: 128,
      isVerified: true,
      approvalStatus: 'approved',
    ),
    TechnicianItemModel(
      id: 'TECH-2',
      name: 'م. حسن عبد السلام',
      specialty: 'سباكة',
      city: 'القاهرة',
      phone: '01022334455',
      distanceKm: 2.4,
      nationalId: '29308220105519',
      idFrontPhoto: 'بطاقة_حسن_أمامي.jpg',
      idBackPhoto: 'بطاقة_حسن_خلفي.jpg',
      certificatePhoto: 'فيش_جنائي_معتمد.jpg',
      experienceYears: 6,
      walletNumber: '01022334455',
      companyAffiliation: 'فني مستقل معتمد',
      rating: 4.8,
      completedJobs: 94,
      isVerified: true,
      approvalStatus: 'approved',
    ),
    TechnicianItemModel(
      id: 'TECH-3',
      name: 'م. كريم طارق (طلب انضمام جديد)',
      specialty: 'كهرباء',
      city: 'الجيزة',
      phone: '01099881122',
      distanceKm: 1.5,
      nationalId: '29611050108834',
      idFrontPhoto: 'هوية_كريم_طارق_أمامي.jpg',
      idBackPhoto: 'هوية_كريم_طارق_خلفي.jpg',
      certificatePhoto: 'شهادة_خبرة_كهرباء_وإنتركم.jpg',
      experienceYears: 4,
      walletNumber: '01099881122',
      companyAffiliation: 'فني مستقل معتمد',
      rating: 4.7,
      completedJobs: 0,
      isVerified: false,
      approvalStatus: 'pending',
    ),
  ];

  final List<OrderItemModel> orders = [
    OrderItemModel(
      id: 'KH-9041',
      serviceName: 'تكييف وتبريد',
      description: 'التكييف يخرج هواء غير بارد مع صوت طنين في الوحدة الخارجية ويحتاج فحص الفريون والكابستور',
      attachedPhotos: [
        'قبل_الوحدة_الداخلية.jpg',
        'بعد_تنظيف_وشحن_الفريون.jpg',
        'قطعة_كابستور تكييف 45/50 ميكروفاراد كوري (180 ج.م)',
        'وسم_الأمان_العائلي',
      ],
      city: 'القاهرة',
      address: 'مدينة نصر - شارع عباس العقاد - برج التطبيقيين الدور 5',
      mapCoordinates: '30.0561 N, 31.3301 E (GPS نشط)',
      appointmentSlot: 'اليوم - الفترة المسائية (04:00 م - 07:00 م)',
      assignmentMode: 'استلام ومقارنة عروض أسعار (نظام صيانة)',
      customerName: 'أحمد محمود',
      customerPhone: '01012345678',
      pinCode: '4829',
      paymentMethod: 'فودافون كاش (Vodafone Cash)',
      statusIndex: 1,
      price: 430,
      technicianId: 'TECH-1',
      technicianName: 'م. مصطفى السيد (يبعد 1.2 كم)',
      technicianPhone: '01066554433',
      isPaid: false,
      chatMessages: [
        'النظام: تم تعيين م. مصطفى السيد (موثق الهوية الوطنية لدى الإدارة) وتفعيل وضع الأمان العائلي.',
        'المقايسة الإلكترونية: مصنعية (300 ج.م) + قطعة كابستور رسمي (180 ج.م) - خصم رسوم المعاينة (-50 ج.م) = 430 ج.م.',
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
    if (supabaseUrl.trim().isEmpty || supabaseAnonKey.trim().isEmpty) return;
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
        lastSyncStatus = 'تنبيه سحابة Supabase: كود ${res.statusCode}';
      }

      final notifUri = Uri.parse('$_cleanBaseUrl/rest/v1/notifications?select=*&order=id.desc&limit=10');
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
      lastSyncStatus = 'يعمل بالذاكرة المحلية (اضغط ربط السحابة للمزامنة)';
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

  // ===========================================================================
  // محرك التشخيص الذكي بالذكاء الاصطناعي (النص + الصورة + الصوت + كتالوج القطع)
  // ===========================================================================
  Future<AiDiagnosisResultModel> runSmartAiDiagnosis({
    required String descriptionText,
    required String soundPattern,
    required bool hasPhoto,
  }) async {
    final text = '$descriptionText $soundPattern'.toLowerCase();

    // في حال إدخال مفتاح Gemini API اختياري، يستدعي نموذج gemini-2.5-flash لتعزيز الوصف
    String aiExtraNote = '';
    if (geminiApiKey.trim().isNotEmpty) {
      try {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${geminiApiKey.trim()}',
        );
        final res = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {
                        'text':
                            'شخص هذا العطل المنزلي باختصار في سطرين باللغة العربية وحدد السبب الفني: $descriptionText - نمط الصوت: $soundPattern'
                      }
                    ]
                  }
                ]
              }),
            )
            .timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final decoded = jsonDecode(utf8.decode(res.bodyBytes));
          aiExtraNote =
              '\n(تحليل Gemini 2.5 Flash: ${decoded['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? ''})';
        }
      } catch (_) {}
    }

    if (text.contains('تكييف') || text.contains('فريون') || text.contains('تبريد') || text.contains('طنين')) {
      final parts = sparePartsCatalog.where((p) => p.id == 'SP-1' || p.id == 'SP-2').toList();
      return AiDiagnosisResultModel(
        title: 'تشخيص ذكي: ضعف كفاءة التبريد أو كابستور الوحدة الخارجية',
        technicalCause:
            'بناءً على تحليل الأعراض ونمط صوت الوحدة الخارجية، يرجح تلف كابستور الإقلاع (45 ميكروفاراد) أو نقص ضغط غاز الفريون R410A مع انسداد فلاتر المبخر.$aiExtraNote',
        recommendedService: 'تكييف وتبريد',
        suggestedParts: parts,
        estimatedLabor: 250,
        inspectionFee: 50,
        isUrgentSos: false,
      );
    } else if (text.contains('مياه') || text.contains('موتور') || text.contains('تسريب') || text.contains('سباكة')) {
      final parts = sparePartsCatalog.where((p) => p.id == 'SP-4' || p.id == 'SP-5').toList();
      return AiDiagnosisResultModel(
        title: 'تشخيص ذكي: خلل في أوتوماتيك ضغط المياه (الفلوماك) أو تهريب بالوصلات',
        technicalCause:
            'يشير التقطيع المتكرر في صوت الموتور أو ضعف اندفاع المياه إلى تلف بردة الفلوماك الإيطالي أو تآكل قلب الخلاط السيراميك.$aiExtraNote',
        recommendedService: 'سباكة',
        suggestedParts: parts,
        estimatedLabor: 200,
        inspectionFee: 50,
        isUrgentSos: text.contains('غرق') || text.contains('تسريب'),
      );
    } else if (text.contains('كهرباء') || text.contains('قفلة') || text.contains('شرز') || text.contains('قاطع')) {
      final parts = sparePartsCatalog.where((p) => p.id == 'SP-7' || p.id == 'SP-8').toList();
      return AiDiagnosisResultModel(
        title: 'تشخيص ذكي (حرج): حمل زائد أو تلامس أرضي في لوحة التوزيع',
        technicalCause:
            'صوت الشرز الكهربائي أو فصل القاطع المتكرر يدل على ضعف نقاط التلامس في القاطع الفرعي 32 أمبير ويستلزم تغييره بقاطع معتمد فوراً للأمان.$aiExtraNote',
        recommendedService: 'كهرباء',
        suggestedParts: parts,
        estimatedLabor: 200,
        inspectionFee: 50,
        isUrgentSos: true,
      );
    } else {
      final parts = sparePartsCatalog.where((p) => p.id == 'SP-9' || p.id == 'SP-10').toList();
      return AiDiagnosisResultModel(
        title: 'تشخيص ذكي: عطل في طلمبة الطرد أو منظومة التسخين بالأجهزة المنزلية',
        technicalCause:
            'تم رصد انسداد أو ضعف في طلمبة الطرد / هيتر التسخين، ويوصى باستبدال القطعة الأصلية من الكتالوج الرسمي مع ضمان 12 شهراً.$aiExtraNote',
        recommendedService: 'أجهزة منزلية',
        suggestedParts: parts,
        estimatedLabor: 250,
        inspectionFee: 50,
        isUrgentSos: false,
      );
    }
  }

  // ===========================================================================
  // رادار الطوارئ السريع (SOS 45-Min SLA Emergency Dispatch)
  // ===========================================================================
  OrderItemModel triggerSosEmergencyOrder({
    required String serviceName,
    required String urgentDescription,
    required String address,
  }) {
    final order = createOrder(
      serviceName: serviceName,
      description: '[SOS طوارئ 45 دقيقة] $urgentDescription',
      photos: ['قبل_بلاغ_طوارئ_SOS.jpg', 'وسم_SOS', 'وسم_الأمان_العائلي'],
      address: address,
      mapCoords: 'رادار GPS للطوارئ نشط - توجيه لأقرب 5 فنيين (يبعد 0.8 كم)',
      appointmentSlot: 'طوارئ فورية SOS (وصول مضمون خلال 45 دقيقة)',
      assignmentMode: 'رادار الطوارئ التلقائي SOS',
      paymentMethod: 'فودافون كاش (Vodafone Cash)',
      price: 350,
    );
    _pushNotificationToSupabase(
      '🚨 نداء رادار طوارئ SOS #${order.id} ($serviceName): تم استنفار أقرب الفنيين للوصول خلال 45 دقيقة!',
    );
    return order;
  }

  // ===========================================================================
  // المقايسة الإلكترونية المعتمدة + إضافة قطع الغيار بالسعر الرسمي + خصم المعاينة
  // ===========================================================================
  void addOfficialSparePartToOrder(String orderId, SparePartItemModel part) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final order = orders[idx];
    final tag = 'قطعة_${part.name} (${part.officialPrice} ج.م)';
    if (!order.attachedPhotos.contains(tag)) {
      order.attachedPhotos.add(tag);
      order.price += part.officialPrice;
      order.chatMessages.add(
        'مقايسة إلكترونية رسمية: أضاف الفني [${part.name}] بالسعر الرسمي للكتالوج (${part.officialPrice} ج.م) بضمان ${part.warrantyMonths} شهور.',
      );
      notifyListeners();
      _pushOrderToSupabase(order, isUpdate: true);
    }
  }

  void approveElectronicQuoteWithInspectionDeduction(String orderId) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final order = orders[idx];
    if (!order.attachedPhotos.contains('وسم_مقايسة_معتمدة')) {
      order.attachedPhotos.add('وسم_مقايسة_معتمدة');
      order.price = (order.price - 50).clamp(100, 99999);
      order.chatMessages.add(
        'اعتماد المقايسة ✅: وافق العميل على المقايسة الإلكترونية وتم خصم رسوم المعاينة (-50 ج.م) تلقائياً ليكون الصافي ${order.price} ج.م.',
      );
      notifyListeners();
      _pushOrderToSupabase(order, isUpdate: true);
      _pushNotificationToSupabase('تم اعتماد المقايسة الإلكترونية للطلب #${order.id} وخصم رسوم المعاينة 50 ج.م.');
    }
  }

  // ===========================================================================
  // وضع الأمان العائلي (Family Safe Mode)
  // ===========================================================================
  void toggleFamilySafeMode(String orderId) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final order = orders[idx];
    if (order.attachedPhotos.contains('وسم_الأمان_العائلي')) {
      order.attachedPhotos.remove('وسم_الأمان_العائلي');
      order.chatMessages.add('الأمان العائلي: تم إيقاف مشاركة رابط التتبع العائلي.');
    } else {
      order.attachedPhotos.add('وسم_الأمان_العائلي');
      order.chatMessages.add(
        'درع الأمان العائلي 🛡️: تم تفعيل رابط التتبع الحي لرب الأسرة (${order.familyTrackingLink}) مع هوية الفني الموثقة.',
      );
    }
    notifyListeners();
    _pushOrderToSupabase(order, isUpdate: true);
  }

  // ===========================================================================
  // تحديث أسعار كتالوج قطع الغيار الرسمي (للإدارة) وإضافة أجهزة لجواز المنزل
  // ===========================================================================
  void updateSparePartPrice(String partId, int newPrice) {
    final idx = sparePartsCatalog.indexWhere((p) => p.id == partId);
    if (idx != -1) {
      sparePartsCatalog[idx].officialPrice = newPrice;
      notifyListeners();
      _pushNotificationToSupabase(
        'تحديث رسمي للكتالوج: تم تعديل سعر [${sparePartsCatalog[idx].name}] إلى $newPrice ج.م.',
      );
    }
  }

  void addHomeApplianceToPassport({
    required String name,
    required String brand,
    required String room,
  }) {
    homeAppliances.insert(
      0,
      HomeApplianceModel(
        id: 'APP-${homeAppliances.length + 10}',
        name: name,
        brand: brand,
        locationRoom: room,
        lastMaintenanceDate: '2026-11-12',
        nextReminderDate: '2027-05-12',
        healthScore: 100,
        warrantyStatus: 'مسجل حديثاً في جواز المنزل الصياني',
      ),
    );
    notifyListeners();
  }

  void registerNewCompany({
    required String name,
    required String specialty,
    required String city,
    required String commercialReg,
    required String taxCard,
    required int fleetCount,
  }) {
    companies.insert(
      0,
      CompanyItemModel(
        id: 'COMP-${companies.length + 10}',
        name: name,
        specialty: specialty,
        city: city,
        commercialReg: commercialReg,
        taxCard: taxCard,
        techniciansCount: fleetCount,
        activeAmcContracts: 1,
        rating: 5.0,
        isVerified: true,
      ),
    );
    notifyListeners();
    _pushNotificationToSupabase('انضمام شركة صيانة جديدة: ($name) بسجل تجاري [$commercialReg] وأسطول ($fleetCount فنيين).');
  }

  TechnicianItemModel registerNewTechnicianApplication({
    required String name,
    required String phone,
    required String specialty,
    required String city,
    required String nationalId,
    required String idFrontPhoto,
    required String idBackPhoto,
    required String certificatePhoto,
    required int experienceYears,
    required String walletNumber,
    String companyAffiliation = 'فني مستقل معتمد',
  }) {
    final id = 'TECH-${technicians.length + 10}';
    final tech = TechnicianItemModel(
      id: id,
      name: name,
      specialty: specialty,
      city: city,
      phone: phone,
      distanceKm: 1.4,
      nationalId: nationalId,
      idFrontPhoto: idFrontPhoto,
      idBackPhoto: idBackPhoto,
      certificatePhoto: certificatePhoto,
      experienceYears: experienceYears,
      walletNumber: walletNumber,
      companyAffiliation: companyAffiliation,
      rating: 5.0,
      completedJobs: 0,
      isVerified: false,
      approvalStatus: 'pending',
    );
    technicians.insert(0, tech);
    notifyListeners();
    _pushNotificationToSupabase(
      'طلب توثيق فني جديد: ($name - $specialty - $city) برقم هوية [$nationalId] بانتظار موافقة الإدارة.',
    );
    return tech;
  }

  void reviewTechnicianApplication(String techId, {required bool approve}) {
    final idx = technicians.indexWhere((t) => t.id == techId);
    if (idx == -1) return;
    final tech = technicians[idx];
    tech.isVerified = approve;
    tech.approvalStatus = approve ? 'approved' : 'rejected';
    notifyListeners();
    _pushNotificationToSupabase(
      approve
          ? 'موافقة الإدارة ✅: تم التحقق من هوية الفني (${tech.name}) واعتماده رسمياً لاستقبال الطلبات!'
          : 'قرار الإدارة ❌: تم رفض طلب تسجيل الفني (${tech.name}) لعدم مطابقة صورة الهوية.',
    );
  }

  void addOrderMaintenancePhoto(String orderId, {required bool isAfterPhoto}) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final order = orders[idx];
    final prefix = isAfterPhoto ? 'بعد_الإصلاح' : 'قبل_الصيانة';
    final fileName = '${prefix}_${DateTime.now().second}.jpg';
    order.attachedPhotos.add(fileName);
    order.chatMessages.add(
      isAfterPhoto
          ? 'توثيق الفني: تم رفع صورة بعد إتمام الصيانة ($fileName) وتفعيل شهادة الضمان الذهبي.'
          : 'توثيق الفني: تم رفع صورة العطل قبل بدء الصيانة ($fileName).',
    );
    notifyListeners();
    _pushOrderToSupabase(order, isUpdate: true);
  }

  // الدفع الإلكتروني مع منح العميل 10% كاش باك فوري وتفعيل الضمان الذهبي
  void markOrderPaid(String orderId, String methodLabel, String referenceCode) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    final order = orders[idx];
    order.isPaid = true;
    final int cashback = order.cashbackAmount;
    customerWallet += cashback;
    totalCashbackEarned += cashback;

    order.chatMessages.add(
      'إيصال دفع إلكتروني + درع الكاش باك 🎁: تم سداد ${order.price} ج.م عبر $methodLabel (مرجع: $referenceCode) وإضافة $cashback ج.م (10% كاش باك) لمحفظة العميل وتفعيل الضمان الذهبي 30 يوماً!',
    );
    notifyListeners();
    _pushOrderToSupabase(order, isUpdate: true);
    _pushNotificationToSupabase(
      'تم سداد الطلب #${order.id} عبر $methodLabel وحصل العميل على $cashback ج.م كاش باك فوري!',
    );
  }

  void rechargeWalletViaSandbox(int amount, String methodLabel, String referenceCode) {
    final int bonus = (amount * 0.10).round();
    customerWallet += (amount + bonus);
    totalCashbackEarned += bonus;
    notifyListeners();
    _pushNotificationToSupabase(
      'شحن محفظة + هدية 10%: تم شحن $amount ج.م وإضافة $bonus ج.م رصيد إضافي عبر $methodLabel ($referenceCode)',
    );
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
    bool isPaidInitially = false,
    String? paymentRef,
  }) {
    final String pin = (1000 + (DateTime.now().millisecond % 8999)).toString();
    final String id = 'KH-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

    final approvedTechs = technicians.where((t) => t.isVerified).toList();
    TechnicianItemModel chosenTech = approvedTechs.isNotEmpty ? approvedTechs.first : technicians.first;

    if (manualTechId != null) {
      for (final t in technicians) {
        if (t.id == manualTechId) chosenTech = t;
      }
    } else {
      for (final t in approvedTechs) {
        if (t.specialty == serviceName) {
          chosenTech = t;
          break;
        }
      }
    }

    final initialChats = <String>[
      'النظام: تم تسجيل الطلب وتعيين المزود المعتمد (${chosenTech.name}) - رسوم المعاينة (50 ج.م) تُخصم مجاناً عند الإصلاح.',
    ];
    if (isPaidInitially && paymentRef != null) {
      final int cashback = (price * 0.10).round();
      customerWallet += cashback;
      totalCashbackEarned += cashback;
      initialChats.add(
        'إيصال دفع مسبق + 10% كاش باك: تم سداد $price ج.م عبر $paymentMethod (مرجع: $paymentRef) وإضافة $cashback ج.م لمحفظتك.',
      );
    }

    final normalizedPhotos = photos.isEmpty
        ? ['قبل_صورة_العطل_1.jpg', 'وسم_الأمان_العائلي']
        : photos
            .map((p) => (p.startsWith('قبل_') || p.startsWith('بعد_') || p.startsWith('قطعة_') || p.startsWith('وسم_'))
                ? p
                : 'قبل_$p')
            .toList();

    final order = OrderItemModel(
      id: id,
      serviceName: serviceName,
      description: description.trim().isEmpty ? 'طلب صيانة وفحص شامل ($serviceName)' : description.trim(),
      attachedPhotos: normalizedPhotos,
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
      isPaid: isPaidInitially,
      chatMessages: initialChats,
    );

    orders.insert(0, order);
    activeOrderId = order.id;
    notifyListeners();

    _pushOrderToSupabase(order, isUpdate: false);
    _pushNotificationToSupabase('طلب جديد #$id ($serviceName) في $selectedCity - الدفع: $paymentMethod');
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
      order.chatMessages.add('الفني: أنا في الطريق إليك الآن عبر موقع الخريطة المحدد (الأمان العائلي مفعل).');
    } else if (next == 3) {
      order.chatMessages.add('الفني: وصلت للموقع وتم مطابقة كود PIN (${order.pinCode}) وتصوير العطل قبل البدء.');
    } else if (next == 4) {
      order.isPaid = true;
      if (order.afterPhotos.isEmpty) {
        order.attachedPhotos.add('بعد_إتمام_الإصلاح_الموثق.jpg');
      }
      technicianEarnings += (order.price * 0.85);
      order.chatMessages.add(
        'النظام: اكتمل الطلب بنجاح وتم توثيق صور (قبل وبعد) وتحديث جواز السفر الصياني للمنزل وإصدار شهادة الضمان (${order.warrantyNumber}).',
      );
    }
    notifyListeners();
    _pushOrderToSupabase(order, isUpdate: true);
    _pushNotificationToSupabase('تحديث سحابي للطلب #${order.id}: الحالة الآن (${order.statusText})');
  }

  void rejectOrderByTechnician(String orderId) {
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx == -1) return;
    orders[idx].technicianName = 'جاري إعادة التعيين التلقائي لأقرب فني معتمد بديل...';
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
      final newState = !technicians[idx].isVerified;
      reviewTechnicianApplication(techId, approve: newState);
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