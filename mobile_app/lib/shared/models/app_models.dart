import 'package:flutter/material.dart';

class ServiceItemModel {
  final String id;
  final String name;
  final String subtitle;
  int minPrice;
  int maxPrice;
  final int inspectionFee;
  final IconData icon;
  final Color color;

  ServiceItemModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.minPrice,
    required this.maxPrice,
    this.inspectionFee = 50,
    required this.icon,
    required this.color,
  });

  String get priceRange => '$minPrice - $maxPrice ج.م';
}

class SparePartItemModel {
  final String id;
  final String name;
  final String category;
  final String brand;
  int officialPrice;
  final int warrantyMonths;

  SparePartItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.brand,
    required this.officialPrice,
    this.warrantyMonths = 6,
  });
}

class HomeApplianceModel {
  final String id;
  final String name;
  final String brand;
  final String locationRoom;
  final String lastMaintenanceDate;
  final String nextReminderDate;
  final int healthScore;
  final String warrantyStatus;

  HomeApplianceModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.locationRoom,
    required this.lastMaintenanceDate,
    required this.nextReminderDate,
    this.healthScore = 94,
    this.warrantyStatus = 'ساري تحت الضمان الذهبي',
  });
}

class CompanyItemModel {
  final String id;
  final String name;
  final String specialty;
  final String city;
  final String commercialReg;
  final String taxCard;
  int techniciansCount;
  int activeAmcContracts;
  double rating;
  bool isVerified;

  CompanyItemModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.city,
    required this.commercialReg,
    required this.taxCard,
    this.techniciansCount = 12,
    this.activeAmcContracts = 18,
    this.rating = 4.9,
    this.isVerified = true,
  });
}

class AiDiagnosisResultModel {
  final String title;
  final String technicalCause;
  final String recommendedService;
  final List<SparePartItemModel> suggestedParts;
  final int estimatedLabor;
  final int inspectionFee;
  final bool isUrgentSos;

  AiDiagnosisResultModel({
    required this.title,
    required this.technicalCause,
    required this.recommendedService,
    required this.suggestedParts,
    required this.estimatedLabor,
    this.inspectionFee = 50,
    this.isUrgentSos = false,
  });

  int get partsTotal => suggestedParts.fold<int>(0, (sum, p) => sum + p.officialPrice);
  int get totalEstimatedPrice => estimatedLabor + partsTotal;
}

class TechnicianItemModel {
  final String id;
  final String name;
  final String specialty;
  final String city;
  final String phone;
  final double distanceKm;
  final String nationalId;
  final String idFrontPhoto;
  final String idBackPhoto;
  final String certificatePhoto;
  final int experienceYears;
  final String walletNumber;
  final String companyAffiliation;
  double rating;
  int completedJobs;
  bool isVerified;
  bool isOnline;
  String approvalStatus; // 'approved', 'pending', 'rejected'

  TechnicianItemModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.city,
    required this.phone,
    required this.distanceKm,
    this.nationalId = '29405120102938',
    this.idFrontPhoto = 'بطاقة_الهوية_أمامي.jpg',
    this.idBackPhoto = 'بطاقة_الهوية_خلفي.jpg',
    this.certificatePhoto = 'شهادة_الخبرة_والفيش.jpg',
    this.experienceYears = 5,
    this.walletNumber = '01012345678',
    this.companyAffiliation = 'فني مستقل معتمد',
    this.rating = 4.9,
    this.completedJobs = 42,
    this.isVerified = true,
    this.isOnline = true,
    this.approvalStatus = 'approved',
  });

  String get approvalStatusArabic {
    if (approvalStatus == 'approved' && isVerified) return 'معتمد وموثق بالهوية ✅';
    if (approvalStatus == 'rejected') return 'مرفوض من الإدارة ❌';
    return 'قيد مراجعة الإدارة للهوية ⏳';
  }
}

class OrderItemModel {
  final String id;
  final String serviceName;
  final String description;
  final List<String> attachedPhotos;
  final String city;
  final String address;
  final String mapCoordinates;
  final String appointmentSlot;
  final String assignmentMode;
  final String customerName;
  final String customerPhone;
  final String pinCode;
  final String paymentMethod;
  int statusIndex;
  int price;
  String technicianId;
  String technicianName;
  String technicianPhone;
  bool isPaid;
  int? customerRating;
  String? customerReview;
  final List<String> chatMessages;

