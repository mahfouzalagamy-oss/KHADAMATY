import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';
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
  final _addressCtrl = TextEditingController(text: 'مدينة نصر - شارع عباس العقاد - عمارة 18');
  final _priceCtrl = TextEditingController(text: '250');

  final List<String> _photos = ['صورة_موقع_العطل.jpg'];
  String _mapCoordinates = '30.0444° N, 31.2357° E (تم تحديد الدبوس على خريطة Google Maps)';
  String _appointmentSlot = 'اليوم - الفترة المسائية (04:00 م - 07:00 م)';
  String _assignmentMode = 'تلقائي حسب الأقرب جغرافياً';
  String? _selectedTechId;
  String _paymentMethod = 'كاش عند الإتمام';

  final List<String> _timeSlots = const [
    'اليوم - طوارئ فورية (خلال 45 دقيقة)',
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

  void _submitOrder() {
    final state = AppStateService.instance;
    final order = state.createOrder(
      serviceName: _selectedService,
      description: _descCtrl.text,
      photos: List<String>.from(_photos),
      address: _addressCtrl.text,
      mapCoords: _mapCoordinates,
      appointmentSlot: _appointmentSlot,
      assignmentMode: _assignmentMode,
      paymentMethod: _paymentMethod,
      price: int.tryParse(_priceCtrl.text.trim()) ?? 250,
      manualTechId: _assignmentMode == 'اختيار فني يدوي' ? _selectedTechId : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم إنشاء الطلب #${order.id} وتعيين الفني ${order.technicianName}')),
    );
    Navigator.pushReplacementNamed(context, AppRoutes.trackOrder, arguments: {'orderId': order.id});
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateService.instance;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              children: [
                const RoleHeaderBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text('إنشاء طلب صيانة جديد (وصف + صور + خريطة + موعد)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.arrow_back),
                                  label: const Text('رجوع'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            const Divider(height: 22),
                            const Text('1. اختر الخدمة من الكتالوج:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: state.services.map((s) {
                                final selected = s.name == _selectedService;
                                return ChoiceChip(
                                  avatar: Icon(s.icon, size: 16, color: selected ? Colors.white : s.color),
                                  label: Text('${s.name} (${s.priceRange})', style: TextStyle(color: selected ? Colors.white : AppColors.textPrimary)),
                                  selected: selected,
                                  selectedColor: s.color,
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
                                labelText: '2. وصف المشكلة أو العطل بالتفصيل',
                                prefixIcon: Icon(Icons.description),
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text('3. إرفاق صور العطل (لمساعدة الفني في إحضار قطع الغيار):', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ..._photos.map((p) => Chip(
                                      avatar: const Icon(Icons.image, size: 16, color: AppColors.customerPrimary),
                                      label: Text(p),
                                      onDeleted: () => setState(() => _photos.remove(p)),
                                    )),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.add_a_photo, size: 16),
                                  label: const Text('إضافة صورة للعطل'),
                                  onPressed: () {
                                    setState(() => _photos.add('صورة_إضافية_${_photos.length + 1}.jpg'));
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            const Text('4. الموقع على الخريطة (Google Maps Egypt) والعنوان:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.customerPrimary),
                              ),
                              child: Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 10,
                                runSpacing: 8,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.location_on, color: AppColors.danger),
                                      const SizedBox(width: 6),
                                      Text(_mapCoordinates, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.my_location, size: 15),
                                    label: const Text('تحديث إحداثيات GPS الحالية'),
                                    onPressed: () {
                                      setState(() {
                                        _mapCoordinates = '30.0595° N, 31.2230° E (${state.selectedCity} - موقع دقيق GPS)';
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _addressCtrl,
                              decoration: const InputDecoration(labelText: 'العنوان التفصيلي (الشارع / العمارة / الدور / الشقة)', prefixIcon: Icon(Icons.home)),
                            ),
                            const SizedBox(height: 14),
                            const Text('5. تحديد موعد الزيارة المناسب:', style: TextStyle(fontWeight: FontWeight.bold)),
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
                            const SizedBox(height: 14),
                            const Text('6. طريقة تعيين الفني:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              children: ['تلقائي حسب الأقرب جغرافياً', 'اختيار فني يدوي'].map((m) {
                                return ChoiceChip(
                                  label: Text(m),
                                  selected: _assignmentMode == m,
                                  onSelected: (_) => setState(() => _assignmentMode = m),
                                );
                              }).toList(),
                            ),
                            if (_assignmentMode == 'اختيار فني يدوي') ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: state.technicians.map((t) {
                                  return ChoiceChip(
                                    label: Text('${t.name} (${t.rating}★ - ${t.distanceKm} كم)'),
                                    selected: _selectedTechId == t.id,
                                    onSelected: (_) => setState(() => _selectedTechId = t.id),
                                  );
                                }).toList(),
                              ),
                            ],
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _priceCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'السعر التقديري (ج.م)', prefixIcon: Icon(Icons.payments)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _paymentMethod,
                                    decoration: const InputDecoration(labelText: 'وسيلة الدفع (مصر)'),
                                    items: ['كاش عند الإتمام', 'بطاقة بنكية (Paymob)', 'فوري (Fawry)'].map((p) {
                                      return DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13)));
                                    }).toList(),
                                    onChanged: (v) {
                                      if (v != null) setState(() => _paymentMethod = v);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check_circle),
                              label: const Text('تأكيد الطلب وإشعار الفني فوراً'),
                              onPressed: _submitOrder,
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