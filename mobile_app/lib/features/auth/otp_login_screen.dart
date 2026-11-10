import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';

class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final _nameCtrl = TextEditingController(text: 'أحمد محمود');
  final _phoneCtrl = TextEditingController(text: '01012345678');
  final _otpCtrl = TextEditingController();
  int _role = 0;
  bool _sent = false;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.byRole(_role);
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول برقم الموبايل (OTP)')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.phonelink_lock, size: 48, color: color),
                      const SizedBox(height: 12),
                      const Text(
                        'منصة خدماتي للصيانة المنزلية في مصر',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          ChoiceChip(label: const Text('عميل'), selected: _role == 0, onSelected: (_) => setState(() => _role = 0)),
                          ChoiceChip(label: const Text('فني صيانة'), selected: _role == 1, onSelected: (_) => setState(() => _role = 1)),
                          ChoiceChip(label: const Text('أدمن المنصة'), selected: _role == 2, onSelected: (_) => setState(() => _role = 2)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person))),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'رقم الموبايل المصري (010/011/012/015)', prefixIcon: Icon(Icons.phone_android)),
                      ),
                      const SizedBox(height: 16),
                      if (!_sent)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.sms),
                          label: const Text('إرسال رمز التحقق OTP'),
                          onPressed: () {
                            final code = AppStateService.instance.sendOtp(_phoneCtrl.text, _nameCtrl.text, _role);
                            setState(() {
                              _sent = true;
                              _otpCtrl.text = code;
                            });
                          },
                        ),
                      if (_sent) ...[
                        const Text('تم إرسال الكود التجريبي: 1234', textAlign: TextAlign.center, style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _otpCtrl,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'أدخل رمز OTP المكون من 4 أرقام'),
                        ),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle),
                          label: const Text('تأكيد الدخول للمنصة'),
                          onPressed: () {
                            if (AppStateService.instance.verifyOtp(_otpCtrl.text)) {
                              Navigator.pushReplacementNamed(context, AppRoutes.home);
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}