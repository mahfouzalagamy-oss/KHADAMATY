import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';
import '../../shared/models/app_models.dart';
import '../../shared/widgets/ai_diagnosis_modal.dart';
import '../../shared/widgets/home_passport_modal.dart';
import '../../shared/widgets/payment_sandbox_modal.dart';
import '../../shared/widgets/role_header_bar.dart';
import '../../shared/widgets/spare_parts_catalog_modal.dart';
import '../../shared/widgets/warranty_certificate_modal.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';

  void _triggerQuickSosDialog(BuildContext context, AppStateService state) {
    final addrCtrl = TextEditingController(text: '${state.selectedCity} - الموقع الحالي عبر GPS');
    String selectedService = 'كهرباء';

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.emergency, color: AppColors.danger, size: 28),
              SizedBox(width: 8),
              Expanded(child: Text('رادار الطوارئ السريع SOS (وصول خلال 45 دقيقة)', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w900, fontSize: 16))),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('يرسل نداء استغاثة فورياً لأقرب 5 فنيين وشركات متاحة في محيط 2 كم لمعالجة الأعطال الحرجة:', style: TextStyle(fontSize: 12)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedService,
                decoration: const InputDecoration(labelText: 'نوع الطوارئ الحرجة'),
                items: state.services.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name))).toList(),
                onChanged: (v) {
                  if (v != null) selectedService = v;
                },
              ),
              const SizedBox(height: 10),
              TextField(controller: addrCtrl, decoration: const InputDecoration(labelText: 'موقع الطوارئ GPS', prefixIcon: Icon(Icons.my_location))),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              icon: const Icon(Icons.bolt),
              label: const Text('إطلاق نداء الطوارئ SOS الآن'),
              onPressed: () {
                final order = state.triggerSosEmergencyOrder(
                  serviceName: selectedService,
                  urgentDescription: 'بلاغ طوارئ عاجل يتطلب وصول الفني خلال 45 دقيقة',
                  address: addrCtrl.text,
                );
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRoutes.trackOrder, arguments: {'orderId': order.id});
              },
            ),
          ],
        ),
      ),
    );
  }

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
              Expanded(child: Text('مراجعة هوية ووثائق الفني: ${tech.name}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900))),
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
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الاسم الكامل: ${tech.name}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('التخصص والجهة: ${tech.specialty} • ${tech.companyAffiliation}'),
                        Text('رقم البطاقة / الهوية الوطنية: ${tech.nationalId}', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.customerPrimary)),
                        Text('الحالة: ${tech.approvalStatusArabic}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.syaanhOrange)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(dense: true, leading: const Icon(Icons.credit_card, color: AppColors.success), title: Text('الوجه الأمامي للهوية: ${tech.idFrontPhoto}')),
                  ListTile(dense: true, leading: const Icon(Icons.credit_card, color: AppColors.success), title: Text('الوجه الخلفي للهوية: ${tech.idBackPhoto}')),
                  ListTile(dense: true, leading: const Icon(Icons.workspace_premium, color: AppColors.success), title: Text('الفيش الجنائي والخبرة: ${tech.certificatePhoto}')),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق')),
            OutlinedButton(
              onPressed: () {
                state.reviewTechnicianApplication(tech.id, approve: false);
                Navigator.pop(ctx);
              },
              child: const Text('رفض الطلب'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              icon: const Icon(Icons.check_circle, size: 16),
              label: const Text('موافقة وتفعيل الحساب رسمياً'),
              onPressed: () {
                state.reviewTechnicianApplication(tech.id, approve: true);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCompanyDialog(BuildContext context, AppStateService state) {
    final nameCtrl = TextEditingController();
    final crCtrl = TextEditingController(text: 'CR-992811');
    final taxCtrl = TextEditingController(text: 'TX-441-882-100');
    final fleetCtrl = TextEditingController(text: '15');

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('تسجيل شركة صيانة ومقاولات جديدة (B2B)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم الشركة الرسمي', prefixIcon: Icon(Icons.business))),
                const SizedBox(height: 10),
                TextField(controller: crCtrl, decoration: const InputDecoration(labelText: 'رقم السجل التجاري', prefixIcon: Icon(Icons.badge))),
                const SizedBox(height: 10),
                TextField(controller: taxCtrl, decoration: const InputDecoration(labelText: 'رقم البطاقة الضريبية', prefixIcon: Icon(Icons.receipt_long))),
                const SizedBox(height: 10),
                TextField(controller: fleetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'عدد الفنيين في أسطول الشركة', prefixIcon: Icon(Icons.groups))),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  state.registerNewCompany(
                    name: nameCtrl.text.trim(),
                    specialty: 'صيانة متكاملة وعقود سنوية AMC',
                    city: state.selectedCity,
                    commercialReg: crCtrl.text.trim(),
                    taxCard: taxCtrl.text.trim(),
                    fleetCount: int.tryParse(fleetCtrl.text.trim()) ?? 10,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('اعتماد وتسجيل الشركة'),
            ),
          ],
        ),
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
                constraints: const BoxConstraints(maxWidth: 980),
                child: Column(
                  children: [
                    const RoleHeaderBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: _buildPortalView(context, state),
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
              if (i == 1) AiSmartDiagnosisModal.show(context);
              if (i == 2) SparePartsCatalogModal.show(context);
              if (i == 3) HomePassportModal.show(context);
              if (i == 4) Navigator.pushNamed(context, AppRoutes.registerTech);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
              BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'تشخيص ذكي AI'),
              BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'كتالوج القطع'),
              BottomNavigationBarItem(icon: Icon(Icons.workspace_premium), label: 'جواز المنزل'),
              BottomNavigationBarItem(icon: Icon(Icons.badge), label: 'توثيق فني'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPortalView(BuildContext context, AppStateService state) {
    if (state.currentRole == 1) return _buildTechnicianPortal(context, state);
    if (state.currentRole == 2) return _buildCompaniesPortal(context, state);
    if (state.currentRole == 3) return _buildAdminAndReviewerPortal(context, state);
    return _buildCustomerPortal(context, state);
  }

  // ===========================================================================
  // 1. بوابة العميل المتكاملة (Customer Super-Portal)
  // ===========================================================================
  Widget _buildCustomerPortal(BuildContext context, AppStateService state) {
    final filteredServices = state.services.where((s) {
      if (_searchQuery.trim().isEmpty) return true;
      return s.name.contains(_searchQuery.trim()) || s.subtitle.contains(_searchQuery.trim());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // البنر الرئيسي المزود بأزرار الذكاء الاصطناعي ورادار الطوارئ SOS
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0C2D48), Color(0xFF145DA0)]),
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
                      Text('منصة خدماتي • صيانة الذكية (مصر وقطر)', style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900)),
                      SizedBox(height: 4),
                      Text('تشخيص بالذكاء الاصطناعي • كتالوج قطع غيار رسمي يمنع التلاعب • أمان عائلي و10% كاش باك', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                        icon: const Icon(Icons.emergency),
                        label: const Text('رادار طوارئ SOS (45 دقيقة)'),
                        onPressed: () => _triggerQuickSosDialog(context, state),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.syaanhOrange),
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('فحص العطل بالذكاء الاصطناعي'),
                        onPressed: () => AiSmartDiagnosisModal.show(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'ابحث عن خدمة صيانة أو قطعة غيار رسمية (تكييف، سباكة، كهرباء، غسالات...)',
                  prefixIcon: const Icon(Icons.search, color: AppColors.syaanhOrange),
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 14),
              // شريط المميزات الحصرية الأربعة للوصول السريع
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.receipt_long, size: 16, color: AppColors.syaanhOrange),
                    label: const Text('كتالوج أسعار قطع الغيار الرسمي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    onPressed: () => SparePartsCatalogModal.show(context),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.workspace_premium, size: 16, color: AppColors.companyPrimary),
                    label: Text('جواز المنزل الصياني (${state.homeAppliances.length} أجهزة)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    onPressed: () => HomePassportModal.show(context),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.shield, size: 16, color: AppColors.success),
                    label: const Text('درع الأمان العائلي وتتبع الزيارة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    onPressed: () => HomePassportModal.showFamilySafeModeDialog(context, state.activeOrder),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.lock, size: 16, color: AppColors.customerPrimary),
                    label: const Text('مكالمة مشفرة بدون إظهار رقمك', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    onPressed: () => HomePassportModal.showEncryptedCallDialog(context, state.activeOrder),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // شريط محفظة الكاش باك 10% والدفع الإلكتروني
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
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
                      decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.account_balance_wallet, color: AppColors.success),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'رصيد المحفظة: ${state.customerWallet.toInt()} ج.م (إجمالي الكاش باك المكتسب: +${state.totalCashbackEarned.toInt()} ج.م 🎁)',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.customerPrimary),
                        ),
                        const Text('احصل على 10% رصيد مسترد فوري وتفعيل الضمان الذهبي عند الدفع الإلكتروني', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE60000)),
                      icon: const Icon(Icons.phone_android, size: 15),
                      label: const Text('فودافون كاش (+10% هدية)'),
                      onPressed: () {
                        PaymentSandboxModal.show(
                          context,
                          title: 'شحن محفظة صيانة (+10% كاش باك)',
                          amount: 200,
                          initialGateway: 'vodafone',
                          onPaymentSuccess: (m, r) => state.rechargeWalletViaSandbox(200, m, r),
                        );
                      },
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C1D95)),
                      icon: const Icon(Icons.account_balance, size: 15),
                      label: const Text('إنستا باي (+10% هدية)'),
                      onPressed: () {
                        PaymentSandboxModal.show(
                          context,
                          title: 'شحن محفظة صيانة (+10% كاش باك)',
                          amount: 200,
                          initialGateway: 'instapay',
                          onPaymentSuccess: (m, r) => state.rechargeWalletViaSandbox(200, m, r),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // شبكة أقسام الصيانة مع توضيح رسوم المعاينة القابلة للخصم
        const Text('أقسام الصيانة المعتمدة (رسوم المعاينة 50 ج.م تُخصم بالكامل عند الإصلاح):', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.customerPrimary)),
        const SizedBox(height: 10),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(backgroundColor: const Color(0xFFFFF7ED), child: Icon(s.icon, color: AppColors.syaanhOrange)),
                        const SizedBox(height: 8),
                        Text(s.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.customerPrimary)),
                        Text(s.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text('يبدأ من ${s.minPrice} ج.م • معاينة تُخصم', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.syaanhOrange)),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        const SizedBox(height: 20),

        // الطلبات الحالية والمقايسات المعتمدة
        const Text('طلباتي النشطة والمقايسات الإلكترونية وشهادات الضمان:', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.customerPrimary)),
        const SizedBox(height: 8),
        ...state.orders.map((o) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: o.isSosEmergency ? AppColors.danger : AppColors.customerPrimary,
                  child: Icon(o.isSosEmergency ? Icons.emergency : Icons.handyman, color: Colors.white, size: 18),
                ),
                title: Text('${o.serviceName} (#${o.id}) — ${o.statusText}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${o.address} | الفني: ${o.technicianName}\nالإجمالي: ${o.price} ج.م • قطع غيار رسمية: (${o.officialSparePartsUsed.length}) • كاش باك: +${o.cashbackAmount} ج.م'),
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
                      child: const Text('المقايسة والتتبع'),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // ===========================================================================
  // 2. بوابة الفني المستقل (Technician Portal)
  // ===========================================================================
  Widget _buildTechnicianPortal(BuildContext context, AppStateService state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.technicianPrimary, borderRadius: BorderRadius.circular(18)),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('بوابة الفني المعتمد — إدارة المهام والمقايسات الإلكترونية', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  Text('أضف قطع الغيار من الكتالوج الرسمي، وثّق صور قبل وبعد الإصلاح، واستلم أرباحك فوراً', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.badge),
                    label: const Text('توثيق هوية فني جديد'),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.registerTech),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Text('صافي أرباحك: ${state.technicianEarnings.toInt()} ج.م', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.customerPrimary)),
                  ),
                ],
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
                      children: [
                        Text('طلب #${o.id} - ${o.serviceName} (${o.price} ج.م)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Chip(label: Text('${o.statusText} | كود الباب PIN: ${o.pinCode}')),
                      ],
                    ),
                    Text('العميل: ${o.customerName} | العنوان: ${o.address}'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.fast_forward, size: 16),
                          label: Text(o.statusIndex < 4 ? 'تحديث إلى: ${OrderItemModel.statusLabels[(o.statusIndex + 1).clamp(0, 4)]}' : 'مكتمل ✓'),
                          onPressed: o.statusIndex < 4 ? () => state.advanceOrderStatus(o.id) : null,
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.receipt_long, size: 16),
                          label: const Text('إضافة قطعة غيار من الكتالوج الرسمي للمقايسة'),
                          onPressed: () => SparePartsCatalogModal.show(context, orderIdForQuote: o.id),
                        ),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.add_a_photo, size: 16),
                          label: const Text('رفع صورة بعد الصيانة'),
                          onPressed: () => state.addOrderMaintenancePhoto(o.id, isAfterPhoto: true),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.phone_in_talk, size: 16),
                          label: const Text('اتصال مشفر بالعميل'),
                          onPressed: () => HomePassportModal.showEncryptedCallDialog(context, o),
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

  // ===========================================================================
  // 3. بوابة الشركات والمقاولين (B2B Companies & Fleet Portal)
  // ===========================================================================
  Widget _buildCompaniesPortal(BuildContext context, AppStateService state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.companyPrimary, borderRadius: BorderRadius.circular(18)),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('بوابة شركات الصيانة والمقاولين المعتمدين (B2B Fleet Portal)', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  Text('إدارة أسطول الفنيين التابعين للشركة، عقود الصيانة السنوية AMC، والفواتير الضريبية', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Wrap(
                spacing: 8,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add_circle),
                    label: const Text('تسجيل شركة صيانة جديدة'),
                    onPressed: () => _showAddCompanyDialog(context, state),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white)),
                    icon: const Icon(Icons.person_add),
                    label: const Text('إضافة فني لأسطول الشركة'),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.registerTech),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('الشركات المعتمدة وأساطيل الصيانة المسجلة:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.customerPrimary)),
        const SizedBox(height: 8),
        ...state.companies.map((c) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppColors.border)),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.companyPrimary,
                  child: Icon(Icons.apartment, color: Colors.white),
                ),
                title: Text('${c.name} (${c.city})', style: const TextStyle(fontWeight: FontWeight.w900)),
                subtitle: Text('التخصص: ${c.specialty}\nالسجل التجاري: ${c.commercialReg} | البطاقة الضريبية: ${c.taxCard} | الأسطول: ${c.techniciansCount} فنيين | العقود السنوية AMC: ${c.activeAmcContracts} عقد'),
                isThreeLine: true,
                trailing: Chip(
                  label: Text('${c.rating} ★ معتمدة', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                  backgroundColor: AppColors.success,
                ),
              ),
            )),
      ],
    );
  }

  // ===========================================================================
  // 4. صفحة الإدارة والمراجع الشاملة (Admin & Reviewer Control Center)
  // ===========================================================================
  Widget _buildAdminAndReviewerPortal(BuildContext context, AppStateService state) {
    final int totalSales = state.orders.fold<int>(0, (sum, o) => sum + o.price);
    final int netRevenue = (totalSales * 0.15).toInt();
    final int pendingTechs = state.technicians.where((t) => t.approvalStatus == 'pending').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: AppColors.customerPrimary, borderRadius: BorderRadius.circular(18)),
          child: Wrap(
            alignment: WrapAlignment.spaceAround,
            spacing: 14,
            runSpacing: 10,
            children: [
              _adminMetric('إجمالي الطلبات', '${state.orders.length} طلب'),
              _adminMetric('حجم المعاملات', '$totalSales ج.م'),
              _adminMetric('عمولة المنصة (15%)', '$netRevenue ج.م'),
              _adminMetric('بانتظار فحص الهوية', '$pendingTechs فنيين'),
              _adminMetric('الشركات المعتمدة', '${state.companies.length} شركات'),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // أولاً: مراجعة هوية الفنيين وإعطاء الموافقة (KYC Approval)
        const Text('1. مراجعة صور هوية الفنيين وإعطاء الموافقة (KYC Approval):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.customerPrimary)),
        const SizedBox(height: 8),
        ...state.technicians.map((t) {
          final bool isPending = t.approvalStatus == 'pending';
          return Card(
            color: isPending ? const Color(0xFFFFF7ED) : Colors.white,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: isPending ? AppColors.syaanhOrange : AppColors.border, width: isPending ? 1.8 : 1),
            ),
            child: ListTile(
              leading: Icon(t.isVerified ? Icons.verified_user : Icons.pending_actions, color: t.isVerified ? AppColors.success : AppColors.syaanhOrange),
              title: Text('${t.name} • ${t.specialty} (${t.companyAffiliation})', style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text('رقم الهوية: ${t.nationalId} | المرفقات: [${t.idFrontPhoto} + ${t.idBackPhoto}]\nالحالة: ${t.approvalStatusArabic}'),
              isThreeLine: true,
              trailing: Wrap(
                spacing: 6,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.visibility, size: 15),
                    label: const Text('فحص الهوية'),
                    onPressed: () => _showKycInspectionDialog(context, state, t),
                  ),
                  if (!t.isVerified)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                      onPressed: () => state.reviewTechnicianApplication(t.id, approve: true),
                      child: const Text('موافقة ✅'),
                    ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 18),

        // ثانياً: التحكم في أسعار كتالوج قطع الغيار الرسمي
        const Text('2. إدارة كتالوج أسعار قطع الغيار الرسمي (لمنع التلاعب بالأسعار):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.customerPrimary)),
        const SizedBox(height: 8),
        ...state.sparePartsCatalog.take(5).map((p) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                dense: true,
                leading: const Icon(Icons.settings, color: AppColors.syaanhOrange),
                title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('الماركة: ${p.brand} | السعر الرسمي الحالي: ${p.officialPrice} ج.م'),
                trailing: OutlinedButton.icon(
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('تحديث السعر (+20 ج.م)'),
                  onPressed: () => state.updateSparePartPrice(p.id, p.officialPrice + 20),
                ),
              ),
            )),
      ],
    );
  }

  Widget _adminMetric(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: AppColors.syaanhOrange, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
      ],
    );
  }
}