import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';
import '../../shared/widgets/role_header_bar.dart';

class TechnicianRegistrationScreen extends StatefulWidget {
  const TechnicianRegistrationScreen({super.key});

  @override
  State<TechnicianRegistrationScreen> createState() => _TechnicianRegistrationScreenState();
}

class _TechnicianRegistrationScreenState extends State<TechnicianRegistrationScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _expCtrl = TextEditingController(text: '5');
  final _walletCtrl = TextEditingController();

  String _selectedSpecialty = 'تكييف وتبريد';
  String _selectedCity = 'القاهرة';

  String? _idFrontFile = 'صورة_البطاقة_الشخصية_أمامي.jpg';
  String? _idBackFile = 'صورة_البطاقة_الشخصية_خلفي.jpg';
  String? _certFile = 'صحيفة_الحالة_الجنائية_والخبرة.jpg';

  void _submitApplication() {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty || _nationalIdCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.danger,
          content: Text('يرجى إدخال اسم الفني، رقم الموبايل، ورقم البطاقة الشخصية / الهوية'),
        ),
      );
      return;
    }

    if (_idFrontFile == null || _idBackFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.danger,
          content: Text('يرجى إرفاق صورة الهوية (الوجه الأمامي والخلفي) لإتمام التسجيل'),
        ),
      );
      return;
    }

    final state = AppStateService.instance;
    final newTech = state.registerNewTechnicianApplication(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      specialty: _selectedSpecialty,
      city: _selectedCity,
      nationalId: _nationalIdCtrl.text.trim(),
      idFrontPhoto: _idFrontFile!,
      idBackPhoto: _idBackFile!,
      certificatePhoto: _certFile ?? 'غير مرفق',
      experienceYears: int.tryParse(_expCtrl.text.trim()) ?? 3,
      walletNumber: _walletCtrl.text.trim().isEmpty ? _phoneCtrl.text.trim() : _walletCtrl.text.trim(),
    );

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.mark_email_read, color: AppColors.syaanhOrange, size: 28),
              SizedBox(width: 8),
              Expanded(child: Text('تم إرسال طلب التسجيل والهوية للإدارة')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مرحباً بك يا ${newTech.name} في منصة خدماتي • صيانة.'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.syaanhOrange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('رقم طلب العضوية: #${newTech.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('رقم الهوية المرفق: ${newTech.nationalId}'),
                    const Text('الحالة الحالية: قيد مراجعة إدارة التطبيق ⏳', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.syaanhOrange)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'سيقوم مدير المنصة (الأدمن) بمراجعة صورة الهوية وبياناتك وإعطاء الموافقة لتفعيل حسابك واستقبال طلبات العملاء.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                state.setRole(1);
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
              child: const Text('الذهاب لبوابة الفني'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.admin_panel_settings, size: 16),
              label: const Text('فتح لوحة الأدمن الآن للموافقة على الفني'),
              onPressed: () {
                Navigator.pop(ctx);
                state.setRole(2);
                Navigator.pushReplacementNamed(context, AppRoutes.home);
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
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'تسجيل فني / مزود خدمة جديد وتوثيق الهوية (KYC)',
                                        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.customerPrimary),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'أدخل بياناتك وارفع صورة البطاقة الشخصية أو الإقامة لمراجعتها واعتمادها من إدارة التطبيق',
                                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.arrow_back, size: 16),
                                  label: const Text('رجوع'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            const Divider(height: 26),
                            const Text('1. البيانات الشخصية والمهنية للفني:', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.customerPrimary)),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: 270,
                                  child: TextField(
                                    controller: _nameCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'الاسم الكامل (مطابق للهوية)',
                                      prefixIcon: Icon(Icons.person),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 270,
                                  child: TextField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(
                                      labelText: 'رقم الجوال الفعال (مصر / قطر)',
                                      prefixIcon: Icon(Icons.phone_android),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 280,
                                  child: TextField(
                                    controller: _nationalIdCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'رقم البطاقة القومي / الإقامة (QID)',
                                      prefixIcon: Icon(Icons.badge),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: 270,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedSpecialty,
                                    decoration: const InputDecoration(labelText: 'التخصص الرئيسي', prefixIcon: Icon(Icons.handyman)),
                                    items: state.services
                                        .map((s) => DropdownMenuItem(value: s.name, child: Text(s.name, style: const TextStyle(fontSize: 13))))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) setState(() => _selectedSpecialty = v);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 270,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedCity,
                                    decoration: const InputDecoration(labelText: 'المدينة / منطقة العمل', prefixIcon: Icon(Icons.location_city)),
                                    items: state.egyptCities
                                        .map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))))
                                        .toList(),
                                    onChanged: (v) {
                                      if (v != null) setState(() => _selectedCity = v);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: TextField(
                                    controller: _expCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'سنوات الخبرة'),
                                  ),
                                ),
                                SizedBox(
                                  width: 280,
                                  child: TextField(
                                    controller: _walletCtrl,
                                    decoration: const InputDecoration(
                                      labelText: 'رقم محفظة فودافون كاش / إنستا باي للأرباح',
                                      prefixIcon: Icon(Icons.account_balance_wallet),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            const Text('2. رفع صور إثبات الهوية والمستندات (إلزامي لمراجعة الإدارة):', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.customerPrimary)),
                            const SizedBox(height: 10),
                            _buildUploadCard(
                              title: 'صورة البطاقة الشخصية / الإقامة (الوجه الأمامي)',
                              subtitle: 'يجب أن تكون الأرقام والصورة واضحة تماماً للمطابقة',
                              fileName: _idFrontFile,
                              onUpload: () => setState(() => _idFrontFile = 'الهوية_الوجه_الأمامي_${DateTime.now().second}.jpg'),
                            ),
                            const SizedBox(height: 10),
                            _buildUploadCard(
                              title: 'صورة البطاقة الشخصية / الإقامة (الوجه الخلفي)',
                              subtitle: 'لتأكيد سريان صلاحية البطاقة والبيانات المهنية',
                              fileName: _idBackFile,
                              onUpload: () => setState(() => _idBackFile = 'الهوية_الوجه_الخلفي_${DateTime.now().second}.jpg'),
                            ),
                            const SizedBox(height: 10),
                            _buildUploadCard(
                              title: 'صحيفة الحالة الجنائية (الفيش) أو شهادة الخبرة الفنية',
                              subtitle: 'تزيد من أولوية ظهور عروضك للعملاء وتمنحك شارة الضمان الذهبي',
                              fileName: _certFile,
                              onUpload: () => setState(() => _certFile = 'شهادة_الفيش_والخبرة_${DateTime.now().second}.jpg'),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.verified_user),
                              label: const Text('إرسال بيانات الفني وصور الهوية لمراجعة إدارة التطبيق'),
                              onPressed: _submitApplication,
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

  Widget _buildUploadCard({
    required String title,
    required String subtitle,
    required String? fileName,
    required VoidCallback onUpload,
  }) {
    final bool uploaded = fileName != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: uploaded ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: uploaded ? AppColors.success : AppColors.border),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 10,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                uploaded ? Icons.check_circle : Icons.badge_outlined,
                color: uploaded ? AppColors.success : AppColors.syaanhOrange,
                size: 28,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  if (uploaded)
                    Text('المستند المرفق: $fileName ✓', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success)),
                ],
              ),
            ],
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.camera_alt, size: 16),
            label: Text(uploaded ? 'تحديث صورة الهوية' : 'التقاط / رفع الصورة'),
            onPressed: onUpload,
          ),
        ],
      ),
    );
  }
}