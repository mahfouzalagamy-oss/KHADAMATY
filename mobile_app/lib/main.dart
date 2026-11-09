import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const KhadamatyApp());
}

class ServiceOrder {
  final String id;
  final String category;
  final String description;
  final String city;
  final String customerName;
  final String pinCode;
  String status;
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
  int _bottomTab = 0;
  String _selectedCity = 'المنصورة';
  double _customerWallet = 100.0;
  double _techWallet = 420.0;
  bool _techOnline = true;

  final List<String> _cities = ['القاهرة', 'الجيزة', 'الإسكندرية', 'المنصورة', 'طنطا', 'أسيوط'];

  final List<ServiceOrder> _orders = [
    ServiceOrder(
      id: 'KH-9041',
      category: 'تكييف وتبريد',
      description: 'شحن فريون وصيانة تكييف شارب 1.5 حصان',
      city: 'المنصورة',
      customerName: 'أحمد محمود',
      pinCode: '4829',
      status: 'بانتظار عروض الفنيين',
      price: 450,
      technicianName: 'بانتظار قبول فني',
      warrantyEnd: '2026-12-10',
      isEmergency: true,
    ),
  ];

  final List> _b2bContracts = [
    {
      'company': 'مجموعة صيدليات الشفاء (12 فرع)',
      'plan': 'عقد صيانة سنوي شامل (تكييف + كهرباء)',
      'visitsLeft': 18,
      'monthlyFee': 4500,
      'status': 'ساري ومفعل',
    },
  ];

  Color get _portalPrimaryColor {
    switch (_selectedPortal) {
      case 0: return const Color(0xFF0F766E);
      case 1: return const Color(0xFF1D4ED8);
      case 2: return const Color(0xFF6D28D9);
      case 3: return const Color(0xFFB91C1C);
      default: return const Color(0xFF0F766E);
    }
  }

