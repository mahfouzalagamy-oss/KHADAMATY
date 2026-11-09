import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const KhadamatyApp());
}

class ServiceOrder {
  final String id;
  final String category;
  final String description;
  final String city;
  final String customerName;
  final String customerPhone;
  final String pinCode;
  String status; // 'بانتظار عروض الفنيين', 'تم تقديم عرض سعر', 'جاري التنفيذ', 'مكتمل ومضمون'
  int price;
  String technicianName;
  final String warrantyEnd;
  final bool isEmergency;

  ServiceOrder({
    required this.id,
    required this.category,
    required this.description,
    required this.city,
    required this.customerName,
    required this.customerPhone,
    required this.pinCode,
    required this.status,
    required this.price,
    required this.technicianName,
    required this.warrantyEnd,
    this.isEmergency = false,
  });
}

class KhadamatyApp extends StatelessWidget {
  const KhadamatyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'خدماتي - KHADAMATY',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        colorSchemeSeed: const Color(0xFF0F766E),
      ),
      home: const Directionality(
        textDirection: TextDirection.rtl,
        child: MainPlatformShell(),
      ),
    );
  }
}

class MainPlatformShell extends StatefulWidget {
  const MainPlatformShell({super.key});

  @override
  State<MainPlatformShell> createState() => _MainPlatformShellState();
}

class _MainPlatformShellState extends State<MainPlatformShell> {
  int _selectedPortal = 0; // 0: عميل, 1: فني, 2: شركات B2B, 3: إدارة KHADAMATY
  int _bottomTab = 0; // 0: الرئيسية, 1: طلباتي/مهامي, 2: الرسائل والدعم, 3: محفظتي و QR
  String _selectedCity = 'المنصورة';
  double _customerWallet = 100.0;
  double _techWallet = 420.0;
  bool _techOnline = true;

  final List<String> _cities = [
    'القاهرة', 'الجيزة', 'الإسكندرية', 'المنصورة', 'طنطا', 'الزقازيق', 'أسيوط', 'أسوان'
  ];

  final List<ServiceOrder> _orders = [
    ServiceOrder(
      id: 'KH-9041',
      category: 'تكييف وتبريد',
      description: 'شحن فريون وصيانة تكييف شارب 1.5 حصان مع تنظيف الوحدة الداخلية',
      city: 'المنصورة',
      customerName: 'أحمد محمود',
      customerPhone: '01012345678',
      pinCode: '4829',
      status: 'بانتظار عروض الفنيين',
      price: 450,
      technicianName: 'بانتظار قبول فني',
      warrantyEnd: '2026-12-10',
      isEmergency: true,
    ),
    ServiceOrder(
      id: 'KH-8820',
      category: 'سباكة',
      description: 'تغيير خلاط مياه وإصلاح تسريب أسفل الحوض بقطع غيار أصلية',
      city: 'المنصورة',
      customerName: 'أحمد محمود',
      customerPhone: '01012345678',
      pinCode: '7712',
      status: 'مكتمل ومضمون',
      price: 350,
      technicianName: 'م. مصطفى السيد (فني معتمد)',
      warrantyEnd: '2027-01-15',
    ),
  ];

  final List> _pendingTechnicians = [
    {
      'name': 'محمود عبد الرحمن',
      'specialty': 'فني تكييف وتبريد',
      'city': 'المنصورة',
      'nationalId': '29405121200914',
      'criminalRecord': 'تم إرفاق الفيش الجنائي ساري',
      'approved': false,
    },
    {
      'name': 'إبراهيم عادل',
      'specialty': 'فني كهرباء منازل ذكية',
      'city': 'القاهرة',
      'nationalId': '29108190102345',
      'criminalRecord': 'تم إرفاق الفيش الجنائي ساري',
      'approved': false,
    },
  ];

  final List> _b2bContracts = [
    {
      'company': 'مجموعة صيدليات الشفاء (12 فرع)',
      'plan': 'عقد صيانة سنوي شامل (تكييف + كهرباء)',
      'visitsLeft': 18,
      'monthlyFee': 4500,
      'status': 'ساري ومفعل',
    },
    {
      'company': 'مطاعم النيل السياحية (4 فروع)',
      'plan': 'عقد طوارئ سباكة وتبريد غرف تجميد',
      'visitsLeft': 9,
      'monthlyFee': 3200,
      'status': 'ساري ومفعل',
    },
  ];

