import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cart_manager.dart';

enum RentalUnit { hours, days }

class Order {
  Order({
    required this.selectedSegment,
    required this.selectedTime,
    required this.selectedDate,
    required this.name,
    required this.items,
    required this.vehicleName,
    required this.vehicleImageUrl,
    required this.vehicleClass,
    required this.baseRate,
    required this.rentalUnit,
    required this.rentalLength,
    this.discountAmount = 0,
    this.discountCode,
  });

  final Set<int> selectedSegment;
  final TimeOfDay? selectedTime;
  final DateTime? selectedDate;
  final String name;
  final List<CartItem> items;
  final String vehicleName;
  final String vehicleImageUrl;
  final String vehicleClass;
  final double baseRate;
  final RentalUnit rentalUnit;
  final int rentalLength;
  final double discountAmount;
  final String? discountCode;

  String getFormattedSegment() {
    if (selectedSegment.contains(0)) {
      return 'Round trip';
    } else if (selectedSegment.contains(1)) {
      return 'One-way';
    } else {
      return 'Flexible';
    }
  }

  String getFormattedTime() {
    if (selectedTime == null) return 'Unknown';
    final hour = selectedTime!.hour.toString().padLeft(2, '0');
    final minute = selectedTime!.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String getFormattedDate() {
    if (selectedDate == null) return 'Unknown';
    return DateFormat('yyyy-MM-dd').format(selectedDate!);
  }

  String getFormattedName() {
    if (name.isEmpty) return 'Guest driver';
    return name;
  }

  String get rentalLengthLabel {
    final unitLabel = rentalUnit == RentalUnit.hours ? 'hour' : 'day';
    final suffix = rentalLength == 1 ? '' : 's';
    return '$rentalLength $unitLabel$suffix';
  }

  double get addOnTotal {
    return items.fold<double>(0, (total, item) => total + item.totalCost);
  }

  double get rentalCost => baseRate * rentalLength;

  double get subtotal => rentalCost + addOnTotal;

  double get totalCost => (subtotal - discountAmount).clamp(0, double.infinity);

  DateTime? get pickupDateTime {
    if (selectedDate == null || selectedTime == null) {
      return null;
    }

    return DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
  }

  DateTime? get returnDateTime {
    final pickup = pickupDateTime;
    if (pickup == null) {
      return null;
    }

    return rentalUnit == RentalUnit.hours
        ? pickup.add(Duration(hours: rentalLength))
        : pickup.add(Duration(days: rentalLength));
  }

  String getFormattedReturnDate() {
    if (returnDateTime == null) return 'Unknown';
    return DateFormat('yyyy-MM-dd HH:mm').format(returnDateTime!);
  }

  String getFormattedOrderInfo() {
    return '$vehicleName - $vehicleClass\n'
        '${getFormattedName()}, Pickup: ${getFormattedDate()} at '
        '${getFormattedTime()}\n'
        'Return: ${getFormattedReturnDate()}\n'
        '$rentalLengthLabel, ${getFormattedSegment()}'
        '${discountCode == null ? '' : '\nPromo: $discountCode'}';
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    final selectedSegment = (json['selectedSegment'] as List<dynamic>? ?? [])
        .whereType<num>()
        .map((value) => value.toInt())
        .toSet();
    final selectedTimeJson = json['selectedTime'] as Map<String, dynamic>?;
    final selectedTime = selectedTimeJson == null
        ? null
        : TimeOfDay(
            hour: (selectedTimeJson['hour'] as int?) ?? 0,
            minute: (selectedTimeJson['minute'] as int?) ?? 0,
          );
    final selectedDateRaw = json['selectedDate'] as String?;
    final selectedDate =
        selectedDateRaw == null ? null : DateTime.tryParse(selectedDateRaw);
    final items = (json['items'] as List<dynamic>? ?? [])
        .whereType<Map>()
        .map((item) => CartItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    final rentalUnitRaw = json['rentalUnit'] as String?;
    final rentalUnit = rentalUnitRaw == RentalUnit.days.name
        ? RentalUnit.days
        : RentalUnit.hours;

    return Order(
      selectedSegment: selectedSegment.isEmpty ? {0} : selectedSegment,
      selectedTime: selectedTime,
      selectedDate: selectedDate,
      name: json['name'] as String? ?? '',
      items: items,
      vehicleName: json['vehicleName'] as String? ?? '',
      vehicleImageUrl: json['vehicleImageUrl'] as String? ?? '',
      vehicleClass: json['vehicleClass'] as String? ?? '',
      baseRate: (json['baseRate'] as num?)?.toDouble() ?? 0,
      rentalUnit: rentalUnit,
      rentalLength: json['rentalLength'] as int? ?? 1,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0,
      discountCode: json['discountCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'selectedSegment': selectedSegment.toList(),
        'selectedTime': selectedTime == null
            ? null
            : {
                'hour': selectedTime!.hour,
                'minute': selectedTime!.minute,
              },
        'selectedDate': selectedDate?.toIso8601String(),
        'name': name,
        'items': items.map((item) => item.toJson()).toList(),
        'vehicleName': vehicleName,
        'vehicleImageUrl': vehicleImageUrl,
        'vehicleClass': vehicleClass,
        'baseRate': baseRate,
        'rentalUnit': rentalUnit.name,
        'rentalLength': rentalLength,
        'discountAmount': discountAmount,
        'discountCode': discountCode,
      };
}

class OrderManager {
  OrderManager({List<Order>? initialOrders}) {
    if (initialOrders != null) {
      _orders.addAll(initialOrders);
    }
  }

  static const _ordersKey = 'echelon_orders';
  static const _cloudCollection = 'order_history';
  static const _maxCloudOrders = 200;
  final List<Order> _orders = [];

  static Future<List<Order>> loadSavedOrders() async {
    final cloudOrders = await _tryLoadCloudOrders();
    if (cloudOrders != null) {
      return cloudOrders;
    }
    return _loadLocalOrders();
  }

  static Future<List<Order>?> _tryLoadCloudOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return null;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection(_cloudCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => doc.data()['order'])
          .whereType<Map>()
          .map((entry) => Order.fromJson(Map<String, dynamic>.from(entry)))
          .toList();
    } catch (_) {
      return null;
    }
  }

  static Future<List<Order>> _loadLocalOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_ordersKey);
      if (raw == null || raw.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((entry) => Order.fromJson(Map<String, dynamic>.from(entry)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _persistOrders({bool persistCloud = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_orders.map((order) => order.toJson()).toList());
    await prefs.setString(_ordersKey, encoded);
    if (persistCloud) {
      await _tryPersistCloudOrders();
    }
  }

  Future<void> _tryPersistCloudOrders() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return;
      }

      final ordersCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection(_cloudCollection);

      final existingDocs = await ordersCollection.get();
      final batch = FirebaseFirestore.instance.batch();

      for (final doc in existingDocs.docs) {
        batch.delete(doc.reference);
      }

      final start = _orders.length > _maxCloudOrders
          ? _orders.length - _maxCloudOrders
          : 0;
      for (final order in _orders.skip(start)) {
        final docRef = ordersCollection.doc();
        batch.set(docRef, {
          'order': order.toJson(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (_) {
      // Keep local persistence as primary fallback when cloud sync fails.
    }
  }

  Future<void> syncFromCloudIfAvailable() async {
    final cloudOrders = await _tryLoadCloudOrders();
    if (cloudOrders == null) {
      return;
    }

    _orders
      ..clear()
      ..addAll(cloudOrders);
    await _persistOrders(persistCloud: false);
  }

  List<Order> get orders => _orders;

  Future<void> addOrder(Order order) async {
    _orders.add(order);
    await _persistOrders();
  }

  Future<void> insertOrder(int index, Order order) async {
    _orders.insert(index.clamp(0, _orders.length), order);
    await _persistOrders();
  }

  Future<void> removeOrder(Order order) async {
    _orders.remove(order);
    await _persistOrders();
  }

  int get totalOrders => _orders.length;
}
