import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';

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
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: state.notifications
                    .take(8)
                    .map((n) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.notifications_active, color: AppColors.syaanhOrange),
                          title: Text(n, style: const TextStyle(fontSize: 13)),
                        ))
                    .toList(),
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.sync),
              label: const Text('تحديث الآن'),
              onPressed: () => state.syncFromSupabase(),
            ),
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
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
                  decoration: const InputDecoration(
                    labelText: 'Supabase Project URL',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: keyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Supabase anon public API Key',
                    prefixIcon: Icon(Icons.vpn_key),
                  ),
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
                final ok = await state.configureSupabaseConnection(urlCtrl.text, keyCtrl.text);
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        ok
                            ? 'تم الاتصال بسحابة Supabase بنجاح! الطلبات والإشعارات متزامنة حياً.'
                            : 'تم حفظ البيانات، جاري المزامنة التلقائية.',
                      ),
                    ),
                  );
                }
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
      'اطلب خدمة صيانة، قارن عروض الأسعار، وتابع الفني بالضمان الذهبي',
      'بوابة مزود الخدمة: استقبل الطلبات، قدّم عرض سعر، وحدّث حالة العمل',
      'لوحة إدارة المنصة: اعتماد الشركات والفنيين، الأسعار، والتقارير المالية',
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // شريط صيانة العلوي الكحلي الملكي
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: AppColors.customerPrimary,
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.syaanhOrange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.handyman, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'خدماتي • صيانة',
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                          SizedBox(width: 6),
                          Chip(
                            label: Text('ضمان 100%', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                            backgroundColor: AppColors.syaanhOrange,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      Text(
                        roleSubtitles[state.currentRole],
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
                      ),
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
                    onTap: () => _showSupabaseConfigDialog(context, state),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: state.isCloudConnected ? const Color(0xFF16A34A) : AppColors.syaanhOrange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            state.isCloudConnected ? Icons.cloud_done : Icons.cloud_sync,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            state.isCloudConnected ? 'متصل بـ Supabase' : 'ربط السحابة',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButton<String>(
                      value: state.selectedCity,
                      dropdownColor: AppColors.customerPrimary,
                      underline: const SizedBox(),
                      isDense: true,
                      iconEnabledColor: Colors.white,
                      items: state.egyptCities
                          .map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(c, style: const TextStyle(fontSize: 12, color: Colors.white)),
                              ))
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
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.customerPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    icon: const Icon(Icons.person, size: 15),
                    label: Text(state.isAuthenticated ? state.currentUserName : 'دخول OTP', style: const TextStyle(fontSize: 12)),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                  ),
                ],
              ),
            ],
          ),
        ),
        // شريط تبديل الأدوار الثلاثة على طراز تبويبات صيانة
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _roleChip(context, 0, 'تطبيق العميل', Icons.person_outline, AppColors.customerPrimary),
              _roleChip(context, 1, 'تطبيق الفني / المزود', Icons.engineering_outlined, AppColors.syaanhOrange),
              _roleChip(context, 2, 'إدارة صيانة (Admin)', Icons.dashboard_customize_outlined, AppColors.adminPrimary),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : color),
            const SizedBox(width: 6),
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