  OrderItemModel({
    required this.id,
    required this.serviceName,
    required this.description,
    required this.attachedPhotos,
    required this.city,
    required this.address,
    required this.mapCoordinates,
    required this.appointmentSlot,
    required this.assignmentMode,
    required this.customerName,
    required this.customerPhone,
    required this.pinCode,
    required this.paymentMethod,
    required this.statusIndex,
    required this.price,
    required this.technicianId,
    required this.technicianName,
    required this.technicianPhone,
    this.isPaid = false,
    this.customerRating,
    this.customerReview,
    List<String>? chatMessages,
  }) : chatMessages = chatMessages ?? [
          'النظام: تم تسجيل الطلب وإرساله لأقرب فني معتمد في منطقتك.',
        ];

  static const List<String> statusLabels = [
    'جديد',
    'مقبول',
    'في الطريق',
    'قيد التنفيذ',
    'مكتمل',
  ];

  String get statusText => statusLabels[statusIndex.clamp(0, 4)];

  List<String> get beforePhotos =>
      attachedPhotos.where((p) => !p.startsWith('بعد_') && !p.startsWith('قطعة_') && !p.startsWith('وسم_')).toList();

  List<String> get afterPhotos =>
      attachedPhotos.where((p) => p.startsWith('بعد_')).toList();

  List<String> get officialSparePartsUsed =>
      attachedPhotos.where((p) => p.startsWith('قطعة_')).map((p) => p.replaceFirst('قطعة_', '')).toList();

  bool get isSosEmergency =>
      appointmentSlot.contains('طوارئ') || description.contains('[SOS]') || attachedPhotos.contains('وسم_SOS');

  bool get isFamilySafeModeActive =>
      attachedPhotos.contains('وسم_الأمان_العائلي');

  bool get isQuoteApproved =>
      attachedPhotos.contains('وسم_مقايسة_معتمدة');

  int get cashbackAmount => (price * 0.10).round();

  String get warrantyNumber => 'WAR-${id.replaceAll("KH-", "")}-2026';

  String get familyTrackingLink => 'https://khadamaty.com/safe-track/$id?pin=$pinCode';

  Map<String, dynamic> toSupabaseJson() => {
        'id': id,
        'service_name': serviceName,
        'description': description,
        'attached_photos': attachedPhotos,
        'city': city,
        'address': address,
        'map_coordinates': mapCoordinates,
        'appointment_slot': appointmentSlot,
        'assignment_mode': assignmentMode,
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'pin_code': pinCode,
        'payment_method': paymentMethod,
        'status_index': statusIndex,
        'price': price,
        'technician_id': technicianId,
        'technician_name': technicianName,
        'technician_phone': technicianPhone,
        'is_paid': isPaid,
        'customer_rating': customerRating,
        'customer_review': customerReview,
        'chat_messages': chatMessages,
      };

  factory OrderItemModel.fromSupabaseJson(Map<String, dynamic> json) {
    final rawPhotos = json['attached_photos'];
    final rawChats = json['chat_messages'];
    return OrderItemModel(
      id: (json['id'] ?? 'KH-0000').toString(),
      serviceName: (json['service_name'] ?? 'صيانة عامة').toString(),
      description: (json['description'] ?? '').toString(),
      attachedPhotos: rawPhotos is List ? rawPhotos.map((e) => e.toString()).toList() : ['قبل_صورة_العطل.jpg'],
      city: (json['city'] ?? 'القاهرة').toString(),
      address: (json['address'] ?? '').toString(),
      mapCoordinates: (json['map_coordinates'] ?? '').toString(),
      appointmentSlot: (json['appointment_slot'] ?? '').toString(),
      assignmentMode: (json['assignment_mode'] ?? 'تلقائي').toString(),
      customerName: (json['customer_name'] ?? 'عميل خدماتي').toString(),
      customerPhone: (json['customer_phone'] ?? '').toString(),
      pinCode: (json['pin_code'] ?? '1234').toString(),
      paymentMethod: (json['payment_method'] ?? 'كاش').toString(),
      statusIndex: (json['status_index'] is int) ? json['status_index'] as int : int.tryParse(json['status_index'].toString()) ?? 0,
      price: (json['price'] is int) ? json['price'] as int : int.tryParse(json['price'].toString()) ?? 300,
      technicianId: (json['technician_id'] ?? 'TECH-1').toString(),
      technicianName: (json['technician_name'] ?? 'م. مصطفى السيد').toString(),
      technicianPhone: (json['technician_phone'] ?? '01066554433').toString(),
      isPaid: json['is_paid'] == true,
      customerRating: json['customer_rating'] is int ? json['customer_rating'] as int : null,
      customerReview: json['customer_review']?.toString(),
      chatMessages: rawChats is List ? rawChats.map((e) => e.toString()).toList() : ['النظام: تم استلام الطلب على السحابة.'],
    );
  }
}