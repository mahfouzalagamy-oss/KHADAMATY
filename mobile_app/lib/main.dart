import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:barcode_widget/barcode_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KhadamatyUltimateApp());
}

// ======================= إعدادات روابط الموقع الرسمي والتطبيق وخدمة العملاء =======================
class KhadamatyConfig {
  static const String appNameAr = 'خدماتي';
  static const String appNameEn = 'KHADAMATY';
  static String supportPhone = '01000000000';
  static String supportWhatsApp = '201000000000';
  static String supportEmail = 'support@khadamaty-eg.com';
  static String officialWebsiteUrl = 'https://mahfouzalagamy-oss.github.io/KHADAMATY/';
  static String appReleasesUrl = 'https://github.com/mahfouzalagamy-oss/KHADAMATY/actions';
  static bool dataSaverMode = true;
}

// ======================= ألوان وهوية البوابات الأربع =======================
enum PortalType { customer, technician, company, admin }

class PortalThemeConfig {
  final String title;
  final String badge;
  final Color primary;
  final Color lightTint;

  const PortalThemeConfig({
    required this.title,
    required this.badge,
    required this.primary,
    required this.lightTint,
  });

  static PortalThemeConfig of(PortalType type) {
    switch (type) {
      case PortalType.customer:
        return const PortalThemeConfig(
          title: 'بوابة العميل',
          badge: 'مجاناً + كاش باك',
          primary: Color(0xFF0E7470),
          lightTint: Color(0xFFE6F4F3),
        );
      case PortalType.technician:
        return const PortalThemeConfig(
          title: 'بوابة الفنيين',
          badge: 'شهر مجاني مفتوح',
          primary: Color(0xFF1D4ED8),
          lightTint: Color(0xFFDBEAFE),
        );
      case PortalType.company:
        return const PortalThemeConfig(
          title: 'بوابة الشركات B2B',
          badge: 'شهر مجاني للشركات',
          primary: Color(0xFFD97706),
          lightTint: Color(0xFFFEF3C7),
        );
      case PortalType.admin:
        return const PortalThemeConfig(
          title: 'إدارة KHADAMATY',
          badge: 'Super Admin',
          primary: Color(0xFF6D28D9),
          lightTint: Color(0xFFEDE9FE),
        );
    }
  }
}

// ======================= مشغل قنوات التواصل المباشر والروابط =======================
class KhadamatyLauncher {
  static Future<void> callPhone(BuildContext context, String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('الاتصال بالرقم: $phone')),
        );
      }
    }
  }

  static Future<void> openWhatsApp(BuildContext context, String phoneWithCountryCode, String message) async {
    final cleanPhone = phoneWithCountryCode.replaceAll(RegExp(r'[^0-9]'), '');
    final formattedPhone = cleanPhone.startsWith('0') ? '2$cleanPhone' : cleanPhone;
    final encodedMsg = Uri.encodeComponent(message);
    final Uri waUri = Uri.parse('https://wa.me/$formattedPhone?text=$encodedMsg');

    if (!await launchUrl(waUri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فتح واتساب: $formattedPhone')),
        );
      }
    }
  }

  static Future<void> shareKhadamatyOnWhatsApp(BuildContext context, String referralCode) async {
    final shareText =
        '📲 *جرّب منصة خدماتي (KHADAMATY) لصيانة المنازل والشركات في مصر*\n'
        '🌐 تعمل مباشرة من أي موبايل (أندرويد أو آيفون) بدون تثبيت عبر الموقع الرسمي:\n'
        '${KhadamatyConfig.officialWebsiteUrl}\n'
        '🎁 كود الدعوة ($referralCode) يمنحك 50 ج.م كاش باك فوري + كود أمان لدخول المنزل + فاتورة ضمان بـ QR Code!';
    final Uri waShare = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(shareText)}');
    await launchUrl(waShare, mode: LaunchMode.externalApplication);
  }

  static Future<void> sendEmail(BuildContext context, String email, String subject, String body) async {
    final Uri mailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );
    await launchUrl(mailUri);
  }
}

// ======================= نموذج ومحرك الفاتورة وشهادة الضمان PDF المزودة بـ QR Code =======================
class ElectronicWarrantyInvoiceModel {
  final String invoiceNumber;
  final String issueDate;
  final String warrantyEndDate;
  final String warrantyPeriodText;
  final String safeEntryPin;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String providerName;
  final String providerRole;
  final String providerPhone;
  final String serviceTitle;
  final String workDescription;
  final double totalAmountEgp;

  ElectronicWarrantyInvoiceModel({
    required this.invoiceNumber,
    required this.issueDate,
    required this.warrantyEndDate,
    required this.warrantyPeriodText,
    required this.safeEntryPin,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.providerName,
    required this.providerRole,
    required this.providerPhone,
    required this.serviceTitle,
    required this.workDescription,
    required this.totalAmountEgp,
  });

  String get qrVerificationPayload =>
      'KHADAMATY-WARRANTY|INV:$invoiceNumber|PIN:$safeEntryPin|VALID_TO:$warrantyEndDate|EGP:${totalAmountEgp.toInt()}|PROVIDER:$providerPhone|WEB:${KhadamatyConfig.officialWebsiteUrl}';
}

