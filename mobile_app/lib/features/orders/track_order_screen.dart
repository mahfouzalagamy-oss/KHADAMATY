import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';
import '../../shared/models/app_models.dart';
import '../../shared/widgets/payment_sandbox_modal.dart';
import '../../shared/widgets/role_header_bar.dart';

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
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  children: [
                    const RoleHeaderBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                        Text('تتبع حالة الطلب #${order.id} (${order.serviceName})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                                        Chip(
                                          label: Text(
                                            order.isPaid ? 'مدفوع ومؤكد ✅' : 'بانتظار السداد (${order.price} ج.م)',
                                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                          ),
                                          backgroundColor: order.isPaid ? AppColors.success : AppColors.accentAmber,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text('الوصف: ${order.description}'),
                                    Text('الموقع: ${order.address} | ${order.mapCoordinates}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                    Text('وسيلة الدفع: ${order.paymentMethod} | القيمة: ${order.price} ج.م', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('الفني المعين: ${order.technicianName} (${order.technicianPhone}) | كود الأمان PIN: ${order.pinCode}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.customerPrimary)),
                                    const SizedBox(height: 16),
                                    const Text('شريط تتبع الحالة الخماسي (جديد ← مقبول ← في الطريق ← قيد التنفيذ ← مكتمل):', style: TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: List.generate(OrderItemModel.statusLabels.length, (i) {
                                        final done = order.statusIndex >= i;
                                        return Chip(
                                          avatar: Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: done ? Colors.white : Colors.grey),
                                          label: Text(
                                            OrderItemModel.statusLabels[i],
                                            style: TextStyle(color: done ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold),
                                          ),
                                          backgroundColor: done ? AppColors.success : Colors.grey.shade200,
                                        );
                                      }),
                                    ),
                                    const SizedBox(height: 16),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        if (!order.isPaid) ...[
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE60000)),
                                            icon: const Icon(Icons.phone_android),
                                            label: Text('دفع فودافون كاش (${order.price} ج.م)'),
                                            onPressed: () {
                                              PaymentSandboxModal.show(
                                                context,
                                                title: 'سداد الطلب #${order.id}',
                                                amount: order.price,
                                                initialGateway: 'vodafone',
                                                onPaymentSuccess: (method, ref) {
                                                  state.markOrderPaid(order.id, method, ref);
                                                },
                                              );
                                            },
                                          ),
                                          ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4C1D95)),
                                            icon: const Icon(Icons.account_balance),
                                            label: Text('دفع إنستا باي (${order.price} ج.م)'),
                                            onPressed: () {
                                              PaymentSandboxModal.show(
                                                context,
                                                title: 'سداد الطلب #${order.id}',
                                                amount: order.price,
                                                initialGateway: 'instapay',
                                                onPaymentSuccess: (method, ref) {
                                                  state.markOrderPaid(order.id, method, ref);
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                        if (order.statusIndex < 4)
                                          OutlinedButton.icon(
                                            icon: const Icon(Icons.fast_forward),
                                            label: Text('تحديث الحالة إلى: ${OrderItemModel.statusLabels[(order.statusIndex + 1).clamp(0, 4)]}'),
                                            onPressed: () => state.advanceOrderStatus(order.id),
                                          ),
                                        TextButton.icon(
                                          icon: const Icon(Icons.home),
                                          label: const Text('العودة للرئيسية'),
                                          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.home),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text('الدردشة الفورية وإيصالات الدفع (متزامنة عبر Supabase):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    ...order.chatMessages.map((msg) => Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                                            child: Text(msg, style: const TextStyle(fontSize: 13)),
                                          ),
                                        )),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _chatCtrl,
                                            decoration: const InputDecoration(labelText: 'اكتب رسالة للفني أو العميل...'),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton.icon(
                                          icon: const Icon(Icons.send, size: 16),
                                          label: const Text('إرسال'),
                                          onPressed: () {
                                            final sender = state.currentRole == 1 ? 'الفني' : 'العميل';
                                            state.sendChatMessage(order.id, sender, _chatCtrl.text);
                                            _chatCtrl.clear();
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Text('تقييم الخدمة والفني:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    if (order.customerRating != null)
                                      Text('تم تقييم الخدمة: ${order.customerRating} نجوم - "${order.customerReview}"', style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))
                                    else ...[
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
                                      TextField(controller: _reviewCtrl, decoration: const InputDecoration(labelText: 'اكتب رأيك في التزام وجودة عمل الفني')),
                                      const SizedBox(height: 10),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.star),
                                        label: const Text('إرسال التقييم وتحديث سجل الفني'),
                                        onPressed: () => state.submitReview(order.id, _selectedStars, _reviewCtrl.text),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
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
}