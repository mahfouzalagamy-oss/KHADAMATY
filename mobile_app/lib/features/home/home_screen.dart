import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';
import '../../shared/models/app_models.dart';
import '../../shared/widgets/payment_sandbox_modal.dart';
import '../../shared/widgets/role_header_bar.dart';
import '../../shared/widgets/warranty_certificate_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  void _showKycInspectionDialog(BuildContext context, AppStateService state, TechnicianItemModel tech) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.badge, color: AppColors.customerPrimary, size: 28),
              const SizedBox(width: 8),
              Expanded(child: Text('مراجعة هوية ووثائق الفني: ${tech.name}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الاسم الكامل: ${tech.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('التخصص والمدينة: ${tech.specialty} • ${tech.city}'),
                        Text('رقم الجوال: ${tech.phone} | محفظة التحويل: ${tech.walletNumber}'),
                        Text('سنوات الخبرة المسجلة: ${tech.experienceYears} سنوات'),
                        const Divider(),
                        Text('رقم البطاقة / الهوية الوطنية: ${tech.nationalId}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.customerPrimary)),
                        Text('حالة الاعتماد الحالية: ${tech.approvalStatusArabic}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.syaanhOrange)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('المستندات والصور المرفوعة من الفني للمطابقة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  _docPreviewTile(Icons.credit_card, 'صورة الهوية (الوجه الأمامي)', tech.idFrontPhoto),
                  const SizedBox(height: 6),
                  _docPreviewTile(Icons.credit_card_outlined, 'صورة الهوية (الوجه الخلفي)', tech.idBackPhoto),
                  const SizedBox(height: 6),
                  _docPreviewTile(Icons.workspace_premium, 'شهادة الخبرة والفيش الجنائي', tech.certificatePhoto),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('رفض الطلب'),
              onPressed: () {
                state.reviewTechnicianApplication(tech.id, approve: false);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: AppColors.danger, content: Text('تم رفض طلب تسجيل الفني ${tech.name}')),
                );
              },
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              icon: const Icon(Icons.check_circle, size: 16),
              label: const Text('موافقة وتوثيق الفني رسمياً'),
              onPressed: () {
                state.reviewTechnicianApplication(tech.id, approve: true);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(backgroundColor: AppColors.success, content: Text('تم اعتماد وتوثيق هوية الفني ${tech.name} بنجاح!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _docPreviewTile(IconData icon, String label, String fileName) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.success.withAlpha(90)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.customerPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                Text('الملف المرفق: $fileName (واضح ومطابق ✓)', style: const TextStyle(fontSize: 11, color: AppColors.success)),
              ],
            ),
          ),
          const Icon(Icons.visibility, size: 18, color: AppColors.customerPrimary),
        ],
      ),
    );
  }

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
              if (i == 3) Navigator.pushNamed(context, AppRoutes.registerTech);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'الرئيسية'),
              BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'اطلب صيانة'),
              BottomNavigationBarItem(icon: Icon(Icons.fact_check_outlined), label: 'عروض وطلباتي'),
              BottomNavigationBarItem(icon: Icon(Icons.badge_outlined), label: 'تسجيل فني بالهوية'),
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
                        'فنيون موثقون بالبطاقة الشخصية لدى الإدارة • عروض أسعار فورية • شهادة ضمان PDF لمدة 30 يوماً',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.syaanhOrange),
                        icon: const Icon(Icons.flash_on),
                        label: const Text('طلب صيانة الآن'),
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.createOrder),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white70)),
                        icon: const Icon(Icons.badge, size: 16),
                        label: const Text('سجّل كفني معتمد'),
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.registerTech),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
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
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _trustBadge(Icons.verified_user_outlined, 'فنيون موثقو الهوية والفيش'),
                  _trustBadge(Icons.camera_alt_outlined, 'توثيق صور قبل وبعد الصيانة'),
                  _trustBadge(Icons.picture_as_pdf_outlined, 'شهادة ضمان رقمية PDF 100%'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
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
        const Text(
          'أقسام الصيانة والخدمات المنزلية',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.customerPrimary),
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
        const Text(
          'طلباتي وشهادات الضمان (متزامنة حياً مع Supabase)',
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
                leading: const CircleAvatar(
                  backgroundColor: AppColors.customerPrimary,
                  child: Icon(Icons.handyman, color: Colors.white, size: 18),
                ),
                title: Text('${o.serviceName} (#${o.id}) — ${o.statusText}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${o.address} | المزود: ${o.technicianName}\nالعرض: ${o.price} ج.م • الصور الموثقة: (${o.beforePhotos.length} قبل / ${o.afterPhotos.length} بعد)'),
                isThreeLine: true,
                trailing: Wrap(
                  spacing: 6,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf, size: 15),
                      label: const Text('الضمان PDF'),
                      onPressed: () => WarrantyCertificateModal.show(context, o),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        state.activeOrderId = o.id;
                        Navigator.pushNamed(context, AppRoutes.trackOrder, arguments: {'orderId': o.id});
                      },
                      child: const Text('تتبع ودفع'),
                    ),
                  ],
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

  // 2. بوابة الفنيين (تشمل زر التسجيل بالهوية + حالة مراجعة الإدارة + توثيق الصور)
  Widget _buildTechnicianDashboard(BuildContext context, AppStateService state) {
    final pendingTechs = state.technicians.where((t) => t.approvalStatus == 'pending').toList();

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
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 10,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('بوابة مزودي الخدمة والفنيين (Syaanh Provider)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('سجّل هويتك للاعتماد، استقبل الطلبات، ووثّق عملك بصور قبل وبعد الصيانة', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.syaanhOrange),
                    icon: const Icon(Icons.badge),
                    label: const Text('تسجيل فني جديد ورفع الهوية'),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.registerTech),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      'صافي أرباحك: ${state.technicianEarnings.toInt()} ج.م',
                      style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.customerPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (pendingTechs.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.syaanhOrange),
            ),
            child: Row(
              children: [
                const Icon(Icons.pending_actions, color: AppColors.syaanhOrange, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'يوجد عدد (${pendingTechs.length}) طلب انضمام فني (${pendingTechs.first.name}) قيد مراجعة الهوية لدى إدارة التطبيق.',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: () => state.setRole(2),
                  child: const Text('انتقل للوحة الأدمن للموافقة'),
                ),
              ],
            ),
          ),
        ],
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
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                            icon: const Icon(Icons.verified),
                            label: const Text('إتمام العمل وإصدار شهادة الضمان (مكتمل)'),
                            onPressed: () => state.advanceOrderStatus(o.id, targetStatus: 4),
                          ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add_a_photo, size: 16),
                          label: const Text('رفع صورة بعد الصيانة'),
                          onPressed: () => state.addOrderMaintenancePhoto(o.id, isAfterPhoto: true),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.chat),
                          label: const Text('التفاصيل والضمان PDF'),
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

  // 3. لوحة إدارة التطبيق (مراجعة صور هوية الفنيين وإعطاء الموافقة أو الرفض)
  Widget _buildAdminDashboard(BuildContext context, AppStateService state) {
    final int totalSales = state.orders.fold<int>(0, (sum, o) => sum + o.price);
    final int netRevenue = (totalSales * 0.15).toInt();
    final int pendingCount = state.technicians.where((t) => t.approvalStatus == 'pending').length;

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
              _adminMetric('بانتظار مراجعة الهوية', '$pendingCount فنيين'),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'مراجعة طلبات تسجيل الفنيين وتوثيق الهوية (KYC Approval):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.customerPrimary),
              ),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.person_add_alt_1, size: 16),
              label: const Text('إضافة فني جديد'),
              onPressed: () => Navigator.pushNamed(context, AppRoutes.registerTech),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...state.technicians.map((t) {
          final bool isPending = t.approvalStatus == 'pending';
          return Card(
            elevation: 0,
            color: isPending ? const Color(0xFFFFF7ED) : Colors.white,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: isPending ? AppColors.syaanhOrange : AppColors.border, width: isPending ? 1.8 : 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            t.isVerified ? Icons.verified_user : Icons.pending_actions,
                            color: t.isVerified ? AppColors.success : AppColors.syaanhOrange,
                          ),
                          const SizedBox(width: 8),
                          Text('${t.name} • ${t.specialty} (${t.city})', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                        ],
                      ),
                      Chip(
                        label: Text(
                          t.approvalStatusArabic,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: t.isVerified
                            ? AppColors.success
                            : (t.approvalStatus == 'rejected' ? AppColors.danger : AppColors.syaanhOrange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('رقم الهوية القومي / الإقامة: ${t.nationalId} | الخبرة: ${t.experienceYears} سنوات | الجوال: ${t.phone}', style: const TextStyle(fontSize: 12)),
                  Text('المرفقات: [${t.idFrontPhoto}] • [${t.idBackPhoto}] • [${t.certificatePhoto}]', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.search, size: 16),
                        label: const Text('فحص صورة الهوية والمستندات'),
                        onPressed: () => _showKycInspectionDialog(context, state, t),
                      ),
                      if (!t.isVerified)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                          icon: const Icon(Icons.check_circle, size: 16),
                          label: const Text('موافقة وتفعيل حساب الفني'),
                          onPressed: () => state.reviewTechnicianApplication(t.id, approve: true),
                        ),
                      if (t.isVerified || isPending)
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                          icon: const Icon(Icons.cancel, size: 16),
                          label: Text(t.isVerified ? 'إيقاف الاعتماد' : 'رفض الطلب'),
                          onPressed: () => state.reviewTechnicianApplication(t.id, approve: false),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
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