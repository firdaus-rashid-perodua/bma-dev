import 'package:flutter/material.dart';

class RegionModel {
  final String? routeType;
  final String title;
  final String? regionCode;
  final String? outletCode;
  final String percentage;
  final Color color;
  final String actual;
  final String target;
  final String yoy;
  final Color yoyColor;
  final VoidCallback? onTap;
  final IconData? icon;

  RegionModel({
    this.routeType,
    required this.title,
    this.regionCode,
    this.outletCode,
    required this.percentage,
    required this.color,
    required this.actual,
    required this.target,
    required this.yoy,
    required this.yoyColor,
    this.onTap,
    this.icon,
  });
}