class PdfWarrantyService {
  static Future<Uint8List> generateInvoicePdfBytes(ElectronicWarrantyInvoiceModel inv) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(26),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.teal800, width: 2),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(12)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('KHADAMATY EGYPT PLATFORM',
                            style: pw.TextStyle(fontSize: 21, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                        pw.Text('Official Electronic Maintenance Invoice & QR Warranty Certificate',
                            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                        pw.SizedBox(height: 6),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: const pw.BoxDecoration(
                            color: PdfColors.amber100,
                            borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
                          ),
                          child: pw.Text('WARRANTY #${inv.invoiceNumber}  |  SAFE PIN: ${inv.safeEntryPin}',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                        ),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: inv.qrVerificationPayload,
                          width: 75,
                          height: 75,
                          color: PdfColors.teal900,
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Scan to Verify Warranty', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                      ],
                    ),
                  ],
                ),
                pw.Divider(height: 24, thickness: 1.5, color: PdfColors.teal800),
                pw.Text('1. Service & Customer Verification:',
                    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                pw.SizedBox(height: 6),
                pw.Text('Issue Date: ${inv.issueDate}   |   Warranty Valid Until: ${inv.warrantyEndDate}'),
                pw.Text('Customer Phone: ${inv.customerPhone}   |   Safe Home Entry PIN: ${inv.safeEntryPin}'),
                pw.SizedBox(height: 14),
                pw.Text('2. Certified Provider Information:',
                    style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                pw.SizedBox(height: 6),
                pw.Text('Provider Phone / WhatsApp: ${inv.providerPhone}'),
                pw.Text('Verification Status: KYC ID VERIFIED & GUARANTEED BY KHADAMATY'),
                pw.SizedBox(height: 18),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(14),
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.teal50,
                    borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Total Paid Amount (EGP):',
                          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                      pw.Text('${inv.totalAmountEgp.toStringAsFixed(0)} EGP',
                          style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.teal900)),
                    ],
                  ),
                ),
                pw.Spacer(),
                pw.Divider(color: PdfColors.grey400),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Open KHADAMATY on Any Phone (Android, iPhone, Web)',
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11, color: PdfColors.teal900)),
                          pw.Text('Website: ${KhadamatyConfig.officialWebsiteUrl}',
                              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                          pw.Text('24/7 Support: ${KhadamatyConfig.supportPhone} | ${KhadamatyConfig.supportEmail}',
                              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                        ],
                      ),
                    ),
                    pw.SizedBox(width: 12),
                    pw.Column(
                      children: [
                        pw.BarcodeWidget(
                          barcode: pw.Barcode.qrCode(),
                          data: KhadamatyConfig.officialWebsiteUrl,
                          width: 55,
                          height: 55,
                        ),
                        pw.Text('Scan Web/App', style: const pw.TextStyle(fontSize: 7)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}

class KhadamatyUltimateApp extends StatefulWidget {
  const KhadamatyUltimateApp({super.key});

  @override
  State<KhadamatyUltimateApp> createState() => _KhadamatyUltimateAppState();
}

class _KhadamatyUltimateAppState extends State<KhadamatyUltimateApp> {
  PortalType currentPortal = PortalType.customer;

  @override
  Widget build(BuildContext context) {
    final pTheme = PortalThemeConfig.of(currentPortal);

    return MaterialApp(
      title: 'خدماتي KHADAMATY',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F9FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: pTheme.primary,
          primary: pTheme.primary,
          secondary: const Color(0xFFF59E0B),
        ),
      ),
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(minScaleFactor: 0.9, maxScaleFactor: 1.1),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            // توسيط العرض تلقائياً إذا فُتح الموقع على شاشة كمبيوتر عريضة، وملء الشاشة على الموبايل
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: child!,
              ),
            ),
          ),
        );
      },
      home: KhadamatyMainWorkspace(
        currentPortal: currentPortal,
        onPortalChanged: (p) => setState(() => currentPortal = p),
      ),
    );
  }
}

// ======================= نماذج البيانات =======================
class ServiceItem {
  final String name;
  final IconData icon;
  final Color iconColor;
  final String fairPriceRangeEgp;
  final List<String> commonProblems;

  const ServiceItem({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.fairPriceRangeEgp,
    required this.commonProblems,
  });
}

class ChatMessageModel {
  final String senderName;
  final bool isMe;
  final String text;
  final String time;
  final ElectronicWarrantyInvoiceModel? attachedInvoice;

  ChatMessageModel({
    required this.senderName,
    required this.isMe,
    required this.text,
    required this.time,
    this.attachedInvoice,
  });
}

class OfferBid {
  final String providerName;
  final String providerRole;
  final bool isKycVerified;
  final String phone;
  final String whatsapp;
  final String email;
  final double priceEgp;
  final String appointment;
  final String warrantyDaysText;
  int points;
  int jobsCount;
  final double rating;
  final List<String> reviews;

  OfferBid({
    required this.providerName,
    required this.providerRole,
    this.isKycVerified = true,
    required this.phone,
    required this.whatsapp,
    required this.email,
    required this.priceEgp,
    required this.appointment,
    this.warrantyDaysText = 'ضمان 30 يوماً شامل (بشهادة QR)',
    required this.points,
    required this.jobsCount,
    required this.rating,
    required this.reviews,
  });
}

class CustomerRequestModel {
  String id;
  String serviceName;
  String selectedProblem;
  String extraDetails;
  String governorateAndCity;
  String district;
  String streetAndBuilding;
  String floorAndApt;
  String landmark;
  String appointmentType;
  String preferredDateText;
  String customerPhone;
  String safeEntryPin;
  bool isEmergencySos;
  String status;
  List<OfferBid> bids;
  OfferBid? acceptedBid;
  ElectronicWarrantyInvoiceModel? issuedWarrantyInvoice;

  CustomerRequestModel({
    required this.id,
    required this.serviceName,
    required this.selectedProblem,
    required this.extraDetails,
    required this.governorateAndCity,
    required this.district,
    required this.streetAndBuilding,
    required this.floorAndApt,
    required this.landmark,
    required this.appointmentType,
    required this.preferredDateText,
    required this.customerPhone,
    this.safeEntryPin = '4829',
    this.isEmergencySos = false,
    this.status = 'بانتظار اختيار العرض',
    required this.bids,
    this.acceptedBid,
    this.issuedWarrantyInvoice,
  });
}

