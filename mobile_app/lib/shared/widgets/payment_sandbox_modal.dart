import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/theme.dart';

class PaymentSandboxModal extends StatefulWidget {
  final String title;
  final int amount;
  final String initialGateway;
  final void Function(String methodLabel, String referenceCode) onPaymentSuccess;

  const PaymentSandboxModal({
    super.key,
    required this.title,
    required this.amount,
    this.initialGateway = 'vodafone',
    required this.onPaymentSuccess,
  });

  static void show(
    BuildContext context, {
    required String title,
    required int amount,
    String initialGateway = 'vodafone',
    required void Function(String methodLabel, String referenceCode) onPaymentSuccess,
  }) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: PaymentSandboxModal(
          title: title,
          amount: amount,
          initialGateway: initialGateway,
          onPaymentSuccess: onPaymentSuccess,
        ),
      ),
    );
  }

  @override
  State<PaymentSandboxModal> createState() => _PaymentSandboxModalState();
}

class _PaymentSandboxModalState extends State<PaymentSandboxModal> {
  late String _gateway;
  int _vfStep = 0;
  final _walletPhoneCtrl = TextEditingController(text: '01010101010');
  final _walletPinCtrl = TextEditingController(text: '123456');
  final _walletOtpCtrl = TextEditingController(text: '123456');

  final _instaIpaAccount = 'khadamaty@instapay';
  final _instaRefCtrl = TextEditingController(
    text: 'IPN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
  );

  @override
  void initState() {
    super.initState();
    _gateway = widget.initialGateway;
  }

  void _completeVodafoneCash() {
    if (_walletPinCtrl.text.trim().isEmpty || _walletOtpCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال الرقم السري التجريبي (123456) وكود OTP (123456)')),
      );
      return;
    }
    final ref = 'VFC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    Navigator.pop(context);
    widget.onPaymentSuccess('فودافون كاش (${_walletPhoneCtrl.text})', ref);
  }

  void _completeInstaPay() {
    final ref = _instaRefCtrl.text.trim().isEmpty
        ? 'IPN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
        : _instaRefCtrl.text.trim();
    Navigator.pop(context);
    widget.onPaymentSuccess('إنستا باي (InstaPay)', ref);
  }

  @override
  Widget build(BuildContext context) {
    final bool isVodafone = _gateway == 'vodafone';
    final Color brandColor = isVodafone ? const Color(0xFFE60000) : const Color(0xFF4C1D95);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.payments, color: brandColor, size: 26),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'بوابة الدفع التجريبية (Sandbox)',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: brandColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.title} — الإجمالي المطلوب: ${widget.amount} ج.م',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ChoiceChip(
                    avatar: Icon(Icons.phone_android, size: 16, color: isVodafone ? Colors.white : const Color(0xFFE60000)),
                    label: Text(
                      'فودافون كاش (Vodafone Cash)',
                      style: TextStyle(color: isVodafone ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    selected: isVodafone,
                    selectedColor: const Color(0xFFE60000),
                    onSelected: (_) => setState(() {
                      _gateway = 'vodafone';
                      _vfStep = 0;
                    }),
                  ),
                  ChoiceChip(
                    avatar: Icon(Icons.account_balance, size: 16, color: !isVodafone ? Colors.white : const Color(0xFF4C1D95)),
                    label: Text(
                      'إنستا باي (InstaPay)',
                      style: TextStyle(color: !isVodafone ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold),
                    ),
                    selected: !isVodafone,
                    selectedColor: const Color(0xFF4C1D95),
                    onSelected: (_) => setState(() => _gateway = 'instapay'),
                  ),
                ],
              ),
              const Divider(height: 22),
              if (isVodafone) _buildVodafoneCashView() else _buildInstaPayView(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
      ],
    );
  }

  Widget _buildVodafoneCashView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE60000)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'بيئة اختبار محفظة فودافون كاش (Wallet Sandbox)',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE60000), fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                'رقم المحفظة التجريبي: 01010101010 | الرقم السري: 123456 | كود OTP: 123456',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _walletPhoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'رقم محفظة فودافون كاش (010xxxxxxxx)',
            prefixIcon: Icon(Icons.phone_android),
          ),
        ),
        const SizedBox(height: 12),
        if (_vfStep == 0)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE60000)),
            icon: const Icon(Icons.send_to_mobile),
            label: Text('إرسال طلب الدفع (${widget.amount} ج.م) للمحفظة'),
            onPressed: () => setState(() => _vfStep = 1),
          ),
        if (_vfStep == 1) ...[
          TextField(
            controller: _walletPinCtrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'الرقم السري للمحفظة (Wallet PIN التجريبي: 123456)',
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _walletOtpCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'كود التفعيل المتغير (OTP التجريبي: 123456)',
              prefixIcon: Icon(Icons.sms),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            icon: const Icon(Icons.verified),
            label: Text('تأكيد خصم ${widget.amount} ج.م وإصدار الإيصال'),
            onPressed: _completeVodafoneCash,
          ),
        ],
      ],
    );
  }

  Widget _buildInstaPayView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF4C1D95)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'التحويل اللحظي عبر شبكة إنستا باي (InstaPay Egypt IPN)',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4C1D95), fontSize: 13),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  SelectableText(
                    'عنوان الدفع (IPA): $_instaIpaAccount',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.copy, size: 15),
                    label: const Text('نسخ عنوان IPA'),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _instaIpaAccount));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم نسخ عنوان الدفع khadamaty@instapay')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Center(
                child: Icon(Icons.qr_code, size: 84, color: Color(0xFF4C1D95)),
              ),
              const Center(
                child: Text('امسح رمز QR من تطبيق InstaPay أو استخدم المحاكاة اللحظية بالأسفل', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _instaRefCtrl,
          decoration: const InputDecoration(
            labelText: 'رقم المرجع (InstaPay Reference Number)',
            prefixIcon: Icon(Icons.receipt_long),
          ),
        ),
        const SizedBox(height: 14),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C1D95)),
          icon: const Icon(Icons.bolt),
          label: Text('محاكاة الدفع اللحظي وتأكيد استلام ${widget.amount} ج.م'),
          onPressed: _completeInstaPay,
        ),
      ],
    );
  }
}