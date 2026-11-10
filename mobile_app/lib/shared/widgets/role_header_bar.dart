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
          title: const Text('مركز الإشعارات الفورية'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: state.notifications
                  .take(5)
                  .map((n) => ListTile(
                        dense: true,
                        leading: const Icon(Icons.notifications_active, color: AppColors.customerPrimary),
                        title: Text(n, style: const TextStyle(fontSize: 13)),
                      ))
                  .toList(),
            ),
          ),
          actions: [
            ElevatedButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateService.instance;
    final Color primary = AppColors.byRole(state.currentRole);
    final roleSubtitles = [
      'بوابة العميل: اطلب فني، حدد موقعك وموعدك، وتابع حالة الطلب',
      'بوابة الفني: استقبل الطلبات، اقبل أو ارفض، وحدّث حالة العمل وأرباحك',
      'لوحة تحكم الأدمن: إدارة الفنيين، الخدمات، الأسعار، الطلبات، والتقارير',
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
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
              _roleChip(context, 0, 'دور العميل', Icons.person, AppColors.customerPrimary),
              _roleChip(context, 1, 'دور الفني', Icons.handyman, AppColors.technicianPrimary),
              _roleChip(context, 2, 'لوحة الأدمن', Icons.admin_panel_settings, AppColors.adminPrimary),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: AppColors.border)),
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
                    decoration: BoxDecoration(color: primary.withAlpha(25), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.home_repair_service, color: primary, size: 24),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('خدماتي KHADAMATY مصر', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                      Text(roleSubtitles[state.currentRole], style: TextStyle(fontSize: 11, color: primary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(10)),
                    child: DropdownButton<String>(
                      value: state.selectedCity,
                      underline: const SizedBox(),
                      isDense: true,
                      items: state.egyptCities.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (v) {
                        if (v != null) state.setCity(v);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Badge(label: Text('${state.notifications.length}'), child: const Icon(Icons.notifications_outlined)),
                    onPressed: () => _showNotificationsModal(context, state),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.phone_android, size: 15),
                    label: Text(state.isAuthenticated ? state.currentUserName : 'دخول OTP'),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
                  ),
                ],
              ),
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : AppColors.border),
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