// ======================= الشاشة الرئيسية والهيكل العام لمنصة KHADAMATY =======================
class KhadamatyMainWorkspace extends StatefulWidget {
  final PortalType currentPortal;
  final ValueChanged<PortalType> onPortalChanged;

  const KhadamatyMainWorkspace({
    super.key,
    required this.currentPortal,
    required this.onPortalChanged,
  });

  @override
  State<KhadamatyMainWorkspace> createState() => _KhadamatyMainWorkspaceState();
}

class _KhadamatyMainWorkspaceState extends State<KhadamatyMainWorkspace> {
  int _bottomNavIndex = 0;
  int _chatSubTabIndex = 0;
  String selectedCityHeader = 'المنصورة، الدقهلية';
  double customerCashbackWalletEgp = 100.0;
  String userReferralCode = 'KHD-EG-2026';

  final List<String> egyptCitiesList = [
    'المنصورة، الدقهلية',
    'مدينة نصر، القاهرة',
    'المعادي، القاهرة',
    'التجمع الخامس، القاهرة',
    'المهندسين، الجيزة',
    '6 أكتوبر، الجيزة',
    'سموحة، الإسكندرية',
    'طنطا، الغربية',
    'الزقازيق، الشرقية',
    'بنها، القليوبية',
  ];

  final List<ServiceItem> khadamatyServices = const [
    ServiceItem(
      name: 'تكييف',
      icon: Icons.ac_unit_rounded,
      iconColor: Color(0xFF0284C7),
      fairPriceRangeEgp: 'السعر الاسترشادي العادل: 200 - 350 ج.م',
      commonProblems: ['مش بيبرد', 'تسريب مياه', 'صوت غير طبيعي', 'مشكلة أخرى'],
    ),
    ServiceItem(
      name: 'سباكة',
      icon: Icons.plumbing_rounded,
      iconColor: Color(0xFF0E7470),
      fairPriceRangeEgp: 'السعر الاسترشادي العادل: 150 - 300 ج.م',
      commonProblems: ['تسريب مياه', 'انسداد صرف', 'تركيب خلاط/سخان', 'مشكلة أخرى'],
    ),
    ServiceItem(
      name: 'كهرباء',
      icon: Icons.bolt_rounded,
      iconColor: Color(0xFFF59E0B),
      fairPriceRangeEgp: 'السعر الاسترشادي العادل: 150 - 280 ج.م',
      commonProblems: ['انقطاع تيار/قفلة', 'تركيب إضاءة ونجف', 'تغيير مفاتيح وبرايز', 'مشكلة أخرى'],
    ),
    ServiceItem(
      name: 'أجهزة منزلية',
      icon: Icons.local_laundry_service_rounded,
      iconColor: Color(0xFF3B82F6),
      fairPriceRangeEgp: 'السعر الاسترشادي العادل: 200 - 400 ج.م',
      commonProblems: ['غسالة لا تعمل', 'ثلاجة لا تبرد', 'صيانة بوتاجاز/سخان', 'مشكلة أخرى'],
    ),
    ServiceItem(
      name: 'نجارة',
      icon: Icons.handyman_rounded,
      iconColor: Color(0xFFD97706),
      fairPriceRangeEgp: 'السعر الاسترشادي العادل: 150 - 350 ج.م',
      commonProblems: ['إصلاح باب/شباك', 'فك وتركيب أثاث', 'تغيير كالون/مفصلات', 'مشكلة أخرى'],
    ),
    ServiceItem(
      name: 'نظافة',
      icon: Icons.cleaning_services_rounded,
      iconColor: Color(0xFF10B981),
      fairPriceRangeEgp: 'السعر الاسترشادي العادل: 300 - 600 ج.م',
      commonProblems: ['نظافة شاملة للمنزل', 'تنظيف بعد التشطيب', 'تنظيف مفروشات وسجاد', 'مشكلة أخرى'],
    ),
    ServiceItem(
      name: 'نقاشة ودهانات',
      icon: Icons.format_paint_rounded,
      iconColor: Color(0xFFEC4899),
      fairPriceRangeEgp: 'السعر الاسترشادي العادل: حسب المعاينة بالمتر',
      commonProblems: ['دهان غرفة/شقة', 'معالجة رطوبة وشروخ', 'تركيب ورق حائط', 'مشكلة أخرى'],
    ),
    ServiceItem(
      name: 'عقود شركات B2B',
      icon: Icons.business_center_rounded,
      iconColor: Color(0xFF6366F1),
      fairPriceRangeEgp: 'باقات صيانة شهرية وسنوية للمحلات والشركات',
      commonProblems: ['عقد صيانة سنوي شامل', 'صيانة دورية للمكاتب والعيادات', 'تأسيس صيانة فروع تجارية', 'طلب معاينة شركة'],
    ),
  ];

  final List<ChatMessageModel> providerChatMessages = [
    ChatMessageModel(
      senderName: 'شركة الدلتا الهندسية للتكييف',
      isMe: false,
      text: 'مرحباً بحضرتك في منصة خدماتي (KHADAMATY)، الفني في طريقه إليك ومعه كود الأمان لدخول المنزل، وستصلك شهادة الضمان بـ QR Code فور الانتهاء.',
      time: '3:40 م',
    ),
  ];

  final List<ChatMessageModel> customerSupportMessages = [
    ChatMessageModel(
      senderName: 'خدمة عملاء KHADAMATY',
      isMe: false,
      text: 'أهلاً بك في خدمة عملاء منصة خدماتي (KHADAMATY)! يمكنك مراسلتنا هنا أو تحويل المحادثة فوراً لواتساب الإدارة.',
      time: 'الآن',
    ),
  ];

  final TextEditingController chatInputCtrl = TextEditingController();
  late List<CustomerRequestModel> allOrders;

