import 'package:flutter/material.dart';
import '../../core/services/app_state_service.dart';
import '../../core/theme/theme.dart';

class SparePartsCatalogModal extends StatefulWidget {
  final String? orderIdForQuote;

  const SparePartsCatalogModal({super.key, this.orderIdForQuote});

  static void show(BuildContext context, {String? orderIdForQuote}) {
    showDialog(
      context: context,
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: SparePartsCatalogModal(orderIdForQuote: orderIdForQuote),
      ),
    );
  }

  @override
  State<SparePartsCatalogModal> createState() => _SparePartsCatalogModalState();
}

class _SparePartsCatalogModalState extends State<SparePartsCatalogModal> {
  String _selectedCat = 'الكل';

  @override
  Widget build(BuildContext context) {
    final state = AppStateService.instance;
    final cats = ['الكل', 'تكييف وتبريد', 'سباكة', 'كهرباء', 'أجهزة منزلية', 'نجارة وأقفال'];
    final parts = state.sparePartsCatalog.where((p) => _selectedCat == 'الكل' || p.category == _selectedCat).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: EdgeInsets.zero,
      title: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.customerPrimary,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          children: [
            const Icon(Icons.receipt_long, color: AppColors.syaanhOrange, size: 26),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('كتالوج أسعار قطع الغيار الرسمي المعتمد', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                  Text(
                    widget.orderIdForQuote != null
                        ? 'اختر القطعة لإضافتها للمقايسة الإلكترونية للطلب #${widget.orderIdForQuote} بالسعر الرسمي'
                        : 'أسعار موحدة ومعتمدة من الإدارة لمنع أي تلاعب أو مبالغة في أسعار القطع',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: cats.map((c) {
                  final sel = _selectedCat == c;
                  return ChoiceChip(
                    label: Text(c, style: TextStyle(fontSize: 11, color: sel ? Colors.white : AppColors.textPrimary)),
                    selected: sel,
                    selectedColor: AppColors.syaanhOrange,
                    onSelected: (_) => setState(() => _selectedCat = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              ...parts.map((p) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: ListTile(
                      dense: true,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFFFF7ED),
                        child: Icon(Icons.settings, color: AppColors.syaanhOrange, size: 18),
                      ),
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      subtitle: Text('الماركة: ${p.brand} | القسم: ${p.category} | ضمان القطعة: ${p.warrantyMonths} شهور', style: const TextStyle(fontSize: 11)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${p.officialPrice} ج.م', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.customerPrimary, fontSize: 14)),
                          if (widget.orderIdForQuote != null) ...[
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                              onPressed: () {
                                state.addOfficialSparePartToOrder(widget.orderIdForQuote!, p);
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.success,
                                    content: Text('تمت إضافة [${p.name}] بالسعر الرسمي (${p.officialPrice} ج.م) للمقايسة الإلكترونية!'),
                                  ),
                                );
                              },
                              child: const Text('إضافة للمقايسة', style: TextStyle(fontSize: 11)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  )),
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