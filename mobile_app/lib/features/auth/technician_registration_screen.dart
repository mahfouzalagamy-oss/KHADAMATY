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
  String _selectedCompany = 'فني مستقل معتمد';

  String _idFrontFile = 'صورة_البطاقة_الشخصية_أمامي.jpg';
  String _idBackFile = 'صورة_البطاقة_الشخصية_خلفي.jpg';
  String _certFile = 'صحيفة_الحالة_الجنائية_والخبرة.jpg';

  void _submitApplication() {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty || _nationalIdCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.danger,
          content: Text('يرجى إدخال اسم الفني، رقم الجوال، ورقم البطاقة الشخصية / الإقامة'),
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
      idFrontPhoto: _idFrontFile,
      idBackPhoto: _idBackFile,
      certificatePhoto: _certFile,
      experienceYears: int.tryParse(_expCtrl.text.trim()) ?? 4,
      walletNumber: _walletCtrl.text.trim().isEmpty ? _phoneCtrl.text.trim() : _walletCtrl.text.trim(),
      companyAffiliation: _selectedCompany,
    );

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Row(
            children: [
              Icon(Icons.verified_user, color: AppColors.syaanhOrange, size: 28),
              SizedBox(width: 8),
              Expanded(child: Text('تم إرسال طلب التسجيل وصور الهوية للإدارة')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('تم تسجيل بيانات الفني (${newTech.name}) برقم عضوية #${newTech.id}.'),
              const SizedBox(height: 8),
              const Text('الحالة الآن: قيد مراجعة إدارة التطبيق للهوية ⏳', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.syaanhOrange)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                state.setRole(1);
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
              child: const Text('بوابة الفني'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.admin_panel_settings, size: 16),
              label: const Text('فتح صفحة الإدارة الآن لإعطاء الموافقة'),
              onPressed: () {
                Navigator.pop(ctx);
                state.setRole(3);
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
    final companyOptions = ['فني مستقل معتمد', ...state.companies.map((c) => c.name)];

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 940),
            child: Column(
              children: [
                const RoleHeaderBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'تسجيل فني جديد وتوثيق الهوية الوطنية (KYC Verification)',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.customerPrimary),
                                  ),
                                ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.arrow_back, size: 16),
                                  label: const Text('رجوع'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: 270,
                                  child: TextField(
                                    controller: _nameCtrl,
                                    decoration: const InputDecoration(labelText: 'الاسم الكامل (مطابق للهوية)', prefixIcon: Icon(Icons.person)),
                                  ),
                                ),
                                SizedBox(
                                  width: 270,
                                  child: TextField(
                                    controller: _phoneCtrl,
                                    keyboardType: TextInputType.phone,
                                    decoration: const InputDecoration(labelText: 'رقم الجوال الفعال', prefixIcon: Icon(Icons.phone_android)),
                                  ),
                                ),
                                SizedBox(
                                  width: 280,
                                  child: TextField(
                                    controller: _nationalIdCtrl,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(labelText: 'رقم البطاقة القومي / الإقامة', prefixIcon: Icon(Icons.badge)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: 260,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedSpecialty,
                                    decoration: const InputDecoration(labelText: 'التخصص الفني', prefixIcon: Icon(Icons.handyman)),
                                    items: state.services.map((s) => DropdownMenuItem(value: s.name, child: Text(s.name, style: const TextStyle(fontSize: 13)))).toList(),
                                    onChanged: (v) {
                                      if (v != null) setState(() => _selectedSpecialty = v);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 260,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedCity,
                                    decoration: const InputDecoration(labelText: 'المدينة', prefixIcon: Icon(Icons.location_on)),
                                    items: state.egyptCities.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                                    onChanged: (v) {
                                      if (v != null) setState(() => _selectedCity = v);
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 300,
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedCompany,
                                    decoration: const InputDecoration(labelText: 'التبعية (مستقل أو تابع لشركة)', prefixIcon: Icon(Icons.business)),
                                    items: companyOptions.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                                    onChanged: (v) {
                                      if (v != null) setState(() => _selectedCompany = v);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            const Text('مرفقات الهوية والفيش الجنائي (تظهر في صفحة الإدارة للموافقة):', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _uploadRow('1. صورة البطاقة الشخصية (الوجه الأمامي)', _idFrontFile, () {
                              setState(() => _idFrontFile = 'هوية_أمامي_${DateTime.now().second}.jpg');
                            }),
                            const SizedBox(height: 8),
                            _uploadRow('2. صورة البطاقة الشخصية (الوجه الخلفي)', _idBackFile, () {
                              setState(() => _idBackFile = 'هوية_خلفي_${DateTime.now().second}.jpg');
                            }),
                            const SizedBox(height: 8),
                            _uploadRow('3. صحيفة الحالة الجنائية (الفيش) وشهادة الخبرة', _certFile, () {
                              setState(() => _certFile = 'فيش_وخبرة_${DateTime.now().second}.jpg');
                            }),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.verified_user),
                              label: const Text('إرسال الهوية والبيانات لمراجعة الإدارة واعتماد الحساب'),
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

  Widget _uploadRow(String label, String fileName, VoidCallback onPick) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('المرفق: $fileName ✓', style: const TextStyle(fontSize: 11, color: AppColors.success)),
            ],
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.camera_alt, size: 15),
            label: const Text('تحديث الصورة'),
            onPressed: onPick,
          ),
        ],
      ),
    );
  }
}