  Color get _portalPrimaryColor {
    switch (_selectedPortal) {
      case 0:
        return const Color(0xFF0F766E); // أخضر زمردي للعميل
      case 1:
        return const Color(0xFF1D4ED8); // أزرق ملكي للفني
      case 2:
        return const Color(0xFF6D28D9); // بنفسجي للشركات B2B
      case 3:
        return const Color(0xFFB91C1C); // أحمر داكن للإدارة العليا
      default:
        return const Color(0xFF0F766E);
    }
  }

  Future<void> _generateWarrantyPdf(ServiceOrder order) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(24),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.teal800, width: 3),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('KHADAMATY OFFICIAL WARRANTY CERTIFICATE',
                    style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                pw.SizedBox(height: 8),
                pw.Text('Official Digital Invoice & 30-Day Money-Back Guarantee - www.khadamaty.com',
                    style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700)),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 16),
                pw.Text('Order Reference: ${order.id}', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.Text('Service Category: ${order.category}'),
                pw.Text('City / Location: ${order.city}'),
                pw.Text('Customer Phone: ${order.customerPhone}'),
                pw.Text('Certified Technician: ${order.technicianName}'),
                pw.Text('Home Security PIN Verified: ${order.pinCode}'),
                pw.Text('Total Paid Amount: ${order.price} EGP'),
                pw.Text('Warranty Valid Until: ${order.warrantyEnd}'),
                pw.SizedBox(height: 24),
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: 'https://www.khadamaty.com/verify?order=${order.id}&pin=${order.pinCode}&price=${order.price}',
                  width: 110,
                  height: 110,
                ),
                pw.SizedBox(height: 12),
                pw.Text('Scan QR Code to verify authenticity on KHADAMATY Platform.'),
              ],
            ),
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  void _showNewOrderDialog(String category, String minMaxPrice, {bool isEmergency = false}) {
    final descController = TextEditingController();
    final priceController = TextEditingController(text: isEmergency ? '550' : '400');

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(isEmergency ? '🚨 طلب طوارئ عاجل (خلال 45 دقيقة) - $category' : 'طلب صيانة معتمد - $category'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade400),
                  ),
                  child: Text('💡 مؤشر السعر العادل في $_selectedCity: $minMaxPrice ج.م (شامل الكشف والضمان 30 يوماً)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'وصف العطل أو الخدمة المطلوبة بالتفصيل',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'السعر المقترح للخدمة (ج.م)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            FilledButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('إرسال الطلب وتوليد كود الأمان PIN'),
              onPressed: () {
                final newPin = (1000 + DateTime.now().millisecond * 8).toString().substring(0, 4);
                final newOrder = ServiceOrder(
                  id: 'KH-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
                  category: category,
                  description: descController.text.isEmpty ? 'طلب صيانة وفحص شامل ($category)' : descController.text,
                  city: _selectedCity,
                  customerName: 'عميل خدماتي',
                  customerPhone: '01012345678',
                  pinCode: newPin,
                  status: 'بانتظار عروض الفنيين',
                  price: int.tryParse(priceController.text) ?? 400,
                  technicianName: 'بانتظار قبول فني',
                  warrantyEnd: '2026-12-30',
                  isEmergency: isEmergency,
                );
                setState(() {
                  _orders.insert(0, newOrder);
                  _bottomTab = 1; // الانتقال مباشرة لصفحة الطلبات لرؤية الطلب الجديد
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.teal.shade800,
                    content: Text('✅ تم إنشاء الطلب ${newOrder.id} بنجاح! كود الأمان المنزلي PIN: $newPin (افتح بوابة الفنيين الآن لقبوله)'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showQrModal(String title, String qrData, String subtitle) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(title, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: QrImageView(data: qrData, version: QrVersions.auto),
              ),
              const SizedBox(height: 12),
              Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          actions: [
            FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              children: [
                _buildTopPortalSelectorBar(),
                _buildAppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildActiveScreenContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // شريط التبديل العلوي بين البوابات الأربع
  Widget _buildTopPortalSelectorBar() {
    final portals = [
      {'title': 'بوابة العميل', 'icon': Icons.person},
      {'title': 'بوابة الفنيين', 'icon': Icons.handyman},
      {'title': 'بوابة الشركات B2B', 'icon': Icons.business},
      {'title': 'إدارة KHADAMATY', 'icon': Icons.admin_panel_settings},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      color: Colors.white,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List.generate(portals.length, (index) {
          final isSelected = _selectedPortal == index;
          return ChoiceChip(
            avatar: Icon(
              portals[index]['icon'] as IconData,
              size: 18,
              color: isSelected ? Colors.white : _portalPrimaryColor,
            ),
            label: Text(
              portals[index]['title'] as String,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: isSelected,
            selectedColor: _portalPrimaryColor,
            onSelected: (_) {
              setState(() {
                _selectedPortal = index;
                _bottomTab = 0; // إعادة التبويب السفلي للرئيسية عند تغيير البوابة
              });
            },
          );
        }),
      ),
    );
  }

  // هيدر التطبيق المتغير حسب البوابة النشطة
  Widget _buildAppHeader() {
    final portalTitles = [
      'بوابة العملاء المضمونة',
      'بوابة الفنيين المعتمدين (استقبال الطلبات)',
      'بوابة عقود الشركات والمؤسسات B2B',
      'لوحة تحكم المدير العام - إدارة KHADAMATY',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _portalPrimaryColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.home_repair_service, color: _portalPrimaryColor, size: 28),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('خدماتي KHADAMATY', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
                  Text(
                    portalTitles[_selectedPortal],
                    style: TextStyle(fontSize: 12, color: _portalPrimaryColor, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _selectedPortal == 1
                      ? 'محفظة الفني: ${_techWallet.toInt()} ج.م'
                      : 'الرصيد: ${_customerWallet.toInt()} ج.م',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: _selectedCity,
                underline: const SizedBox(),
                items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCity = val!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // الموجه الذكي الذي يعرض شاشة مختلفة كلياً لكل بوابة ولكل تبويب سفلي
  Widget _buildActiveScreenContent() {
    // إذا اختار المستخدم أحد التبويبات السفلية (الطلبات، الرسائل، المحفظة)
    if (_bottomTab == 1) return _buildOrdersAndWarrantyTab();
    if (_bottomTab == 2) return _buildMessagesAndSupportTab();
    if (_bottomTab == 3) return _buildWalletAndQrTab();

    // إذا كان في التبويب الرئيسي (0)، نعرض البوابة المختارة من الأعلى
    switch (_selectedPortal) {
      case 0:
        return _buildCustomerPortalHome();
      case 1:
        return _buildTechnicianPortalHome();
      case 2:
        return _buildB2BPortalHome();
      case 3:
        return _buildAdminPortalHome();
      default:
        return _buildCustomerPortalHome();
    }
  }

  // ===========================================================================
  // 1. بوابة العميل (Customer Portal)
  // ===========================================================================
  Widget _buildCustomerPortalHome() {
    final services = [
      {'name': 'تكييف وتبريد', 'icon': Icons.ac_unit, 'color': Colors.blue, 'price': '250 - 650'},
      {'name': 'سباكة', 'icon': Icons.plumbing, 'color': Colors.teal, 'price': '150 - 450'},
      {'name': 'كهرباء', 'icon': Icons.bolt, 'color': Colors.amber.shade800, 'price': '150 - 500'},
      {'name': 'أجهزة منزلية', 'icon': Icons.local_laundry_service, 'color': Colors.indigo, 'price': '250 - 700'},
      {'name': 'نجارة', 'icon': Icons.handyman, 'color': Colors.brown, 'price': '200 - 600'},
      {'name': 'نظافة شاملة', 'icon': Icons.cleaning_services, 'color': Colors.green, 'price': '350 - 1200'},
      {'name': 'نقاشة ودهانات', 'icon': Icons.format_paint, 'color': Colors.pink, 'price': '500 - 2500'},
      {'name': 'عقود شركات B2B', 'icon': Icons.business_center, 'color': Colors.deepPurple, 'price': 'باقات شهرية'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // شريط الإجراءات السريعة للعميل
        Card(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _quickActionButton(Icons.emergency_share, 'طوارئ 45 د', Colors.red, () {
                  _showNewOrderDialog('طوارئ عاجلة', '300 - 700', isEmergency: true);
                }),
                _quickActionButton(Icons.qr_code_2, 'QR التطبيق', Colors.indigo, () {
                  _showQrModal('رابط تطبيق خدماتي KHADAMATY', 'https://khadamaty.mahfouzalagamy.workers.dev',
                      'امسح الرمز لفتح وتثبيت تطبيق خدماتي على أي هاتف');
                }),
                _quickActionButton(Icons.phone_in_talk, 'اتصال مباشر', Colors.blue, () {
                  launchUrl(Uri.parse('tel:19999'));
                }),
                _quickActionButton(Icons.chat, 'واتساب', Colors.green, () {
                  launchUrl(Uri.parse('https://wa.me/201000000000?text=مرحبا، أحتاج مساعدة في تطبيق خدماتي'));
                }),
                _quickActionButton(Icons.verified_user, 'ضمان PDF', Colors.deepPurple, () {
                  _generateWarrantyPdf(_orders.first);
                }),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('محتاج خدمة إيه النهاردة؟',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('اختر القسم لطلب فني معتمد بكود أمان منزلي PIN وضمان رسمي 30 يوماً',
            textAlign: TextAlign.center, style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 16),

        // بانر التشخيص الصوتي والفيديو
        InkWell(
          onTap: () => _showNewOrderDialog('تشخيص ذكي بالصوت/الفيديو', '200 - 500'),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF115E59)]),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              children: [
                Icon(Icons.mic_external_on, color: Colors.white, size: 38),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('مش عارف تختار؟ (تشخيص صوتي / فيديو)',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      Text('صف المشكلة بصوتك أو فيديو قصير واعرف السعر الاسترشادي العادل فوراً',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('الأقسام المعتمدة في خدماتي (اضغط لطلب الخدمة):',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final item = services[index];
            return InkWell(
              onTap: () {
                if (item['name'] == 'عقود شركات B2B') {
                  setState(() => _selectedPortal = 2);
                } else {
                  _showNewOrderDialog(item['name'] as String, item['price'] as String);
                }
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: (item['color'] as Color).withOpacity(0.12),
                      child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 28),
                    ),
                    const SizedBox(height: 10),
                    Text(item['name'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 2),
                    Text('${item['price']} ج.م',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ===========================================================================
  // 2. بوابة الفنيين (Technician Portal - شاشة مختلفة كلياً)
  // ===========================================================================
  Widget _buildTechnicianPortalHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // لوحة حالة الفني وأرباحه
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('لوحة عمليات الفني المعتمد',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('م. مصطفى السيد • تخصص تكييف وسباكة • تقييم 4.9 ⭐',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                  Switch(
                    value: _techOnline,
                    activeColor: Colors.greenAccent,
                    onChanged: (v) => setState(() => _techOnline = v),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statBox('رصيد المحفظة', '${_techWallet.toInt()} ج.م', Colors.white),
                  _statBox('طلبات متاحة بالمنطقة', '${_orders.length} طلبات', Colors.amberAccent),
                  _statBox('عمولة المنصة', '15% فقط', Colors.greenAccent),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('📡 رادار طلبات العملاء المباشرة في $_selectedCity:',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('شحن محفظة الفني (فوري/فودافون كاش)'),
              onPressed: () {
                setState(() => _techWallet += 200);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ تم شحن محفظة الفني بمبلغ 200 ج.م بنجاح!')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // قائمة الطلبات الحية التي يمكن للفني تقديم عرض سعر عليها أو إنهاؤها بكود PIN
        ..._orders.map((order) => Card(
              margin: const EdgeInsets.only(bottom: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (order.isEmergency)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                margin: const EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                    color: Colors.red.shade100, borderRadius: BorderRadius.circular(6)),
                                child: const Text('🚨 طوارئ 45 د',
                                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                              ),
                            Text('${order.category} (${order.id})',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Chip(
                          label: Text(order.status, style: const TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.blue.shade50,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('وصف العطل: ${order.description}', style: const TextStyle(fontSize: 14)),
                    const SizedBox(height: 6),
                    Text('📍 المدينة: ${order.city} • العميل: ${order.customerName} • السعر المعروض: ${order.price} ج.م',
                        style: const TextStyle(color: Colors.black54, fontSize: 13)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        if (order.status == 'بانتظار عروض الفنيين')
                          FilledButton.icon(
                            icon: const Icon(Icons.local_offer),
                            label: Text('قبول الطلب وتقديم عرض (${order.price} ج.م)'),
                            onPressed: () {
                              setState(() {
                                order.status = 'جاري التنفيذ (بانتظار كود PIN من العميل)';
                                order.technicianName = 'م. مصطفى السيد (فني معتمد)';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('✅ تم إرسال عرض السعر وقبول المهمة! توجه للعميل واطلب كود PIN.')),
                              );
                            },
                          ),
                        if (order.status.contains('جاري التنفيذ'))
                          FilledButton.icon(
                            style: FilledButton.styleFrom(backgroundColor: Colors.green.shade700),
                            icon: const Icon(Icons.lock_open),
                            label: Text('تأكيد كود الأمان المنزلي (${order.pinCode}) وإتمام الصيانة'),
                            onPressed: () {
                              setState(() {
                                order.status = 'مكتمل ومضمون';
                                _techWallet -= (order.price * 0.15); // خصم عمولة المنصة 15%
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('🎉 تم التحقق من كود الأمان PIN وإصدار شهادة الضمان للعميل!')),
                              );
                            },
                          ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('معاينة شهادة الضمان PDF'),
                          onPressed: () => _generateWarrantyPdf(order),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // ===========================================================================
  // 3. بوابة الشركات (B2B Corporate Portal - شاشة مختلفة كلياً)
  // ===========================================================================
  Widget _buildB2BPortalHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('بوابة عقود صيانة الشركات والمؤسسات (B2B)',
                  style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('إدارة مركزية لصيانة الفروع، الصيدليات، المطاعم، العيادات، والمجمعات السكنية بفواتير ضريبية رسمية.',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 16),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.amber.shade700),
                icon: const Icon(Icons.add_business),
                label: const Text('إضافة عقد صيانة شركة / فرع جديد'),
                onPressed: () {
                  setState(() {
                    _b2bContracts.insert(0, {
                      'company': 'شركة جديدة - فرع $_selectedCity',
                      'plan': 'باقة الصيانة الوقائية الشاملة (تكييف + كهرباء + سباكة)',
                      'visitsLeft': 24,
                      'monthlyFee': 3800,
                      'status': 'ساري ومفعل فوراً',
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ تم تفعيل عقد الصيانة السنوي للشركة بنجاح!')),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('🏢 العقود السنوية النشطة للشركات والفروع:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._b2bContracts.map((c) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEDE9FE),
                  child: Icon(Icons.domain_verification, color: Color(0xFF6D28D9)),
                ),
                title: Text(c['company'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${c['plan']} • الزيارات المتبقية: ${c['visitsLeft']} زيارة'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${c['monthlyFee']} ج.م / شهرياً',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6D28D9))),
                    Text(c['status'], style: const TextStyle(color: Colors.green, fontSize: 12)),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // ===========================================================================
  // 4. بوابة إدارة KHADAMATY (Super Admin Portal - شاشة مختلفة كلياً)
  // ===========================================================================
  Widget _buildAdminPortalHome() {
    final totalRevenue = _orders.fold<int>(0, (sum, item) => sum + item.price);
    final platformCommission = (totalRevenue * 0.15).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF7F1D1D), Color(0xFFDC2626)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('🛡️ لوحة تحكم المالك والمدير العام (Super Admin)',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('مراقبة حية لكافة العمليات، أرباح المنصة، وتوثيق البطاقات الشخصية والفيش الجنائي للفنيين.',
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statBox('إجمالي المبيعات', '$totalRevenue ج.م', Colors.white),
                  _statBox('صافي عمولة المنصة (15%)', '$platformCommission ج.م', Colors.amberAccent),
                  _statBox('عقود الشركات B2B', '${_b2bContracts.length} عقود', Colors.greenAccent),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('🆔 طلبات توثيق الفنيين الجدد (مراجعة الرقم القومي والفيش الجنائي):',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._pendingTechnicians.map((tech) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: tech['approved'] ? Colors.green.shade100 : Colors.amber.shade100,
                  child: Icon(tech['approved'] ? Icons.verified : Icons.pending_actions,
                      color: tech['approved'] ? Colors.green : Colors.amber.shade900),
                ),
                title: Text('${tech['name']} - ${tech['specialty']} (${tech['city']})',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('الرقم القومي: ${tech['nationalId']} • ${tech['criminalRecord']}'),
                trailing: tech['approved']
                    ? const Chip(label: Text('معتمد وموثق ✅'), backgroundColor: Color(0xFFDCFCE7))
                    : FilledButton(
                        onPressed: () {
                          setState(() => tech['approved'] = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('✅ تم توثيق وتفعيل حساب الفني ${tech['name']} بنجاح!')),
                          );
                        },
                        child: const Text('اعتماد وتوثيق الفني'),
                      ),
              ),
            )),
      ],
    );
  }

  // ===========================================================================
  // شاشات التبويبات السفلية (الطلبات والضمان، الرسائل، المحفظة و QR)
  // ===========================================================================
  Widget _buildOrdersAndWarrantyTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('📋 سجل الطلبات وشهادات الضمان الرقمية (PDF + QR):',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ..._orders.map((order) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('طلب #${order.id} - ${order.category}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Chip(label: Text(order.status)),
                      ],
                    ),
                    Text(order.description),
                    const SizedBox(height: 8),
                    Text('🔐 كود الأمان المنزلي PIN: ${order.pinCode} • الفني: ${order.technicianName}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F766E))),
                    Text('💰 القيمة: ${order.price} ج.م • الضمان ساري حتى: ${order.warrantyEnd}'),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        FilledButton.icon(
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('تحميل شهادة الضمان PDF'),
                          onPressed: () => _generateWarrantyPdf(order),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.qr_code),
                          label: const Text('عرض رمز الضمان QR'),
                          onPressed: () => _showQrModal(
                            'شهادة ضمان رقم #${order.id}',
                            'KHADAMATY-ORDER:${order.id}-PIN:${order.pinCode}-WARRANTY:${order.warrantyEnd}',
                            'صالح حتى ${order.warrantyEnd} - الفني: ${order.technicianName}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildMessagesAndSupportTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💬 مركز الرسائل الفورية وخدمة عملاء خدماتي 24/7',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.engineering)),
              title: const Text('م. مصطفى السيد (فني معتمد)'),
              subtitle: const Text('أنا في الطريق إليك الآن، يرجى تجهيز كود الأمان المنزلي PIN.'),
              trailing: IconButton(
                icon: const Icon(Icons.phone, color: Colors.green),
                onPressed: () => launchUrl(Uri.parse('tel:01012345678')),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const CircleAvatar(backgroundColor: Colors.green, child: Icon(Icons.support_agent, color: Colors.white)),
              title: const Text('الدعم الفني الرسمي عبر واتساب'),
              subtitle: const Text('تواصل مباشر لحل أي شكوى أو تفعيل ضمان 30 يوماً'),
              trailing: FilledButton(
                onPressed: () => launchUrl(Uri.parse('https://wa.me/201000000000')),
                child: const Text('مراسلة واتساب'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletAndQrTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.account_balance_wallet, size: 54, color: Color(0xFF0F766E)),
            const SizedBox(height: 10),
            Text('رصيد محفظة العميل: ${_customerWallet.toInt()} ج.م',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('رصيد محفظة الفني: ${_techWallet.toInt()} ج.م',
                style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.add_card),
                  label: const Text('شحن رصيد العميل (+100 ج.م)'),
                  onPressed: () => setState(() => _customerWallet += 100),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('إظهار QR مشاركة التطبيق'),
                  onPressed: () => _showQrModal(
                    'مشاركة تطبيق خدماتي KHADAMATY',
                    'https://khadamaty.mahfouzalagamy.workers.dev',
                    'امسح الكود بكاميرا الموبايل لفتح التطبيق فوراً',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      selectedIndex: _bottomTab,
      onDestinationSelected: (idx) => setState(() => _bottomTab = idx),
      destinations: [
        const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
        NavigationDestination(
          icon: Badge(label: Text('${_orders.length}'), child: const Icon(Icons.verified_outlined)),
          selectedIcon: const Icon(Icons.verified),
          label: 'طلباتي والضمان',
        ),
        const NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'الرسائل والدعم'),
        const NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'محفظتي و QR'),
      ],
    );
  }
}