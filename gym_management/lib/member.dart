
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
// Data Models and Storage Helper
class MemberModel {
  String id;
  String name;
  String contact;
  String plan;
  List<String> attendance;
  Fee fee;

  MemberModel({
    required this.id,
    required this.name,
    required this.contact,
    required this.plan,
    required this.attendance,
    required this.fee,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'contact': contact,
        'plan': plan,
        'attendance': attendance,
        'fee': fee.toJson(),
      };

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
        id: json['id'],
        name: json['name'],
        contact: json['contact'],
        plan: json['plan'],
        attendance: List<String>.from(json['attendance'] ?? []),
        fee: Fee.fromJson(json['fee']),
      );
}

class Fee {
  double amount;
  String dueDate;
  bool paid;
  List<FeeHistory> history;

  Fee({
    required this.amount,
    required this.dueDate,
    required this.paid,
    required this.history,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'dueDate': dueDate,
        'paid': paid,
        'history': history.map((h) => h.toJson()).toList(),
      };

  factory Fee.fromJson(Map<String, dynamic> json) => Fee(
        amount: (json['amount'] as num).toDouble(),
        dueDate: json['dueDate'],
        paid: json['paid'],
        history: (json['history'] as List<dynamic>? ?? [])
            .map((h) => FeeHistory.fromJson(h))
            .toList(),
      );
}

class FeeHistory {
  double amount;
  String date;

  FeeHistory({required this.amount, required this.date});

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'date': date,
      };

  factory FeeHistory.fromJson(Map<String, dynamic> json) => FeeHistory(
        amount: (json['amount'] as num).toDouble(),
        date: json['date'],
      );
}

class MemberStorage {
  static const String _key = 'members';

  static Future<List<MemberModel>> loadMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_key);
    if (data == null) return [];
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((e) => MemberModel.fromJson(e)).toList();
  }

  static Future<void> saveMembers(List<MemberModel> members) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(members.map((e) => e.toJson()).toList());
    await prefs.setString(_key, data);
  }
}

// ...existing widget code...