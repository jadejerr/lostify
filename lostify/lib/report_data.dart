import 'dart:io';

// 1. Define what a Report Item looks like
class ReportItem {
  final String title;
  final String brand;
  final String desc;
  final String location;
  final String status;
  final String time;
  final File? image;

  ReportItem({
    required this.title,
    required this.brand,
    required this.desc,
    required this.location,
    required this.status,
    required this.time,
    this.image,
  });
}

List<ReportItem> globalReports = [];