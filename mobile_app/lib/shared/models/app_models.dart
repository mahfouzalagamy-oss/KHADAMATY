import 'package:flutter/material.dart';

class ServiceItemModel {
  final String id;
  final String name;
  final String subtitle;
  int minPrice;
  int maxPrice;
  final IconData icon;
  final Color color;

  ServiceItemModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.minPrice,
    required this.maxPrice,
    required this.icon,
    required this.color,
  });

  String get priceRange => '$minPrice - $maxPrice ج.م';
}

class TechnicianItemModel {
  final String id;
  final String name;
  final String specialty;
  final String city;
  final String phone;
  final double distanceKm;
  double rating;
  int completedJobs;
  bool isVerified;
  bool isOnline;

  TechnicianItemModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.city,
    required this.phone,
    required this.distanceKm,
    this.rating = 4.9,
    this.completedJobs = 42,
    this.isVerified = true,
    this.isOnline = true,
  });
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
  final String assignmentMode; // تلقائي حسب القرب / يدوي
  final String customerName;
  final String customerPhone;
  final String pinCode;
  final String paymentMethod; // كاش / بطاقة Paymob / فوري
  int statusIndex; // 0: جديد, 1: مقبول, 2: في الطريق, 3: قيد التنفيذ, 4: مكتمل
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
}