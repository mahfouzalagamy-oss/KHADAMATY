import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/payment_sandbox_modal.dart';
import '../../shared/widgets/role_header_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateService.instance,
      builder: (context, _) {
        final state = AppStateService.instance;

        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
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
            selectedItemColor: AppColors.syaanhOrange,
            unselectedItemColor: AppColors.customerPrimary,
            type: BottomNavigationBarType.fixed,
            onTap: (i) {
              if (i == 1) Navigator.pushNamed(context, AppRoutes.createOrder);
              if (i == 2) Navigator.pushNamed(context, AppRoutes.trackOrder);
              if (i == 3) Navigator.pushNamed(context, AppRoutes.login);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
              BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'اطلب صيانة'),
              BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), label: 'عروض وطلباتي'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'حسابي'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleView(BuildContext context, AppStateService state) {
    if (state.currentRole == 1) return _buildTechnicianDashboard(context, state);
    if (state.currentRole == 2) return _buildAdminDashboard(context, state);
    return _buildSyaanhCustomerHome(context, state);
  }

  Widget _buildSyaanhCustomerHome(BuildContext context, AppStateService state) {
    final filteredServices = state.services.where((s) {
      if (_searchQuery.trim().isEmpty) return true;
      return s.name.contains(_searchQuery.trim()) || s.subtitle.contains(_searchQuery.trim());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. البنر الرئيسي على طراز موقع وتطبيق صيانة قطر (Syaanh Hero Banner)
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0C2D48), Color(0xFF145DA0)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صيانة منزلك صارت أسهل وأضمن!',
                        style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'احصل على عروض أسعار فورية من أفضل الفنيين والشركات المعتمدة مع ضمان ذهبي 100%',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.syaanhOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    icon: const Icon(Icons.flash_on),
                    label: const Text('طلب طوارئ سريع (45 دقيقة)'),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.createOrder),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // شريط البحث الفوري عن الخدمات
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'عن أي خدمة صيانة تبحث اليوم؟ (مثال: تكييف، سباكة، كهرباء، غسالات...)',
                  prefixIcon: const Icon(Icons.search, color: AppColors.syaanhOrange),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = ''))
                      : null,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              // شارات الثقة الثلاثية الخاصة بمنصة صيانة
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _trustBadge(Icons.verified_outlined, 'ضمان 100% إعادة الخدمة مجاناً'),
                  _trustBadge(Icons.request_quote_outlined, 'مقارنة عروض أسعار شفافة'),
                  _trustBadge(Icons.payments_outlined, 'الدفع بعد الإنجاز أو إلكترونياً'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 2. شريط المحفظة الذكية والدفع السريع (فودافون كاش + إنستا باي)
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.account_balance_wallet, color: AppColors.syaanhOrange),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رصيد محفظة صيانة: ${state.customerWallet.toInt()} ج.م',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.customerPrimary),
                        ),
                        const Text('اشحن رصيدك أو سدد الفواتير عبر فودافون كاش وإنستا باي', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE60000)),
                      icon: const Icon(Icons.phone_android, size: 15),
                      label: const Text('فودافون كاش (+200)'),
                      onPressed: () {
                        PaymentSandboxModal.show(
                          context,
                          title: 'شحن محفظة صيانة',
                          amount: 200,
                          initialGateway: 'vodafone',
                          onPaymentSuccess: (method, ref) {
                            state.rechargeWalletViaSandbox(200, method, ref);
                          },
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C1D95)),
                      icon: const Icon(Icons.account_balance, size: 15),
                      label: const Text('إنستا باي (+200)'),
                      onPressed: () {
                        PaymentSandboxModal.show(
                          context,
                          title: 'شحن محفظة صيانة',
                          amount: 200,
                          initialGateway: 'instapay',
                          onPaymentSuccess: (method, ref) {
                            state.rechargeWalletViaSandbox(200, method, ref);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // 3. شبكة أقسام الصيانة بأسلوب بطاقات "صيانة قطر" النظيفة
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'أقسام الصيانة والخدمات المنزلية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.customerPrimary),
            ),
            TextButton.icon(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.syaanhOrange),
              label: const Text('طلب مخصص', style: TextStyle(color: AppColors.syaanhOrange, fontWeight: FontWeight.bold)),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.createOrder),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final int cols = constraints.maxWidth > 700 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.18,
              ),
              itemCount: filteredServices.length,
              itemBuilder: (context, i) {
                final s = filteredServices[i];
                return InkWell(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.createOrder, arguments: {'service': s.name}),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.syaanhOrange.withAlpha(60)),
                          ),
                          child: Icon(s.icon, color: AppColors.syaanhOrange, size: 28),
                        ),
                        const SizedBox(height: 10),
                        Text(s.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.customerPrimary)),
                        const SizedBox(height: 3),
                        Text(
                          s.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            'يبدأ من ${s.minPrice} ج.م',
                            style: const TextStyle(fontSize: 11, color: AppColors.customerPrimary, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 20),

        // 4. باقة عقود الصيانة السنوية (ميزة تنافسية على غرار صيانة قطر)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.syaanhOrange),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium, color: AppColors.syaanhOrange, size: 36),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('باقة الصيانة السنوية الشاملة (عقد صيانة الذهبي)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.customerPrimary)),
                      Text('غسيل 4 تكييفات + فحص سباكة وكهرباء دوري + طوارئ مجانية طوال العام', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, AppRoutes.createOrder, arguments: {'service': 'تكييف وتبريد'}),
                child: const Text('اشترك بـ 1200 ج.م / سنوياً'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 5. قائمة الطلبات النشطة والمتزامنة مع Supabase
        const Text(
          'طلباتي وعروض الأسعار الجارية (تحديث حي عبر Supabase)',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.customerPrimary),
        ),
        const SizedBox(height: 10),
        ...state.orders.map((o) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.customerPrimary,
                  child: const Icon(Icons.handyman, color: Colors.white, size: 18),
                ),
                title: Text('${o.serviceName} (#${o.id}) — ${o.statusText}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${o.address} | المزود: ${o.technicianName}\nالعرض: ${o.price} ج.م (${o.isPaid ? "مدفوع ✅" : "الدفع عند الإتمام / إلكتروني"})'),
                isThreeLine: true,
                trailing: ElevatedButton(
                  onPressed: () {
                    state.activeOrderId = o.id;
                    Navigator.pushNamed(context, AppRoutes.trackOrder, arguments: {'orderId': o.id});
                  },
                  child: const Text('التفاصيل والدفع'),
                ),
              ),
            )),
      ],
    );
  }

  Widget _trustBadge(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.syaanhOrange, size: 16),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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
            color: AppColors.customerPrimary,
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
                  Text('بوابة مزودي الخدمة والفنيين (Syaanh Provider)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('استقبل طلبات العملاء، قدّم عروض الأسعار، وحدّث مراحل التنفيذ الخمس', style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppColors.syaanhOrange, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  'صافي أرباحك: ${state.technicianEarnings.toInt()} ج.م',
                  style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                        Chip(label: Text('${o.statusText} | ${o.isPaid ? "مدفوع ✅" : "بانتظار الدفع"}')),
                      ],
                    ),
                    Text('العميل: ${o.customerName} (${o.customerPhone}) | البوابة: ${o.paymentMethod}'),
                    Text('العنوان والموعد: ${o.address} | ${o.appointmentSlot}'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (o.statusIndex == 0) ...[
                          ElevatedButton.icon(
                            icon: const Icon(Icons.check),
                            label: const Text('قبول العرض والطلب'),
                            onPressed: () => state.advanceOrderStatus(o.id, targetStatus: 1),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.close),
                            label: const Text('اعتذار وتحويل لمزود آخر'),
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
                            label: const Text('إتمام العمل وتفعيل الضمان (مكتمل)'),
                            onPressed: () => state.advanceOrderStatus(o.id, targetStatus: 4),
                          ),
                        TextButton.icon(
                          icon: const Icon(Icons.chat),
                          label: const Text('مراسلة العميل والتفاصيل'),
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
            color: AppColors.customerPrimary,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 14,
            runSpacing: 10,
            children: [
              _adminMetric('إجمالي الطلبات', '${state.orders.length} طلب'),
              _adminMetric('حجم المعاملات', '$totalSales ج.م'),
              _adminMetric('عمولة المنصة (15%)', '$netRevenue ج.م'),
              _adminMetric('المزودون المعتمدون', '${state.technicians.length} شركات/فنيين'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text('إدارة وتوثيق الفنيين والشركات:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...state.technicians.map((t) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(t.isVerified ? Icons.verified_user : Icons.pending, color: t.isVerified ? AppColors.success : AppColors.syaanhOrange),
                title: Text('${t.name} - ${t.specialty} (${t.city})', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('الهاتف: ${t.phone} | التقييم: ${t.rating}★ | المهام المنجزة: ${t.completedJobs}'),
                trailing: ElevatedButton(
                  onPressed: () => state.toggleTechnicianVerification(t.id),
                  child: Text(t.isVerified ? 'معتمد ✓' : 'اعتماد المزود'),
                ),
              ),
            )),
      ],
    );
  }

  Widget _adminMetric(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: AppColors.syaanhOrange, fontSize: 19, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}