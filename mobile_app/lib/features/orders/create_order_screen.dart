import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/payment_sandbox_modal.dart';
import '../../shared/widgets/role_header_bar.dart';

class CreateOrderScreen extends StatefulWidget {
  final String? initialServiceName;
  const CreateOrderScreen({super.key, this.initialServiceName});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  late String _selectedService;
  final _descCtrl = TextEditingController();
  final _zoneCtrl = TextEditingController(text: 'المنطقة 45 / مدينة نصر');
  final _streetCtrl = TextEditingController(text: 'شارع عباس العقاد الرئيسي');
  final _buildingCtrl = TextEditingController(text: 'مبنى 18 - الدور 3');
  final _priceCtrl = TextEditingController(text: '250');

  final List<String> _photos = ['صورة_موقع_العطل.jpg'];
  String _mapCoordinates = 'تم التحديد الدقيق عبر خرائط GPS';
  String _appointmentSlot = 'طوارئ فورية (وصول خلال 45 دقيقة)';
  String _assignmentMode = 'استلام ومقارنة عروض أسعار (نظام صيانة)';
  String? _selectedTechId;
  String _paymentMethod = 'فودافون كاش (Vodafone Cash)';

  final List<String> _timeSlots = const [
    'طوارئ فورية (وصول خلال 45 دقيقة)',
    'اليوم - الفترة المسائية (04:00 م - 07:00 م)',
    'غداً - الفترة الصباحية (10:00 ص - 01:00 م)',
    'غداً - الفترة المسائية (05:00 م - 08:00 م)',
  ];

  @override
  void initState() {
    super.initState();
    final services = AppStateService.instance.services;
    _selectedService = widget.initialServiceName ?? services.first.name;
    final found = services.where((s) => s.name == _selectedService).toList();
    if (found.isNotEmpty) {
      _priceCtrl.text = found.first.minPrice.toString();
    }
  }

  String get _fullAddress => '${_zoneCtrl.text.trim()} - ${_streetCtrl.text.trim()} - ${_buildingCtrl.text.trim()}';

