import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/theme.dart';
import '../models/app_models.dart';

class WarrantyCertificateModal extends StatelessWidget {
  final OrderItemModel order;

  const WarrantyCertificateModal({super.key, required this.order});

  static void show(BuildContext context, OrderItemModel order) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: WarrantyCertificateModal(order: order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(
          color: AppColors.customerPrimary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.syaanhOrange, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.verified_user, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'شهادة الضمان الذهبي والمقايسة المعتمدة (PDF)',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'رقم الوثيقة: ${order.warrantyNumber} • ضمان 30 يوماً + 10% كاش باك',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
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
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.syaanhOrange),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('رقم الطلب: #${order.id}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                        Chip(
                          label: Text(
                            order.isPaid ? 'مسدد وموثق ✅' : 'يستحق عند الإتمام',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: order.isPaid ? AppColors.success : AppColors.syaanhOrange,
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                    const Divider(),
                    Text('الخدمة المنفذة: ${order.serviceName}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('تفاصيل الإصلاح: ${order.description}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 6),
                    Text('العميل: ${order.customerName} (${order.customerPhone})', style: const TextStyle(fontSize: 12)),
                    Text('الفني المنفذ (موثق الهوية): ${order.technicianName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.customerPrimary)),
                    if (order.officialSparePartsUsed.isNotEmpty) ...[
                      const Divider(),
                      const Text('قطع الغيار الرسمية المركبة (من كتالوج المنصة):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ...order.officialSparePartsUsed.map((p) => Text('• $p', style: const TextStyle(fontSize: 11, color: AppColors.success))),
                    ],
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الكاش باك المكتسب: +${order.cashbackAmount} ج.م', style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.bold)),
                        Text('الإجمالي المعتمد: ${order.price} ج.م', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.syaanhOrange)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.camera_alt, color: AppColors.danger, size: 24),
                          const Text('صور قبل الصيانة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(order.beforePhotos.join('\n'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success, size: 24),
                          const Text('صور بعد الإصلاح', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(
                            order.afterPhotos.isEmpty ? 'بانتظار صورة الإتمام' : order.afterPhotos.join('\n'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.qr_code, size: 58, color: AppColors.customerPrimary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'وثيقة ضمان رسمية صادرة من منصة خدماتي • صيانة لمدة 30 يوماً على المصنعية وحتى 24 شهراً على قطع الغيار الرسمية.',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton.icon(
          icon: const Icon(Icons.copy, size: 16),
          label: const Text('نسخ الشهادة'),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: 'شهادة ضمان #${order.warrantyNumber} - طلب #${order.id}'));
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ بيانات شهادة الضمان إلى الحافظة')));
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf, size: 16),
          label: const Text('حفظ وطباعة PDF'),
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(backgroundColor: AppColors.success, content: Text('تم حفظ شهادة الضمان (${order.warrantyNumber}.pdf) بنجاح!')),
            );
          },
        ),
      ],
    );
  }
}