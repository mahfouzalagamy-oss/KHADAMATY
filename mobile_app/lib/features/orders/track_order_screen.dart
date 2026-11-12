import 'package:flutter/material.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';
import '../../shared/models/app_models.dart';
import '../../shared/widgets/home_passport_modal.dart';
import '../../shared/widgets/payment_sandbox_modal.dart';
import '../../shared/widgets/role_header_bar.dart';
import '../../shared/widgets/spare_parts_catalog_modal.dart';
import '../../shared/widgets/warranty_certificate_modal.dart';

class TrackOrderScreen extends StatefulWidget {
  final String? orderId;
  const TrackOrderScreen({super.key, this.orderId});

  @override
  State<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends State<TrackOrderScreen> {
  final _chatCtrl = TextEditingController();
  final _reviewCtrl = TextEditingController();
  int _selectedStars = 5;

  OrderItemModel get _order {
    final state = AppStateService.instance;
    if (widget.orderId != null) {
      for (final o in state.orders) {
        if (o.id == widget.orderId) return o;
      }
    }
    return state.activeOrder;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppStateService.instance,
      builder: (context, _) {
        final state = AppStateService.instance;
        final order = _order;

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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildMainStatusCard(context, state, order),
                            const SizedBox(height: 14),
                            _buildElectronicQuoteCard(context, state, order),
                            const SizedBox(height: 14),
                            _buildPhotosCard(state, order),
                            const SizedBox(height: 14),
                            _buildChatCard(state, order),
                            const SizedBox(height: 14),
                            _buildReviewCard(state, order),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainStatusCard(BuildContext context, AppStateService state, OrderItemModel order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (order.isSosEmergency)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(8)),
                        child: const Text(
                          'طوارئ SOS 45 دقيقة',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    Text(
                      'طلب #${order.id} (${order.serviceName})',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.customerPrimary),
                    ),
                  ],
                ),
                Chip(
                  label: Text(
                    order.isPaid
                        ? 'مدفوع + كاش باك +${order.cashbackAmount} ج.م ✅'
                        : 'الإجمالي: ${order.price} ج.م (مكافأة +${order.cashbackAmount} ج.م كاش باك)',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11),
                  ),
                  backgroundColor: order.isPaid ? AppColors.success : AppColors.syaanhOrange,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('الوصف: ${order.description}'),
            Text('العنوان: ${order.address} | ${order.mapCoordinates}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(
              'المزود المعتمد (موثق الهوية): ${order.technicianName} | كود الأمان عند الباب PIN: ${order.pinCode}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.customerPrimary),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.companyPrimary),
                  icon: const Icon(Icons.phone_in_talk, size: 16),
                  label: const Text('اتصال صوتي مشفر (بدون إظهار رقمك)'),
                  onPressed: () => HomePassportModal.showEncryptedCallDialog(context, order),
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.shield, size: 16, color: AppColors.success),
                  label: Text(order.isFamilySafeModeActive ? 'درع الأمان العائلي مفعل (مشاركة الرابط)' : 'تفعيل وضع الأمان العائلي'),
                  onPressed: () => HomePassportModal.showFamilySafeModeDialog(context, order),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.customerPrimary),
                  icon: const Icon(Icons.picture_as_pdf, size: 16),
                  label: const Text('شهادة الضمان والمقايسة PDF'),
                  onPressed: () => WarrantyCertificateModal.show(context, order),
                ),
              ],
            ),
            const Divider(height: 22),
            const Text('مراحل التنفيذ الخمس (جديد ← مقبول ← في الطريق ← قيد التنفيذ ← مكتمل):', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(OrderItemModel.statusLabels.length, (i) {
                final done = order.statusIndex >= i;
                return Chip(
                  avatar: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, size: 16, color: done ? Colors.white : Colors.grey),
                  label: Text(
                    OrderItemModel.statusLabels[i],
                    style: TextStyle(color: done ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  backgroundColor: done ? AppColors.success : Colors.grey.shade200,
                );
              }),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!order.isPaid)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE60000)),
                    icon: const Icon(Icons.phone_android),
                    label: Text('دفع فودافون كاش (${order.price} ج.م) + 10% كاش باك'),
                    onPressed: () {
                      PaymentSandboxModal.show(
                        context,
                        title: 'سداد الطلب #${order.id}',
                        amount: order.price,
                        initialGateway: 'vodafone',
                        onPaymentSuccess: (method, ref) => state.markOrderPaid(order.id, method, ref),
                      );
                    },
                  ),
                if (!order.isPaid)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C1D95)),
                    icon: const Icon(Icons.account_balance),
                    label: Text('دفع إنستا باي (${order.price} ج.م) + 10% كاش باك'),
                    onPressed: () {
                      PaymentSandboxModal.show(
                        context,
                        title: 'سداد الطلب #${order.id}',
                        amount: order.price,
                        initialGateway: 'instapay',
                        onPaymentSuccess: (method, ref) => state.markOrderPaid(order.id, method, ref),
                      );
                    },
                  ),
                if (order.statusIndex < 4)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.fast_forward),
                    label: Text('تحديث المرحلة إلى: ${OrderItemModel.statusLabels[(order.statusIndex + 1).clamp(0, 4)]}'),
                    onPressed: () => state.advanceOrderStatus(order.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElectronicQuoteCard(BuildContext context, AppStateService state, OrderItemModel order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long, color: AppColors.syaanhOrange),
                    SizedBox(width: 8),
                    Text(
                      'المقايسة الإلكترونية وقطع الغيار الرسمية',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.customerPrimary),
                    ),
                  ],
                ),
                Chip(
                  label: Text(
                    order.isQuoteApproved ? 'تم خصم رسوم المعاينة (-50 ج.م) ✓' : 'رسوم المعاينة 50 ج.م قابلة للخصم',
                    style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  backgroundColor: order.isQuoteApproved ? AppColors.success : AppColors.customerPrimary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (order.officialSparePartsUsed.isEmpty)
              const Text('لم تتم إضافة قطع غيار إضافية للمقايسة حتى الآن.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
            else
              Column(
                children: order.officialSparePartsUsed
                    .map((part) => ListTile(
                          dense: true,
                          leading: const Icon(Icons.verified, color: AppColors.success, size: 18),
                          title: Text(part, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: const Text('سعر رسمي موحد من كتالوج المنصة ومشمول بالضمان', style: TextStyle(fontSize: 11)),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text('إضافة قطعة غيار من الكتالوج الرسمي للمقايسة'),
                  onPressed: () => SparePartsCatalogModal.show(context, orderIdForQuote: order.id),
                ),
                if (!order.isQuoteApproved)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text('اعتماد المقايسة وخصم رسوم المعاينة (-50 ج.م) فوراً'),
                    onPressed: () => state.approveElectronicQuoteWithInspectionDeduction(order.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosCard(AppStateService state, OrderItemModel order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'توثيق جودة العمل بالصور (قبل البدء وبعد الإصلاح):',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.customerPrimary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_a_photo, size: 15),
                  label: Text('صور قبل الصيانة (${order.beforePhotos.length}) - إضافة صورة'),
                  onPressed: () => state.addOrderMaintenancePhoto(order.id, isAfterPhoto: false),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                  icon: const Icon(Icons.verified, size: 15),
                  label: Text('صور بعد الإصلاح (${order.afterPhotos.length}) - رفع وتفعيل الضمان'),
                  onPressed: () => state.addOrderMaintenancePhoto(order.id, isAfterPhoto: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatCard(AppStateService state, OrderItemModel order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('الدردشة المشفرة وسجل المقايسة والإيصالات (Supabase Live):', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: order.chatMessages
                  .map((msg) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                          child: Text(msg, style: const TextStyle(fontSize: 12)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatCtrl,
                    decoration: const InputDecoration(labelText: 'اكتب رسالة مشفرة للفني أو العميل...'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.send, size: 16),
                  label: const Text('إرسال'),
                  onPressed: () {
                    final sender = state.currentRole == 1 ? 'الفني' : (state.currentRole == 2 ? 'الشركة' : 'العميل');
                    state.sendChatMessage(order.id, sender, _chatCtrl.text);
                    _chatCtrl.clear();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(AppStateService state, OrderItemModel order) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('تقييم الخدمة واعتماد جودة الفني:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (order.customerRating != null)
              Text(
                'تم التقييم: ${order.customerRating} نجوم - "${order.customerReview}"',
                style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: 6,
                    children: List.generate(5, (i) {
                      final star = i + 1;
                      return ChoiceChip(
                        label: Text('$star ★'),
                        selected: _selectedStars == star,
                        onSelected: (_) => setState(() => _selectedStars = star),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _reviewCtrl,
                    decoration: const InputDecoration(labelText: 'اكتب رأيك في التزام وجودة عمل الفني'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.star),
                    label: const Text('إرسال التقييم'),
                    onPressed: () => state.submitReview(order.id, _selectedStars, _reviewCtrl.text),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}