  void _finalizeOrder({bool isPaid = false, String? paymentRef, String? customMethod}) {
    final state = AppStateService.instance;
    final order = state.createOrder(
      serviceName: _selectedService,
      description: _descCtrl.text,
      photos: List<String>.from(_photos),
      address: _fullAddress,
      mapCoords: _mapCoordinates,
      appointmentSlot: _appointmentSlot,
      assignmentMode: _assignmentMode,
      paymentMethod: customMethod ?? _paymentMethod,
      price: int.tryParse(_priceCtrl.text.trim()) ?? 250,
      manualTechId: _selectedTechId,
      isPaidInitially: isPaid,
      paymentRef: paymentRef,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.customerPrimary,
        content: Text(
          isPaid
              ? 'تم السداد وتأكيد الطلب #${order.id} بالضمان الذهبي (مرجع: $paymentRef)'
              : 'تم إرسال الطلب #${order.id} وتعيين المزود ${order.technicianName}',
        ),
      ),
    );
    Navigator.pushReplacementNamed(context, AppRoutes.trackOrder, arguments: {'orderId': order.id});
  }

  void _handleCreateOrderPressed() {
    final int price = int.tryParse(_priceCtrl.text.trim()) ?? 250;
    if (_paymentMethod.contains('فودافون') || _paymentMethod.contains('إنستا')) {
      final gw = _paymentMethod.contains('إنستا') ? 'instapay' : 'vodafone';
      PaymentSandboxModal.show(
        context,
        title: 'سداد طلب صيانة ($_selectedService)',
        amount: price,
        initialGateway: gw,
        onPaymentSuccess: (methodLabel, refCode) {
          _finalizeOrder(isPaid: true, paymentRef: refCode, customMethod: '$methodLabel [$refCode]');
        },
      );
    } else {
      _finalizeOrder(isPaid: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateService.instance;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 940),
            child: Column(
              children: [
                const RoleHeaderBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('طلب خدمة صيانة جديدة', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.customerPrimary)),
                                      Text('مشابه لنظام صيانة قطر: حدد العطل، قارن عروض المزودين، واحصل على ضمان 30 يوماً', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.arrow_back, size: 16),
                                  label: const Text('رجوع'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            const Text('1. اختر قسم الصيانة:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.customerPrimary)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: state.services.map((s) {
                                final selected = s.name == _selectedService;
                                return ChoiceChip(
                                  avatar: Icon(s.icon, size: 16, color: selected ? Colors.white : AppColors.syaanhOrange),
                                  label: Text('${s.name} (${s.priceRange})', style: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                  selected: selected,
                                  selectedColor: AppColors.customerPrimary,
                                  onSelected: (_) {
                                    setState(() {
                                      _selectedService = s.name;
                                      _priceCtrl.text = s.minPrice.toString();
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _descCtrl,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: '2. اشرح العطل أو الخدمة المطلوبة بالتفصيل',
                                prefixIcon: Icon(Icons.build_circle_outlined, color: AppColors.syaanhOrange),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text('3. صور العطل (اختياري لمساعدة الفني في التسعير الدقيق):', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.customerPrimary)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ..._photos.map((p) => Chip(
                                      avatar: const Icon(Icons.camera_alt, size: 16, color: AppColors.syaanhOrange),
                                      label: Text(p),
                                      onDeleted: () => setState(() => _photos.remove(p)),
                                    )),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.add_a_photo, size: 16),
                                  label: const Text('إرفاق صورة جديدة'),
                                  onPressed: () => setState(() => _photos.add('صورة_عطل_${_photos.length + 1}.jpg')),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('4. بيانات الموقع والعنوان الذكي (المنطقة / الشارع / المبنى):', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.customerPrimary)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                SizedBox(
                                  width: 260,
                                  child: TextField(
                                    controller: _zoneCtrl,
                                    decoration: const InputDecoration(labelText: 'المنطقة / الحي', prefixIcon: Icon(Icons.map)),
                                  ),
                                ),
                                SizedBox(
                                  width: 280,
                                  child: TextField(
                                    controller: _streetCtrl,
                                    decoration: const InputDecoration(labelText: 'اسم أو رقم الشارع', prefixIcon: Icon(Icons.signpost)),
                                  ),
                                ),
                                SizedBox(
                                  width: 260,
                                  child: TextField(
                                    controller: _buildingCtrl,
                                    decoration: const InputDecoration(labelText: 'رقم المبنى / الفيلا / الشقة', prefixIcon: Icon(Icons.home_work)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text('5. نظام اختيار الفني وعروض الأسعار (ميزة صيانة قطر):', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.customerPrimary)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              runSpacing: 8,
                              children: [
                                'استلام ومقارنة عروض أسعار (نظام صيانة)',
                                'تعيين تلقائي لأقرب فني متاح فوراً',
                              ].map((m) {
                                final sel = _assignmentMode == m;
                                return ChoiceChip(
                                  label: Text(m, style: TextStyle(color: sel ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                  selected: sel,
                                  selectedColor: AppColors.syaanhOrange,
                                  onSelected: (_) => setState(() => _assignmentMode = m),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 10),
                            // بطاقات عروض أسعار المزودين المباشرة
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('عروض المزودين المعتمدين المتاحين الآن في منطقتك:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  ...state.technicians.map((t) {
                                    final isChosen = _selectedTechId == t.id;
                                    final int quotePrice = (int.tryParse(_priceCtrl.text) ?? 250) + (t.id == 'TECH-1' ? 0 : 35);
                                    return Card(
                                      elevation: 0,
                                      color: isChosen ? const Color(0xFFFFF7ED) : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(color: isChosen ? AppColors.syaanhOrange : AppColors.border, width: isChosen ? 1.8 : 1),
                                      ),
                                      child: ListTile(
                                        onTap: () => setState(() {
                                          _selectedTechId = t.id;
                                          _priceCtrl.text = quotePrice.toString();
                                        }),
                                        leading: CircleAvatar(
                                          backgroundColor: AppColors.customerPrimary,
                                          child: const Icon(Icons.verified_user, color: Colors.white, size: 18),
                                        ),
                                        title: Text('${t.name} • ضمان 30 يوماً', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                        subtitle: Text('التقييم: ${t.rating}★ (${t.completedJobs} مهمة) | يبعد ${t.distanceKm} كم'),
                                        trailing: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text('$quotePrice ج.م', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.syaanhOrange, fontSize: 14)),
                                            Text(isChosen ? 'تم الاختيار ✓' : 'اختر العرض', style: const TextStyle(fontSize: 11)),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text('6. موعد الزيارة المفضل:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.customerPrimary)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _timeSlots.map((slot) {
                                final selected = _appointmentSlot == slot;
                                return ChoiceChip(
                                  label: Text(slot, style: const TextStyle(fontSize: 12)),
                                  selected: selected,
                                  onSelected: (_) => setState(() => _appointmentSlot = slot),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _priceCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'قيمة العرض المعتمد (ج.م)', prefixIcon: Icon(Icons.payments)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _paymentMethod,
                                    decoration: const InputDecoration(labelText: 'وسيلة الدفع المعتمدة'),
                                    items: [
                                      'فودافون كاش (Vodafone Cash)',
                                      'إنستا باي (InstaPay)',
                                      'الدفع بعد إتمام العمل (كاش)',
                                    ].map((p) {
                                      return DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)));
                                    }).toList(),
                                    onChanged: (v) {
                                      if (v != null) setState(() => _paymentMethod = v);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.bolt),
                              label: Text(
                                _paymentMethod.contains('كاش عند') || _paymentMethod.contains('بعد إتمام')
                                    ? 'اعتماد الطلب وإشعار الفني فوراً'
                                    : 'الدفع الإلكتروني الآمن ($_paymentMethod) وتأكيد الطلب',
                              ),
                              onPressed: _handleCreateOrderPressed,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}