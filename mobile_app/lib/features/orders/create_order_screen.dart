import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/ai_diagnosis_modal.dart';
import '../../shared/widgets/payment_sandbox_modal.dart';
import '../../shared/widgets/role_header_bar.dart';
import '../../shared/widgets/spare_parts_catalog_modal.dart';

class CreateOrderScreen extends StatefulWidget {
  final String? initialServiceName;
  const CreateOrderScreen({super.key, this.initialServiceName});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  late String _selectedService;
  final _descCtrl = TextEditingController();
  final _zoneCtrl = TextEditingController(text: 'مدينة نصر / المنطقة 45');
  final _streetCtrl = TextEditingController(text: 'شارع عباس العقاد الرئيسي');
  final _buildingCtrl = TextEditingController(text: 'مبنى 18 - الدور 3');
  final _priceCtrl = TextEditingController(text: '250');

  final List<String> _photos = ['قبل_صورة_موقع_العطل.jpg'];
  String _mapCoordinates = 'تم التحديد الدقيق عبر خرائط GPS';
  String _appointmentSlot = 'طوارئ فورية SOS (وصول خلال 45 دقيقة)';
  String _assignmentMode = 'استلام ومقارنة عروض أسعار (نظام صيانة)';
  String? _selectedTechId;
  String _paymentMethod = 'فودافون كاش (Vodafone Cash)';

  final List<String> _timeSlots = const [
    'طوارئ فورية SOS (وصول خلال 45 دقيقة)',
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.spaceBetween,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('إنشاء طلب صيانة مضمون (معاينة 50 ج.م تُخصم عند الإصلاح)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.customerPrimary)),
                                    Text('استخدم التشخيص الذكي بالذكاء الاصطناعي أو راجع كتالوج أسعار قطع الغيار الرسمي قبل التأكيد', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                  ],
                                ),
                                Wrap(
                                  spacing: 6,
                                  children: [
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.customerPrimary),
                                      icon: const Icon(Icons.auto_awesome, size: 15),
                                      label: const Text('تشخيص ذكي AI'),
                                      onPressed: () => AiSmartDiagnosisModal.show(context),
                                    ),
                                    OutlinedButton.icon(
                                      icon: const Icon(Icons.receipt_long, size: 15),
                                      label: const Text('كتالوج أسعار القطع'),
                                      onPressed: () => SparePartsCatalogModal.show(context),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            const Text('1. اختر قسم الصيانة:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            const SizedBox(height: 14),
                            TextField(
                              controller: _descCtrl,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: '2. وصف العطل بالتفصيل',
                                prefixIcon: Icon(Icons.build_circle_outlined, color: AppColors.syaanhOrange),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                SizedBox(
                                  width: 260,
                                  child: TextField(controller: _zoneCtrl, decoration: const InputDecoration(labelText: 'المنطقة / الحي', prefixIcon: Icon(Icons.location_on))),
                                ),
                                SizedBox(
                                  width: 280,
                                  child: TextField(controller: _streetCtrl, decoration: const InputDecoration(labelText: 'الشارع الرئيسي', prefixIcon: Icon(Icons.directions_car))),
                                ),
                                SizedBox(
                                  width: 260,
                                  child: TextField(controller: _buildingCtrl, decoration: const InputDecoration(labelText: 'رقم المبنى / الدور / الشقة', prefixIcon: Icon(Icons.home))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Text('3. عروض الأسعار الفورية من الفنيين والشركات الموثقة:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...state.technicians.where((t) => t.isVerified).map((t) {
                              final isChosen = _selectedTechId == t.id;
                              final int quotePrice = (int.tryParse(_priceCtrl.text) ?? 250) + (t.id == 'TECH-1' ? 0 : 30);
                              return Card(
                                elevation: 0,
                                color: isChosen ? const Color(0xFFFFF7ED) : Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: isChosen ? AppColors.syaanhOrange : AppColors.border),
                                ),
                                child: ListTile(
                                  onTap: () => setState(() {
                                    _selectedTechId = t.id;
                                    _priceCtrl.text = quotePrice.toString();
                                  }),
                                  leading: const CircleAvatar(
                                    backgroundColor: AppColors.customerPrimary,
                                    child: Icon(Icons.verified_user, color: Colors.white, size: 18),
                                  ),
                                  title: Text('${t.name} (${t.companyAffiliation})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  subtitle: Text('التقييم: ${t.rating}★ | يبعد ${t.distanceKm} كم | معاينة 50 ج.م تُخصم عند الإصلاح'),
                                  trailing: Text('$quotePrice ج.م', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.syaanhOrange, fontSize: 15)),
                                ),
                              );
                            }),
                            const SizedBox(height: 12),
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
                                    decoration: const InputDecoration(labelText: 'قيمة العرض (ج.م)', prefixIcon: Icon(Icons.payments)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _paymentMethod,
                                    decoration: const InputDecoration(labelText: 'وسيلة الدفع (+10% كاش باك للإلكتروني)'),
                                    items: [
                                      'فودافون كاش (Vodafone Cash)',
                                      'إنستا باي (InstaPay)',
                                      'الدفع بعد إتمام العمل (كاش)',
                                    ].map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 12)))).toList(),
                                    onChanged: (v) {
                                      if (v != null) setState(() => _paymentMethod = v);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.bolt),
                              label: const Text('اعتماد الطلب وتفعيل درع الأمان العائلي والضمان الذهبي'),
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