  @override
  void initState() {
    super.initState();
    final sampleInvoice = ElectronicWarrantyInvoiceModel(
      invoiceNumber: 'KHD-2026-901',
      issueDate: '2026-11-09',
      warrantyEndDate: '2026-12-09',
      warrantyPeriodText: 'ضمان شامل 30 يوماً',
      safeEntryPin: '4829',
      customerName: 'عميل خدماتي - المنصورة',
      customerPhone: '01012345678',
      customerAddress: 'المنصورة، حي الجامعة، شارع الجمهورية عمارة 12',
      providerName: 'شركة الدلتا الهندسية للتكييف',
      providerRole: 'شركة صيانة معتمدة (موثقة بالسجل التجاري)',
      providerPhone: '01099887766',
      serviceTitle: 'صيانة تكييف - علاج ضعف التبريد وشحن فريون',
      workDescription: 'غسيل كامل للوحدة الداخلية والخارجية + ضبط ضغط الفريون وفحص الكباس.',
      totalAmountEgp: 300.0,
    );

    allOrders = [
      CustomerRequestModel(
        id: 'REQ-101',
        serviceName: 'صيانة تكييف',
        selectedProblem: 'مش بيبرد (ضعف التبريد)',
        extraDetails: 'التكييف شغال لكن التبريد ضعيف',
        governorateAndCity: 'المنصورة، الدقهلية',
        district: 'حي الجامعة',
        streetAndBuilding: 'شارع الجمهورية، عمارة 12',
        floorAndApt: 'الدور الثالث، شقة 5',
        landmark: 'بجوار جامعة المنصورة',
        appointmentType: 'اختيار موعد',
        preferredDateText: 'الثلاثاء، 4:00 عصراً',
        customerPhone: '01012345678',
        safeEntryPin: '4829',
        issuedWarrantyInvoice: sampleInvoice,
        bids: [
          OfferBid(
            providerName: 'شركة الدلتا الهندسية للتكييف',
            providerRole: 'شركة معتمدة (موثقة بالسجل التجاري)',
            isKycVerified: true,
            phone: '01099887766',
            whatsapp: '201099887766',
            email: 'delta.ac@khadamaty-eg.com',
            priceEgp: 300,
            appointment: 'الثلاثاء، 4:00 عصراً',
            warrantyDaysText: 'ضمان شركة مختوم 30 يوماً (QR + PDF)',
            points: 1950,
            jobsCount: 142,
            rating: 4.9,
            reviews: ['التزام ممتاز بالمواعيد واستلمت فاتورة ضمان بـ QR Code وكود أمان.'],
          ),
          OfferBid(
            providerName: 'م. عمرو الشربيني',
            providerRole: 'فني محترف (موثق بالبطاقة والفيش)',
            isKycVerified: true,
            phone: '01122334455',
            whatsapp: '201122334455',
            email: 'amr.tech@khadamaty-eg.com',
            priceEgp: 250,
            appointment: 'الثلاثاء، 5:00 مساءً',
            warrantyDaysText: 'ضمان 15 يوماً (شهادة إلكترونية)',
            points: 1340,
            jobsCount: 89,
            rating: 4.8,
            reviews: ['أمين جداً وسعره مطابق للسعر الاسترشادي العادل.'],
          ),
        ],
      ),
    ];
  }

