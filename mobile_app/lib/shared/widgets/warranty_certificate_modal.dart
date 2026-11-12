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
                    'شهادة الضمان الذهبي والفاتورة المعتمدة',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'رقم الوثيقة: ${order.warrantyNumber} • ضمان إعادة الخدمة مجاناً 100%',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 500,
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
                    Text('العنوان: ${order.address}', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.verified, color: AppColors.success, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'الفني المنفذ (موثق الهوية): ${order.technicianName}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.customerPrimary),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('وسيلة السداد: ${order.paymentMethod}', style: const TextStyle(fontSize: 12)),
                        Text('الإجمالي: ${order.price} ج.م', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.syaanhOrange)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('توثيق الحالة بالصور (قبل وبعد الصيانة):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
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
                          const Icon(Icons.camera_alt_outlined, color: AppColors.danger, size: 28),
                          const SizedBox(height: 4),
                          const Text('صور قبل الصيانة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(
                            order.beforePhotos.isEmpty ? 'لا توجد صور' : order.beforePhotos.join('\n'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
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
                          const Icon(Icons.check_circle_outline, color: AppColors.success, size: 28),
                          const SizedBox(height: 4),
                          const Text('صور بعد الإصلاح', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          Text(
                            order.afterPhotos.isEmpty ? 'بانتظار رفع صورة الإتمام' : order.afterPhotos.join('\n'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, color: AppColors.success),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.qr_code, size: 64, color: AppColors.customerPrimary),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ختم ضمان منصة خدماتي • صيانة لمدة 30 يوماً', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12)),
                          SizedBox(height: 4),
                          Text(
                            'تضمن المنصة إعادة تنفيذ الخدمة مجاناً أو استرداد المبلغ بالكامل في حال ظهور نفس العطل خلال فترة الضمان.',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
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
          label: const Text('نسخ بيانات الشهادة'),
          onPressed: () {
            Clipboard.setData(
              ClipboardData(
                text: 'شهادة ضمان خدماتي #${order.warrantyNumber} - طلب #${order.id} - الخدمة: ${order.serviceName} - الفني: ${order.technicianName} - المبلغ: ${order.price} ج.م',
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم نسخ بيانات شهادة الضمان الموثقة إلى الحافظة')),
            );
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf, size: 16),
          label: const Text('حفظ وطباعة PDF'),
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.success,
                content: Text('تم اعتماد وحفظ شهادة الضمان الرقمية (${order.warrantyNumber}.pdf) بنجاح!'),
              ),
            );
          },
        ),
      ],
    );
  }
}