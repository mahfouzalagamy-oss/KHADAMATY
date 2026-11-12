import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';
import '../models/app_models.dart';

class AiSmartDiagnosisModal extends StatefulWidget {
  const AiSmartDiagnosisModal({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const Directionality(
        textDirection: TextDirection.rtl,
        child: AiSmartDiagnosisModal(),
      ),
    );
  }

  @override
  State<AiSmartDiagnosisModal> createState() => _AiSmartDiagnosisModalState();
}

class _AiSmartDiagnosisModalState extends State<AiSmartDiagnosisModal> {
  final _descCtrl = TextEditingController(text: 'التكييف لا يبرد ويصدر صوت طنين في الوحدة الخارجية');
  final _geminiKeyCtrl = TextEditingController(text: AppStateService.instance.geminiApiKey);
  String _selectedSound = 'صوت طنين في كباس التكييف';
  bool _hasAttachedPhoto = true;
  bool _isAnalyzing = false;
  AiDiagnosisResultModel? _result;

  final List<String> _soundPatterns = const [
    'صوت طنين في كباس التكييف',
    'تقطيع متكرر في موتور المياه',
    'صوت شرز كهربائي في اللوحة',
    'صوت اهتزاز عالي في الغسالة',
    'لا يوجد صوت غير طبيعي',
  ];

  Future<void> _analyzeNow() async {
    setState(() => _isAnalyzing = true);
    AppStateService.instance.geminiApiKey = _geminiKeyCtrl.text.trim();
    final res = await AppStateService.instance.runSmartAiDiagnosis(
      descriptionText: _descCtrl.text,
      soundPattern: _selectedSound,
      hasPhoto: _hasAttachedPhoto,
    );
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _result = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF0C2D48), Color(0xFF145DA0)]),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.syaanhOrange, size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('المعاينة الذكية بالذكاء الاصطناعي (كاميرا + صوت + نص)', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                  Text('تشخيص فوري للعطل + تحديد قطع الغيار الرسمية من الكتالوج قبل وصول الفني', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: '1. صف المشكلة أو العطل بكلماتك',
                  prefixIcon: Icon(Icons.description, color: AppColors.syaanhOrange),
                ),
              ),
              const SizedBox(height: 12),
              const Text('2. محاكاة تحليل صوت الجهاز (Sound Wave Analyzer):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _soundPatterns.map((s) {
                  final sel = _selectedSound == s;
                  return ChoiceChip(
                    avatar: Icon(Icons.mic, size: 15, color: sel ? Colors.white : AppColors.syaanhOrange),
                    label: Text(s, style: TextStyle(fontSize: 11, color: sel ? Colors.white : AppColors.textPrimary)),
                    selected: sel,
                    selectedColor: AppColors.customerPrimary,
                    onSelected: (_) => setState(() => _selectedSound = s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('إرفاق صورة العطل لتحليل الرؤية الحاسوبية (صورة_الجهاز.jpg)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                value: _hasAttachedPhoto,
                onChanged: (v) => setState(() => _hasAttachedPhoto = v),
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('إعدادات متقدمة: ربط مفتاح Google Gemini 2.5 Flash API (اختياري)', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                children: [
                  TextField(
                    controller: _geminiKeyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'مفتاح Gemini API Key (يعمل المحرك الهندسي تلقائياً بدونه)',
                      prefixIcon: Icon(Icons.vpn_key),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: _isAnalyzing
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome),
                label: Text(_isAnalyzing ? 'جاري تحليل الصوت والصورة ومطابقة الكتالوج...' : 'تشغيل الفحص الذكي وحساب التكلفة الآن'),
                onPressed: _isAnalyzing ? null : _analyzeNow,
              ),
              if (_result != null) ...[
                const Divider(height: 24),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified, color: AppColors.success),
                          const SizedBox(width: 6),
                          Expanded(child: Text(_result!.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.customerPrimary))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(_result!.technicalCause, style: const TextStyle(fontSize: 12)),
                      const Divider(),
                      const Text('قطع الغيار المقترحة من الكتالوج الرسمي (بدون تلاعب):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 4),
                      ..._result!.suggestedParts.map((p) => Text('• ${p.name} (${p.brand}) — السعر الرسمي: ${p.officialPrice} ج.م (ضمان ${p.warrantyMonths} شهور)', style: const TextStyle(fontSize: 12, color: AppColors.customerPrimary))),
                      const Divider(),
                      Text('المصنعية التقديرية: ${_result!.estimatedLabor} ج.م | رسوم المعاينة: ${_result!.inspectionFee} ج.م (تُخصم مجاناً عند الإصلاح)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.customerPrimary),
                        icon: const Icon(Icons.check_circle),
                        label: Text('تحويل التشخيص إلى طلب (${_result!.recommendedService}) بالتسعير المعتمد'),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, AppRoutes.createOrder, arguments: {'service': _result!.recommendedService});
                        },
                      ),
                    ],
                  ),
                ),
              ],
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