  // ======================= نافذة QR Code للموقع الرسمي والتطبيق وكسب الكاش باك =======================
  void _showShareAppQrCodeModal(PortalThemeConfig pTheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2_rounded, color: pTheme.primary, size: 30),
                const SizedBox(width: 8),
                const Text(
                  'مشاركة موقع وتطبيق خدماتي KHADAMATY',
                  style: TextStyle(fontSize: 17.5, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'امسح الرمز بكاميرا أي هاتف (آيفون أو أندرويد) لفتح الموقع الرسمي فوراً بدون تثبيت أو لتحميل التطبيق، واكسب 50 ج.م كاش باك!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: pTheme.primary, width: 2.5),
              ),
              child: Column(
                children: [
                  BarcodeWidget(
                    barcode: Barcode.qrCode(),
                    data: KhadamatyConfig.officialWebsiteUrl,
                    width: 175,
                    height: 175,
                    color: pTheme.primary,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: pTheme.lightTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'كود الدعوة: $userReferralCode',
                      style: TextStyle(fontWeight: FontWeight.bold, color: pTheme.primary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  setState(() => customerCashbackWalletEgp += 50.0);
                  Navigator.pop(ctx);
                  KhadamatyLauncher.shareKhadamatyOnWhatsApp(context, userReferralCode);
                },
                icon: const Icon(Icons.share_rounded),
                label: const Text('إرسال عبر واتساب وإضافة +50 ج.م للمحفظة',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ======================= نافذة الفاتورة وشهادة الضمان المزودة بـ QR Code وكود الأمان =======================
  void _openElectronicWarrantyCertificateModal(ElectronicWarrantyInvoiceModel inv, PortalThemeConfig pTheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.only(top: 36),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: pTheme.lightTint,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: pTheme.primary, width: 1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.verified_rounded, color: pTheme.primary, size: 26),
                              const SizedBox(width: 6),
                              const Expanded(
                                child: Text(
                                  'شهادة ضمان وفاتورة KHADAMATY',
                                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('رقم الشهادة: #${inv.invoiceNumber}',
                              style: TextStyle(fontWeight: FontWeight.bold, color: pTheme.primary)),
                          Text('كود الأمان لدخول المنزل (PIN): ${inv.safeEntryPin}',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                          Text('ساري الضمان حتى: ${inv.warrantyEndDate}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: pTheme.primary),
                      ),
                      child: Column(
                        children: [
                          BarcodeWidget(
                            barcode: Barcode.qrCode(),
                            data: inv.qrVerificationPayload,
                            width: 72,
                            height: 72,
                            color: pTheme.primary,
                          ),
                          const SizedBox(height: 2),
                          const Text('امسح للتحقق', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildInvoiceLine('الخدمة المنفذة:', inv.serviceTitle),
              _buildInvoiceLine('تفاصيل الإصلاح:', inv.workDescription),
              _buildInvoiceLine('مقدم الخدمة الموثق:', '${inv.providerName} (${inv.providerRole})'),
              _buildInvoiceLine('هاتف مقدم الخدمة:', inv.providerPhone),
              _buildInvoiceLine('عنوان العميل:', inv.customerAddress),
              _buildInvoiceLine('مدة الضمان المعتمد:', inv.warrantyPeriodText),
              const Divider(height: 22),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('إجمالي قيمة الفاتورة (شامل الضمان):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5)),
                    Text(
                      '${inv.totalAmountEgp.toInt()} ج.م',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: pTheme.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: pTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    final bytes = await PdfWarrantyService.generateInvoicePdfBytes(inv);
                    await Printing.layoutPdf(
                      onLayout: (_) async => bytes,
                      name: 'KHADAMATY_Warranty_${inv.invoiceNumber}.pdf',
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('حفظ / طباعة الفاتورة وشهادة الضمان (PDF بـ QR Code)'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceLine(String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 125,
            child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12.5, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
          ),
        ],
      ),
    );
  }

  void _open3StepServiceWizard(ServiceItem service, {bool isEmergencySos = false}) async {
    final createdOrder = await Navigator.push<CustomerRequestModel>(
      context,
      MaterialPageRoute(
        builder: (_) => Khadamaty3StepWizardScreen(
          service: service,
          initialCity: selectedCityHeader,
          themeConfig: PortalThemeConfig.of(widget.currentPortal),
          isEmergencySos: isEmergencySos,
        ),
      ),
    );

    if (createdOrder != null) {
      setState(() {
        allOrders.insert(0, createdOrder);
        _bottomNavIndex = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pTheme = PortalThemeConfig.of(widget.currentPortal);

    final pages = [
      _buildKhadamatyHomeScreen(pTheme),
      _buildMyOrdersAndWarrantyTab(pTheme),
      _buildDualChatAndSupportCenterTab(pTheme),
      _buildWalletPassportAndQrTab(pTheme),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_bottomNavIndex]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
        ),
        child: NavigationBar(
          height: 70,
          backgroundColor: Colors.white,
          indicatorColor: pTheme.lightTint,
          selectedIndex: _bottomNavIndex,
          onDestinationSelected: (idx) => setState(() => _bottomNavIndex = idx),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: pTheme.primary),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Badge(
                label: Text('${allOrders.length}'),
                child: const Icon(Icons.verified_outlined),
              ),
              selectedIcon: Icon(Icons.verified_rounded, color: pTheme.primary),
              label: 'طلباتي والضمان',
            ),
            NavigationDestination(
              icon: const Badge(
                label: Text('حي'),
                backgroundColor: Color(0xFF16A34A),
                child: Icon(Icons.chat_bubble_outline_rounded),
              ),
              selectedIcon: Icon(Icons.chat_bubble_rounded, color: pTheme.primary),
              label: 'الرسائل والدعم',
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: pTheme.primary),
              label: 'محفظتي و QR',
            ),
          ],
        ),
      ),
    );
  }

  // ======================= 1. الشاشة الرئيسية لمنصة خدماتي KHADAMATY =======================
  Widget _buildKhadamatyHomeScreen(PortalThemeConfig pTheme) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int gridCols = constraints.maxWidth > 500 ? 4 : 3;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // شريط البوابات الأربع
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: PortalType.values.map((type) {
                    final cfg = PortalThemeConfig.of(type);
                    final isSelected = widget.currentPortal == type;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ChoiceChip(
                        selected: isSelected,
                        selectedColor: cfg.primary,
                        backgroundColor: Colors.white,
                        label: Text(
                          cfg.title,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        onSelected: (_) => widget.onPortalChanged(type),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),

              // الهيدر العلوي بالاسم الجديد "خدماتي KHADAMATY"
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                        ),
                        child: const Icon(Icons.home_work_rounded, color: Color(0xFFF59E0B), size: 26),
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('خدماتي',
                              style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, height: 1.0, color: Color(0xFF0F172A))),
                          Text('KHADAMATY',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Color(0xFF64748B))),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _bottomNavIndex = 3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFF59E0B)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.stars_rounded, color: Color(0xFFD97706), size: 16),
                              const SizedBox(width: 4),
                              Text('${customerCashbackWalletEgp.toInt()} ج.م',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF92400E))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isDense: true,
                            value: selectedCityHeader,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16),
                            items: egyptCitiesList
                                .map((c) => DropdownMenuItem(
                                      value: c,
                                      child: Text(c.split('،').first, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    ))
                                .toList(),
                            onChanged: (val) => setState(() => selectedCityHeader = val!),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton.filledTonal(
                        tooltip: 'مشاركة QR الموقع والتطبيق',
                        onPressed: () => _showShareAppQrCodeModal(pTheme),
                        icon: Icon(Icons.qr_code_2_rounded, color: pTheme.primary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // شريط المميزات السريعة (طوارئ 45 دقيقة SOS - QR الموقع والتطبيق - واتساب - موبايل - شهادة الضمان)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickChannelButton(
                      icon: Icons.emergency_share_rounded,
                      label: 'طوارئ 45 د',
                      color: const Color(0xFFDC2626),
                      onTap: () => _open3StepServiceWizard(khadamatyServices.first, isEmergencySos: true),
                    ),
                    _buildQuickChannelButton(
                      icon: Icons.qr_code_scanner_rounded,
                      label: 'QR التطبيق',
                      color: pTheme.primary,
                      onTap: () => _showShareAppQrCodeModal(pTheme),
                    ),
                    _buildQuickChannelButton(
                      icon: Icons.phone_enabled_rounded,
                      label: 'موبايل',
                      color: const Color(0xFF0284C7),
                      onTap: () => KhadamatyLauncher.callPhone(context, KhadamatyConfig.supportPhone),
                    ),
                    _buildQuickChannelButton(
                      icon: Icons.message_rounded,
                      label: 'واتساب',
                      color: const Color(0xFF16A34A),
                      onTap: () => KhadamatyLauncher.openWhatsApp(
                        context,
                        KhadamatyConfig.supportWhatsApp,
                        'مرحباً خدمة عملاء تطبيق خدماتي KHADAMATY...',
                      ),
                    ),
                    _buildQuickChannelButton(
                      icon: Icons.verified_user_rounded,
                      label: 'ضمان QR',
                      color: const Color(0xFF7C3AED),
                      onTap: () => _openElectronicWarrantyCertificateModal(
                        allOrders.first.issuedWarrantyInvoice!,
                        pTheme,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              const Center(
                child: Column(
                  children: [
                    Text(
                      'محتاج خدمة إيه؟',
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'يعمل على الأندرويد والآيفون والموقع الإلكتروني • بكود أمان وضمان QR',
                      style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _open3StepServiceWizard(khadamatyServices.first),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [pTheme.primary, pTheme.primary.withOpacity(0.84)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.mic_external_on_rounded, color: Color(0xFFFDE68A), size: 28),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('مش عارف تختار؟ (تشخيص صوتي/فيديو)',
                                style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.bold)),
                            SizedBox(height: 3),
                            Text('صف المشكلة بصوتك أو فيديو قصير واعرف السعر الاسترشادي العادل فوراً',
                                style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              const Text('الخدمات المعتمدة في خدماتي', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: khadamatyServices.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridCols,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 122,
                ),
                itemBuilder: (context, index) {
                  final srv = khadamatyServices[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _open3StepServiceWizard(srv),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: srv.iconColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(srv.icon, color: srv.iconColor, size: 30),
                          ),
                          const SizedBox(height: 8),
                          Text(srv.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickChannelButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 19),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ======================= 2. تبويب الطلبات وكود الأمان لدخول المنزل والضمان =======================
  Widget _buildMyOrdersAndWarrantyTab(PortalThemeConfig pTheme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allOrders.length,
      itemBuilder: (context, index) {
        final ord = allOrders[index];
        ord.bids.sort((a, b) => b.points.compareTo(a.points));

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('${ord.serviceName} (${ord.selectedProblem})',
                        style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: ord.isEmergencySos ? const Color(0xFFFEE2E2) : pTheme.lightTint,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ord.isEmergencySos ? '🚨 طوارئ 45 دقيقة' : ord.status,
                      style: TextStyle(
                        color: ord.isEmergencySos ? Colors.red.shade800 : pTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('📍 ${ord.governorateAndCity} - ${ord.district} (${ord.streetAndBuilding})'),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF16A34A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_person_rounded, color: Color(0xFF16A34A), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'كود أمان دخول المنزل (أعطه للفني عند وصوله): ${ord.safeEntryPin}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF166534)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              if (ord.issuedWarrantyInvoice != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code_2_rounded, color: Color(0xFFD97706), size: 34),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('شهادة ضمان KHADAMATY #${ord.issuedWarrantyInvoice!.invoiceNumber}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            Text('سارية حتى: ${ord.issuedWarrantyInvoice!.warrantyEndDate}',
                                style: const TextStyle(fontSize: 12, color: Colors.black54)),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: pTheme.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(95, 38),
                        ),
                        onPressed: () => _openElectronicWarrantyCertificateModal(ord.issuedWarrantyInvoice!, pTheme),
                        icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                        label: const Text('شهادة QR', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ),

              const Divider(height: 20),
              Text('عروض الأسعار المقدمة (${ord.bids.length}) من الفنيين والشركات الموثقة:',
                  style: TextStyle(fontWeight: FontWeight.bold, color: pTheme.primary)),
              const SizedBox(height: 10),

              ...ord.bids.map((bid) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                if (bid.isKycVerified)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Icon(Icons.verified_rounded, color: Color(0xFF0284C7), size: 18),
                                  ),
                                Expanded(
                                  child: Text(bid.providerName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                ),
                              ],
                            ),
                          ),
                          Text('${bid.priceEgp.toInt()} ج.م',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: pTheme.primary)),
                        ],
                      ),
                      Text('${bid.providerRole} • 🏆 ${bid.points} نقطة • نفذ ${bid.jobsCount} خدمة • ⭐ ${bid.rating}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                      Text('🛡️ ${bid.warrantyDaysText}',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0E7470))),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pTheme.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 44),
                          ),
                          onPressed: () {
                            final newInv = ElectronicWarrantyInvoiceModel(
                              invoiceNumber: 'KHD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              issueDate: '2026-11-09',
                              warrantyEndDate: '2026-12-09',
                              warrantyPeriodText: bid.warrantyDaysText,
                              safeEntryPin: ord.safeEntryPin,
                              customerName: 'عميل خدماتي',
                              customerPhone: ord.customerPhone,
                              customerAddress: '${ord.governorateAndCity} - ${ord.district} (${ord.streetAndBuilding})',
                              providerName: bid.providerName,
                              providerRole: bid.providerRole,
                              providerPhone: bid.phone,
                              serviceTitle: '${ord.serviceName} (${ord.selectedProblem})',
                              workDescription: ord.extraDetails,
                              totalAmountEgp: bid.priceEgp,
                            );
                            setState(() {
                              ord.acceptedBid = bid;
                              ord.issuedWarrantyInvoice = newInv;
                              ord.status = 'تم إصدار ضمان QR';
                              bid.points += 50;
                              bid.jobsCount += 1;
                            });
                            _openElectronicWarrantyCertificateModal(newInv, pTheme);
                          },
                          icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                          label: const Text('قبول العرض وإصدار شهادة الضمان وكود الأمان'),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // ======================= 3. مركز المحادثات المزدوج =======================
  Widget _buildDualChatAndSupportCenterTab(PortalThemeConfig pTheme) {
    final bool isSupportChat = _chatSubTabIndex == 1;
    final List<ChatMessageModel> activeMessages = isSupportChat ? customerSupportMessages : providerChatMessages;

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _chatSubTabIndex = 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !isSupportChat ? pTheme.primary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'شات الفني / الشركة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: !isSupportChat ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _chatSubTabIndex = 1),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSupportChat ? pTheme.primary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'خدمة عملاء KHADAMATY',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSupportChat ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: activeMessages.length,
            itemBuilder: (ctx, idx) {
              final msg = activeMessages[idx];
              return Align(
                alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  constraints: const BoxConstraints(maxWidth: 300),
                  decoration: BoxDecoration(
                    color: msg.isMe ? pTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: msg.isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(color: msg.isMe ? Colors.white : Colors.black87, fontSize: 14),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ======================= 4. تبويب محفظة الكاش باك + جواز صيانة المنزل الرقمي + بطاقة QR =======================
  Widget _buildWalletPassportAndQrTab(PortalThemeConfig pTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [pTheme.primary, const Color(0xFF0F172A)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('محفظة كاش باك خدماتي (KHADAMATY Wallet)',
                    style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 6),
                Text('${customerCashbackWalletEgp.toInt()} جنيه مصري',
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                const Text(
                  'شارك QR الموقع أو التطبيق مع أصدقائك أو جيرانك واحصل على +50 ج.م رصيد مجاني لكل صديق!',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: pTheme.primary, width: 2),
            ),
            child: Column(
              children: [
                Text(
                  'بطاقة QR للموقع الرسمي وتطبيق KHADAMATY',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: pTheme.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  KhadamatyConfig.officialWebsiteUrl,
                  style: const TextStyle(fontSize: 11.5, color: Colors.black54),
                ),
                const SizedBox(height: 12),
                BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: KhadamatyConfig.officialWebsiteUrl,
                  width: 165,
                  height: 165,
                  color: pTheme.primary,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () {
                      setState(() => customerCashbackWalletEgp += 50.0);
                      KhadamatyLauncher.shareKhadamatyOnWhatsApp(context, userReferralCode);
                    },
                    icon: const Icon(Icons.share_rounded),
                    label: const Text('إرسال للأصدقاء عبر واتساب (+50 ج.م كاش باك)'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ======================= رحلة طلب الخدمة ذات الـ 3 خطوات المطابقة للصورة + مؤشر السعر العادل =======================
class Khadamaty3StepWizardScreen extends StatefulWidget {
  final ServiceItem service;
  final String initialCity;
  final PortalThemeConfig themeConfig;
  final bool isEmergencySos;

  const Khadamaty3StepWizardScreen({
    super.key,
    required this.service,
    required this.initialCity,
    required this.themeConfig,
    this.isEmergencySos = false,
  });

  @override
  State<Khadamaty3StepWizardScreen> createState() => _Khadamaty3StepWizardScreenState();
}

class _Khadamaty3StepWizardScreenState extends State<Khadamaty3StepWizardScreen> {
  int currentStep = 1;
  late String selectedProblemChip;
  final TextEditingController extraDetailsCtrl = TextEditingController(text: 'التكييف شغال لكن التبريد ضعيف');
  bool recordedVoiceDiagnosis = false;
  late String selectedCityLocation;
  final TextEditingController districtCtrl = TextEditingController(text: 'حي الجامعة');
  final TextEditingController streetBuildingCtrl = TextEditingController(text: 'شارع الجمهورية، عمارة 12');
  final TextEditingController floorAptCtrl = TextEditingController(text: 'الدور الثالث، شقة 5');
  final TextEditingController landmarkCtrl = TextEditingController(text: 'بجوار جامعة المنصورة');
  String preferredAppointmentSlot = 'الثلاثاء، 28 يناير – 4:00 عصراً';
  final TextEditingController customerPhoneCtrl = TextEditingController(text: '01012345678');

  @override
  void initState() {
    super.initState();
    selectedProblemChip = widget.service.commonProblems.first;
    selectedCityLocation = widget.initialCity;
    if (widget.isEmergencySos) {
      preferredAppointmentSlot = 'طوارئ فورية خلال 45 دقيقة (SOS)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = widget.themeConfig.primary;
    final lightTint = widget.themeConfig.lightTint;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () {
            if (currentStep > 1) {
              setState(() => currentStep -= 1);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          widget.isEmergencySos ? '🚨 طوارئ ${widget.service.name} (45 دقيقة)' : 'طلب صيانة ${widget.service.name}',
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(child: Text('$currentStep / 3', style: const TextStyle(fontWeight: FontWeight.bold))),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
            child: Row(
              children: [
                _buildStepCircle(1, 'التفاصيل', primary),
                Expanded(child: Container(height: 2, color: currentStep >= 2 ? primary : const Color(0xFFCBD5E1))),
                _buildStepCircle(2, 'المكان والموعد', primary),
                Expanded(child: Container(height: 2, color: currentStep >= 3 ? primary : const Color(0xFFCBD5E1))),
                _buildStepCircle(3, 'المراجعة', primary),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: currentStep == 1
                  ? _buildStep1(primary, lightTint)
                  : currentStep == 2
                      ? _buildStep2(primary, lightTint)
                      : _buildStep3(primary, lightTint),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int stepNumber, String label, Color primary) {
    final bool isActive = currentStep >= stepNumber;
    return Column(
      children: [
        CircleAvatar(
          radius: 15,
          backgroundColor: isActive ? primary : const Color(0xFFE2E8F0),
          foregroundColor: isActive ? Colors.white : const Color(0xFF64748B),
          child: Text('$stepNumber', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      ],
    );
  }

  Widget _buildStep1(Color primary, Color lightTint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFF59E0B)),
          ),
          child: Row(
            children: [
              const Icon(Icons.price_check_rounded, color: Color(0xFFD97706)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.service.fairPriceRangeEgp,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        const Text('إيه المشكلة؟', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.service.commonProblems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 56,
          ),
          itemBuilder: (context, index) {
            final prob = widget.service.commonProblems[index];
            final isSelected = selectedProblemChip == prob;
            return InkWell(
              onTap: () => setState(() => selectedProblemChip = prob),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isSelected ? lightTint : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isSelected ? primary : const Color(0xFFCBD5E1), width: isSelected ? 1.8 : 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(prob, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? primary : Colors.black87))),
                    if (isSelected) Icon(Icons.check_circle_rounded, color: primary, size: 20),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),

        InkWell(
          onTap: () => setState(() => recordedVoiceDiagnosis = !recordedVoiceDiagnosis),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: recordedVoiceDiagnosis ? Colors.green : const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: recordedVoiceDiagnosis ? Colors.green.shade50 : lightTint,
                  child: Icon(
                    recordedVoiceDiagnosis ? Icons.check_circle_rounded : Icons.mic_rounded,
                    color: recordedVoiceDiagnosis ? Colors.green : primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    recordedVoiceDiagnosis
                        ? 'تم إرفاق رسالة صوتية لتشخيص العطل'
                        : 'سجّل رسالة صوتية أو فيديو قصير لصوت/شكل العطل (اختياري)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text('تفاصيل إضافية (اختياري)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: extraDetailsCtrl,
          maxLines: 2,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
            onPressed: () => setState(() => currentStep = 2),
            child: const Text('متابعة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep2(Color primary, Color lightTint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('فين ومتى؟', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        TextField(controller: districtCtrl, decoration: const InputDecoration(labelText: 'المنطقة / الحي')),
        const SizedBox(height: 12),
        TextField(controller: streetBuildingCtrl, decoration: const InputDecoration(labelText: 'الشارع ورقم العمارة')),
        const SizedBox(height: 12),
        TextField(controller: floorAptCtrl, decoration: const InputDecoration(labelText: 'الدور والشقة (اختياري)')),
        const SizedBox(height: 12),
        TextField(controller: landmarkCtrl, decoration: const InputDecoration(labelText: 'علامة مميزة (اختياري)')),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
            onPressed: () => setState(() => currentStep = 3),
            child: const Text('مراجعة الطلب', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3(Color primary, Color lightTint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('راجع طلبك', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const SizedBox(height: 14),
        Card(
          color: Colors.white,
          child: Column(
            children: [
              ListTile(
                title: const Text('الخدمة والمشكلة'),
                subtitle: Text('صيانة ${widget.service.name} - $selectedProblemChip', style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: TextButton(onPressed: () => setState(() => currentStep = 1), child: const Text('تعديل')),
              ),
              const Divider(height: 1),
              ListTile(
                title: const Text('المكان والموعد'),
                subtitle: Text('${districtCtrl.text} - $preferredAppointmentSlot', style: const TextStyle(fontWeight: FontWeight.bold)),
                trailing: TextButton(onPressed: () => setState(() => currentStep = 2), child: const Text('تعديل')),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primary, foregroundColor: Colors.white),
            onPressed: () {
              final pinCode = (1000 + DateTime.now().millisecond % 8999).toString();
              final inv = ElectronicWarrantyInvoiceModel(
                invoiceNumber: 'KHD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                issueDate: '2026-11-09',
                warrantyEndDate: '2026-12-09',
                warrantyPeriodText: 'ضمان شامل 30 يوماً بـ QR',
                safeEntryPin: pinCode,
                customerName: 'عميل خدماتي',
                customerPhone: customerPhoneCtrl.text.trim(),
                customerAddress: '$selectedCityLocation - ${districtCtrl.text} (${streetBuildingCtrl.text})',
                providerName: 'شركة الرواد الهندسية',
                providerRole: 'شركة صيانة معتمدة (موثقة)',
                providerPhone: '01009988776',
                serviceTitle: 'صيانة ${widget.service.name} ($selectedProblemChip)',
                workDescription: extraDetailsCtrl.text.trim(),
                totalAmountEgp: 300.0,
              );
              final newReq = CustomerRequestModel(
                id: 'REQ-${DateTime.now().millisecondsSinceEpoch.toString().substring(9)}',
                serviceName: 'صيانة ${widget.service.name}',
                selectedProblem: selectedProblemChip,
                extraDetails: extraDetailsCtrl.text.trim(),
                governorateAndCity: selectedCityLocation,
                district: districtCtrl.text.trim(),
                streetAndBuilding: streetBuildingCtrl.text.trim(),
                floorAndApt: floorAptCtrl.text.trim(),
                landmark: landmarkCtrl.text.trim(),
                appointmentType: 'اختيار موعد',
                preferredDateText: preferredAppointmentSlot,
                customerPhone: customerPhoneCtrl.text.trim(),
                safeEntryPin: pinCode,
                isEmergencySos: widget.isEmergencySos,
                issuedWarrantyInvoice: inv,
                bids: [
                  OfferBid(
                    providerName: 'شركة الرواد الهندسية',
                    providerRole: 'شركة معتمدة (موثقة بالسجل التجاري)',
                    phone: '01009988776',
                    whatsapp: '201009988776',
                    email: 'rowad@khadamaty-eg.com',
                    priceEgp: 300,
                    appointment: preferredAppointmentSlot,
                    points: 2100,
                    jobsCount: 165,
                    rating: 4.95,
                    reviews: ['شركة ممتازة ومواعيد دقيقة بالضمان.'],
                  ),
                ],
              );
              Navigator.pop(context, newReq);
            },
            child: const Text('متابعة برقم الهاتف وإصدار كود الأمان والطلب',
                style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}