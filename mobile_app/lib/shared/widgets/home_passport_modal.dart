import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';
import '../models/app_models.dart';

class HomePassportModal extends StatefulWidget {
  const HomePassportModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const Directionality(
        textDirection: TextDirection.rtl,
        child: HomePassportModal(),
      ),
    );
  }

  static void showEncryptedCallDialog(BuildContext context, OrderItemModel order) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.customerPrimary,
          title: const Row(
            children: [
              Icon(Icons.lock, color: AppColors.syaanhOrange),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'مكالمة صوتية مشفرة داخل التطبيق (VoIP Bridge)',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.syaanhOrange,
                child: Icon(Icons.phone_in_talk, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 12),
              Text(
                order.technicianName,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withAlpha(25), borderRadius: BorderRadius.circular(20)),
                child: const Text(
                  'الرقم محجوب للخصوصية: +20-10-XXXX-XXXX 🔒',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'يتم الاتصال عبر مقسم المنصة المشفر لحماية خصوصية رقم العميل ومنع الاتفاق الجانبي خارج ضمان التطبيق.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              icon: const Icon(Icons.call_end),
              label: const Text('إنهاء المكالمة المشفرة'),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  static void showFamilySafeModeDialog(BuildContext context, OrderItemModel order) {
    final state = AppStateService.instance;
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.shield, color: AppColors.success, size: 28),
              SizedBox(width: 8),
              Expanded(child: Text('درع الأمان العائلي وتتبع الزيارة الحي (Family Safe Mode)')),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الفني المعتمد بالمنزل: ${order.technicianName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Text('حالة التحقق الجنائي والهوية: موثق بالبطاقة الشخصية والفيش لدى الإدارة ✅', style: TextStyle(fontSize: 12, color: AppColors.success)),
                      Text('كود الأمان المطابق عند الباب (PIN): ${order.pinCode}', style: const TextStyle(fontWeight: FontWeight.w900)),
                      Text('إحداثيات GPS الحية: ${order.mapCoordinates}', style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text('رابط المشاركة العائلية لرب الأسرة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                SelectableText(
                  order.familyTrackingLink,
                  style: const TextStyle(fontSize: 12, color: AppColors.technicianPrimary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton.icon(
              icon: const Icon(Icons.copy, size: 15),
              label: const Text('نسخ رابط التتبع لرب الأسرة'),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: order.familyTrackingLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ رابط الأمان العائلي لإرساله عبر واتساب لرب الأسرة')),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                state.toggleFamilySafeMode(order.id);
                Navigator.pop(ctx);
              },
              child: Text(order.isFamilySafeModeActive ? 'تحديث البث الحي' : 'تفعيل الأمان العائلي الآن'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<HomePassportModal> createState() => _HomePassportModalState();
}

class _HomePassportModalState extends State<HomePassportModal> {
  final _nameCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _roomCtrl = TextEditingController(text: 'غرفة النوم الرئيسية');

  @override
  Widget build(BuildContext context) {
    final state = AppStateService.instance;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.customerPrimary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Row(
          children: [
            Icon(Icons.workspace_premium, color: AppColors.syaanhOrange, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('جواز السفر الصياني للمنزل (Home Maintenance Passport)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                  Text('سجل رقمي لكافة أجهزة منزلك وتاريخ صيانتها وتذكيرات الفحص الموسمي', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...state.homeAppliances.map((app) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFFF0FDF4),
                        child: Text('${app.healthScore}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.success)),
                      ),
                      title: Text('${app.name} (${app.brand})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('المكان: ${app.locationRoom} | آخر صيانة: ${app.lastMaintenanceDate}\nالتذكير القادم: ${app.nextReminderDate} • ${app.warrantyStatus}', style: const TextStyle(fontSize: 11)),
                      isThreeLine: true,
                    ),
                  )),
              const Divider(height: 22),
              const Text('إضافة جهاز منزلي جديد للجواز الصياني:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  SizedBox(
                    width: 170,
                    child: TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'اسم الجهاز (مثال: تكييف)')),
                  ),
                  SizedBox(
                    width: 150,
                    child: TextField(controller: _brandCtrl, decoration: const InputDecoration(labelText: 'الماركة (مثال: كاريير)')),
                  ),
                  SizedBox(
                    width: 160,
                    child: TextField(controller: _roomCtrl, decoration: const InputDecoration(labelText: 'الغرفة / الموقع')),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_circle),
                label: const Text('تسجيل الجهاز وتفعيل التذكير الموسمي'),
                onPressed: () {
                  if (_nameCtrl.text.trim().isNotEmpty) {
                    setState(() {
                      state.addHomeApplianceToPassport(
                        name: _nameCtrl.text.trim(),
                        brand: _brandCtrl.text.trim().isEmpty ? 'معتمد' : _brandCtrl.text.trim(),
                        room: _roomCtrl.text.trim(),
                      );
                      _nameCtrl.clear();
                      _brandCtrl.clear();
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إغلاق')),
      ],
    );
  }
}