  void _showOrderDialog(String category, String priceRange, {bool isEmergency = false}) {
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(isEmergency ? '🚨 طوارئ عاجلة - $category' : 'طلب صيانة معتمد - $category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('مؤشر السعر العادل في $_selectedCity: $priceRange ج.م (شامل الضمان)'),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'وصف العطل باختصار', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            FilledButton(
              onPressed: () {
                final newPin = (1000 + (DateTime.now().millisecond % 8999)).toString();
                setState(() {
                  _orders.insert(0, ServiceOrder(
                    id: 'KH-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                    category: category,
                    description: descCtrl.text.isEmpty ? 'صيانة عامة' : descCtrl.text,
                    city: _selectedCity,
                    customerName: 'عميل خدماتي',
                    pinCode: newPin,
                    status: 'بانتظار عروض الفنيين',
                    price: 400,
                    technicianName: 'بانتظار قبول فني',
                    warrantyEnd: '2026-12-30',
                    isEmergency: isEmergency,
                  ));
                  _bottomTab = 1;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ تم إنشاء الطلب بنجاح! كود الأمان PIN: $newPin')),
                );
              },
              child: const Text('إرسال وتوليد PIN'),
            ),
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
                _buildPortalSelector(),
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: _buildBodyContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _bottomTab,
        onDestinationSelected: (i) => setState(() => _bottomTab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.verified), label: 'طلباتي والضمان'),
          NavigationDestination(icon: Icon(Icons.support_agent), label: 'الدعم'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'المحفظة'),
        ],
      ),
    );
  }

  Widget _buildPortalSelector() {
    final titles = ['بوابة العميل', 'بوابة الفنيين', 'بوابة الشركات B2B', 'إدارة KHADAMATY'];
    final icons = [Icons.person, Icons.handyman, Icons.business, Icons.admin_panel_settings];

    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.white,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: List.generate(4, (i) {
          final isSelected = _selectedPortal == i;
          return ChoiceChip(
            avatar: Icon(icons[i], size: 18, color: isSelected ? Colors.white : _portalPrimaryColor),
            label: Text(titles[i], style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
            selected: isSelected,
            selectedColor: _portalPrimaryColor,
            onSelected: (_) => setState(() { _selectedPortal = i; _bottomTab = 0; }),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.home_repair_service, color: _portalPrimaryColor, size: 30),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('خدماتي KHADAMATY', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  Text('المنصة الذكية المضمونة للصيانة', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          DropdownButton<String>(
            value: _selectedCity,
            items: _cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) => setState(() => _selectedCity = v!),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_bottomTab == 1) return _buildOrdersTab();
    if (_bottomTab == 2) return _buildSupportTab();
    if (_bottomTab == 3) return _buildWalletTab();

    switch (_selectedPortal) {
      case 0: return _buildCustomerHome();
      case 1: return _buildTechnicianHome();
      case 2: return _buildB2BHome();
      case 3: return _buildAdminHome();
      default: return _buildCustomerHome();
    }
  }

  Widget _buildCustomerHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: Colors.teal.shade700,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('مرحباً بك في خدماتي KHADAMATY', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('طلب فني معتمد، كود أمان منزلي PIN، وضمان ذهبي 30 يوماً.', style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 12),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.teal.shade900),
                  icon: const Icon(Icons.emergency),
                  label: const Text('طلب طوارئ عاجل خلال 45 دقيقة'),
                  onPressed: () => _showOrderDialog('طوارئ', '300 - 600', isEmergency: true),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text('الأقسام الرئيسية:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
          children: [
            _serviceCard('تكييف', Icons.ac_unit, Colors.blue, '250 - 600'),
            _serviceCard('سباكة', Icons.plumbing, Colors.teal, '150 - 400'),
            _serviceCard('كهرباء', Icons.bolt, Colors.orange, '150 - 450'),
            _serviceCard('أجهزة منزلية', Icons.local_laundry_service, Colors.indigo, '250 - 700'),
            _serviceCard('نجارة', Icons.handyman, Colors.brown, '200 - 500'),
            _serviceCard('نظافة', Icons.cleaning_services, Colors.green, '350 - 1000'),
          ],
        ),
      ],
    );
  }

  Widget _serviceCard(String name, IconData icon, Color color, String price) {
    return InkWell(
      onTap: () => _showOrderDialog(name, price),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 6),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text('$price ج.م', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicianHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: Colors.blue.shade800,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('بوابة الفنيين - رادار الطلبات', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text('رصيد المحفظة: ${_techWallet.toInt()} ج.م • عمولة المنصة: 15%', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._orders.map((o) => Card(
          child: ListTile(
            title: Text('${o.category} - ${o.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('المدينة: ${o.city} | السعر: ${o.price} ج.م | PIN: ${o.pinCode}'),
            trailing: FilledButton(
              onPressed: () {
                setState(() => o.status = 'جاري التنفيذ');
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم قبول الطلب بنجاح!')));
              },
              child: const Text('قبول'),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildB2BHome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          color: Colors.deepPurple,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('بوابة الشركات والمؤسسات B2B', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const Text('إدارة صيانة الفروع والعقود السنوية', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._b2bContracts.map((c) => Card(
          child: ListTile(
            title: Text(c['company'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${c['plan']} | الزيارات المتبقية: ${c['visitsLeft']}'),
            trailing: Text('${c['monthlyFee']} ج.م', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          ),
        )),
      ],
    );
  }

  Widget _buildAdminHome() {
    return Card(
      color: Colors.red.shade900,
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('لوحة تحكم المدير العام (Super Admin)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 6),
            Text('مراقبة الأرباح، توثيق الفنيين، وإدارة كامل المنصة.', style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('سجل الطلبات والضمان:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ..._orders.map((o) => Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${o.category} (#${o.id})', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Chip(label: Text(o.status)),
                  ],
                ),
                Text('كود الأمان المنزلي PIN: ${o.pinCode}'),
                Text('ضمان ذهبي حتى: ${o.warrantyEnd}'),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSupportTab() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مركز الدعم الفني 24/7', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('تواصل مباشر مع فريق الدعم الفني عبر الخط الساخن 19999 أو واتساب.'),
          ],
        ),
      ),
    );
  }

  Widget _buildWalletTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.account_balance_wallet, size: 40, color: Color(0xFF0F766E)),
            const SizedBox(height: 8),
            Text('رصيد محفظة العميل: ${_customerWallet.toInt()} ج.م', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => setState(() => _customerWallet += 100),
              child: const Text('شحن رصيد العميل (+100 ج.م)'),
            ),
          ],
        ),
      ),
    );
  }
}