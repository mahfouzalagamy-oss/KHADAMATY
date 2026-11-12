import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/role_header_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateService.instance,
      builder: (context, _) {
        final state = AppStateService.instance;
        final color = AppColors.byRole(state.currentRole);

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
                        child: _buildRoleView(context, state),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            selectedItemColor: color,
            type: BottomNavigationBarType.fixed,
            onTap: (i) {
              if (i == 1) Navigator.pushNamed(context, AppRoutes.createOrder);
              if (i == 2) Navigator.pushNamed(context, AppRoutes.trackOrder);
              if (i == 3) Navigator.pushNamed(context, AppRoutes.login);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
              BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: 'طلب خدمة'),
              BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'تتبع الطلبات'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حسابي OTP'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleView(BuildContext context, AppStateService state) {
    if (state.currentRole == 1) return _buildTechnicianDashboard(context, state);
    if (state.currentRole == 2) return _buildAdminDashboard(context, state);
    return _buildCustomerCatalogView(context, state);
  }

  Widget _buildCustomerCatalogView(BuildContext context, AppStateService state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF115E59)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('اطلب فني صيانة منزلي معتمد في مصر', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
                  Text('سباكة • كهرباء • تكييف • أجهزة منزلية — بتسعير واضح وضمان 30 يوماً', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.customerPrimary),
                icon: const Icon(Icons.add_location_alt),
                label: const Text('طلب صيانة جديد الآن'),
                onPressed: () => Navigator.pushNamed(context, AppRoutes.createOrder),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('كتالوج الخدمات والتسعير الاسترشادي (اضغط لطلب الخدمة):', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final int cols = constraints.maxWidth > 680 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              itemCount: state.services.length,
              itemBuilder: (context, i) {
                final s = state.services[i];
                return InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.createOrder, arguments: {'service': s.name}),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(backgroundColor: s.color.withAlpha(25), child: Icon(s.icon, color: s.color)),
                        const SizedBox(height: 8),
                        Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(s.priceRange, style: TextStyle(fontSize: 12, color: s.color, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 20),
        const Text('طلباتي الحالية والسابقة (متزامنة مع Supabase):', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...state.orders.map((o) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text('${o.serviceName} (#${o.id}) - ${o.statusText}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${o.address} | الموعد: ${o.appointmentSlot} | السعر: ${o.price} ج.م'),
                trailing: ElevatedButton(
                  onPressed: () {
                    state.activeOrderId = o.id;
                    Navigator.pushNamed(context, AppRoutes.trackOrder, arguments: {'orderId': o.id});
                  },
                  child: const Text('تتبع الحالة'),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildTechnicianDashboard(BuildContext context, AppStateService state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 10,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('بوابة الفني المعتمد - استقبال وإدارة المهام', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('استقبل الطلبات القريبة، اقبل أو ارفض، وحدّث حالة العمل خطوة بخطوة', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  'صافي أرباحك (بعد عمولة 15%): ${state.technicianEarnings.toInt()} ج.م',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.technicianPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('الطلبات الواردة للفني (تحديث: جديد ← مقبول ← في الطريق ← قيد التنفيذ ← مكتمل):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...state.orders.map((o) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      spacing: 10,
                      children: [
                        Text('طلب #${o.id} - ${o.serviceName} (${o.price} ج.م)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Chip(label: Text('الحالة الحالية: ${o.statusText}')),
                      ],
                    ),
                    Text('العميل: ${o.customerName} (${o.customerPhone}) | الدفع: ${o.paymentMethod}'),
                    Text('العنوان والموعد: ${o.address} | ${o.appointmentSlot}'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (o.statusIndex == 0) ...[
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            label: const Text('قبول الطلب (تحويل إلى مقبول)'),
                            onPressed: () => state.advanceOrderStatus(o.id, targetStatus: 1),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.close),
                            label: const Text('رفض وتحويل لفني آخر'),
                            onPressed: () => state.rejectOrderByTechnician(o.id),
                          ),
                        ],
                        if (o.statusIndex == 1)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.directions_car),
                            label: const Text('بدء التحرك (في الطريق)'),
                            onPressed: () => state.advanceOrderStatus(o.id, targetStatus: 2),
                          ),
                        if (o.statusIndex == 2)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.build),
                            label: const Text('بدء العمل (قيد التنفيذ)'),
                            onPressed: () => state.advanceOrderStatus(o.id, targetStatus: 3),
                          ),
                        if (o.statusIndex == 3)
                          ElevatedButton.icon(
                            icon: const Icon(Icons.verified),
                            label: const Text('إتمام العمل وتحصيل الفاتورة (مكتمل)'),
                            onPressed: () => state.advanceOrderStatus(o.id, targetStatus: 4),
                          ),
                        TextButton.icon(
                          icon: const Icon(Icons.chat),
                          label: const Text('فتح شاشة التتبع والدردشة'),
                          onPressed: () => Navigator.pushNamed(context, AppRoutes.trackOrder, arguments: {'orderId': o.id}),
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

  Widget _buildAdminDashboard(BuildContext context, AppStateService state) {
    final int totalSales = state.orders.fold<int>(0, (sum, o) => sum + o.price);
    final int netRevenue = (totalSales * 0.15).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF7F1D1D), Color(0xFFDC2626)]),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 14,
            runSpacing: 10,
            children: [
              _adminMetric('إجمالي الطلبات', '${state.orders.length} طلب'),
              _adminMetric('إجمالي المعاملات', '$totalSales ج.م'),
              _adminMetric('عمولة المنصة (15%)', '$netRevenue ج.م'),
              _adminMetric('الفنيين المسجلين', '${state.technicians.length} فنيين'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('إدارة وتوثيق الفنيين:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...state.technicians.map((t) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(t.isVerified ? Icons.verified_user : Icons.pending, color: t.isVerified ? AppColors.success : AppColors.accentAmber),
                title: Text('${t.name} - ${t.specialty} (${t.city})', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('الهاتف: ${t.phone} | التقييم: ${t.rating}★ | العمليات: ${t.completedJobs}'),
                trailing: ElevatedButton(
                  onPressed: () => state.toggleTechnicianVerification(t.id),
                  child: Text(t.isVerified ? 'معتمد (إيقاف مؤقت)' : 'توثيق واعتماد الفني'),
                ),
              ),
            )),
        const SizedBox(height: 16),
        const Text('إدارة كتالوج الخدمات وتحديث الأسعار:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...state.services.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(s.icon, color: s.color),
                title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('السعر الحالي: ${s.priceRange}'),
                trailing: OutlinedButton.icon(
                  icon: const Icon(Icons.edit, size: 15),
                  label: const Text('زيادة السعر +25 ج.م'),
                  onPressed: () => state.updateServicePrice(s.id, s.minPrice + 25, s.maxPrice + 25),
                ),
              ),
            )),
      ],
    );
  }

  Widget _adminMetric(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}