import 'package:flutter/material.dart';

class DealerItemModel {
  final int? rank;
  final Color? medalColor;
  final String? name;
  final String? outletCode;
  final int? actual;
  final int? target;
  final int? percentage;
  final String? status;
  final Color? statusColor;
  final Color? dotColor;
  final bool? isGold;
  final VoidCallback? onTap;

  const DealerItemModel({
    this.rank,
    this.medalColor,
    this.name,
    this.outletCode,
    this.actual,
    this.target,
    this.percentage,
    this.status,
    this.statusColor,
    this.dotColor,
    this.isGold,
    this.onTap,
  });
}
