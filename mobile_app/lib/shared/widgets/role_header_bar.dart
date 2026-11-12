import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';
import 'ai_diagnosis_modal.dart';
import 'home_passport_modal.dart';
import 'spare_parts_catalog_modal.dart';

class RoleHeaderBar extends StatelessWidget {
  const RoleHeaderBar({super.key});

  void _showNotificationsModal(BuildContext context, AppStateService state) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('مركز إشعارات صيانة الفورية (Supabase Live)'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: state.notifications
                    .take(10)
                    .map((n) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.notifications_active, color: AppColors.syaanhOrange),
                          title: Text(n, style: const TextStyle(fontSize: 12)),
                        ))
                    .toList(),
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text('مزامنة الآن'),
              onPressed: () => state.syncFromSupabase(),
            ),
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
          ],
        ),
      ),
    );
  }

  void _showReviewerQuickGuide(BuildContext context, AppStateService state) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.fact_check, color: AppColors.syaanhOrange),
              SizedBox(width: 8),
              Expanded(child: Text('دليل المراجع السريع لاختبار كافة مميزات المنصة')),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('اختر أي ميزة لتجربتها مباشرة بضغطة زر واحدة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('1. تجربة التشخيص الذكي بالذكاء الاصطناعي (صوت + صورة)'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      AiSmartDiagnosisModal.show(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.customerPrimary),
                    icon: const Icon(Icons.receipt_long),
                    label: const Text('2. فتح كتالوج أسعار قطع الغيار الرسمي المعتمد'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      SparePartsCatalogModal.show(context, orderIdForQuote: state.activeOrder.id);
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.companyPrimary),
                    icon: const Icon(Icons.workspace_premium),
                    label: const Text('3. فتح جواز السفر الصياني للمنزل (Home Passport)'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      HomePassportModal.show(context);
                    },
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.adminPrimary),
                    icon: const Icon(Icons.admin_panel_settings),
                    label: const Text('4. فتح لوحة الإدارة ومراجعة هوية الفنيين وأسعار الكتالوج'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      state.setRole(3);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
          ],
        ),
      ),
    );
  }

  void _showSupabaseConfigDialog(BuildContext context, AppStateService state) {
    final urlCtrl = TextEditingController(text: state.supabaseUrl);
    final keyCtrl = TextEditingController(text: state.supabaseAnonKey);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cloud_done, color: AppColors.customerPrimary),
              SizedBox(width: 8),
              Expanded(child: Text('إعدادات الربط السحابي المباشر (Supabase)')),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.lastSyncStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: state.isCloudConnected ? AppColors.success : AppColors.syaanhOrange,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(labelText: 'Supabase Project URL', prefixIcon: Icon(Icons.link)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: keyCtrl,
                  decoration: const InputDecoration(labelText: 'Supabase anon public API Key', prefixIcon: Icon(Icons.vpn_key)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
            ElevatedButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text('اتصال ومزامنة الهواتف الآن'),
              onPressed: () async {
                await state.configureSupabaseConnection(urlCtrl.text, keyCtrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateService.instance;
    final roleSubtitles = [
      'بوابة العميل: تشخيص ذكي، كتالوج قطع غيار رسمي، أمان عائلي، و10% كاش باك',
      'بوابة الفني: استقبل الطلبات، أصدر مقايسة إلكترونية من الكتالوج، ووثّق صور العمل',
      'بوابة الشركات: إدارة أسطول الفنيين، عروض أسعار الشركات، وعقود الصيانة السنوية AMC',
      'بوابة الإدارة والمراجع: اعتماد هوية الفنيين والشركات، تحديث أسعار الكتالوج، والتقارير',
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(color: AppColors.customerPrimary),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.syaanhOrange, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.handyman, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('خدماتي • صيانة Pro', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white)),
                          SizedBox(width: 6),
                          Chip(
                            label: Text('10% كاش باك + ضمان', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                            backgroundColor: AppColors.syaanhOrange,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      Text(roleSubtitles[state.currentRole.clamp(0, 3)], style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  InkWell(
                    onTap: () => _showReviewerQuickGuide(context, state),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: AppColors.syaanhOrange, borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('دليل المراجع السريع', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _showSupabaseConfigDialog(context, state),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: state.isCloudConnected ? AppColors.success : Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(state.isCloudConnected ? Icons.cloud_done : Icons.cloud_off, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            state.isCloudConnected ? 'Supabase حي' : 'ربط السحابة',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(color: Colors.white.withAlpha(25), borderRadius: BorderRadius.circular(10)),
                    child: DropdownButton<String>(
                      value: state.selectedCity,
                      dropdownColor: AppColors.customerPrimary,
                      underline: const SizedBox(),
                      isDense: true,
                      iconEnabledColor: Colors.white,
                      items: state.egyptCities
                          .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 11, color: Colors.white))))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) state.setCity(v);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Badge(
                      backgroundColor: AppColors.syaanhOrange,
                      label: Text('${state.notifications.length}'),
                      child: const Icon(Icons.notifications_outlined, color: Colors.white),
                    ),
                    onPressed: () => _showNotificationsModal(context, state),
                  ),
                ],
              ),
            ],
          ),
        ),
        // شريط التبديل الفوري بين البوابات الأربع (العميل | الفني | الشركات | الإدارة)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _roleChip(context, 0, '1. بوابة العميل', Icons.person, AppColors.customerPrimary),
              _roleChip(context, 1, '2. بوابة الفني', Icons.handyman, AppColors.technicianPrimary),
              _roleChip(context, 2, '3. بوابة الشركات', Icons.business, AppColors.companyPrimary),
              _roleChip(context, 3, '4. صفحة الإدارة والمراجع', Icons.admin_panel_settings, AppColors.adminPrimary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _roleChip(BuildContext context, int index, String label, IconData icon, Color color) {
    final state = AppStateService.instance;
    final bool selected = state.currentRole == index;
    return InkWell(
      onTap: () {
        state.setRole(index);
        if (ModalRoute.of(context)?.settings.name != AppRoutes.home) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (r) => false);
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: selected ? Colors.white : color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(color: selected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}