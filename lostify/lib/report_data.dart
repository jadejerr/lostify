class ReportItem {
  final String id;
  final String title;
  final String? brand;
  final String? description;
  final String? location;
  final String status;
  final String? timeDescription;
  final String? imageUrl;
  final String reportType;

  ReportItem({
    required this.id,
    required this.title,
    this.brand,
    this.description,
    this.location,
    required this.status,
    this.timeDescription,
    this.imageUrl,
    required this.reportType,
  });

  factory ReportItem.fromMap(Map<String, dynamic> map) {
    return ReportItem(
      id: map['id'].toString(),
      title: map['title'] ?? '',
      brand: map['brand'],
      description: map['description'],
      location: map['location'],
      status: map['status'] ?? '',
      timeDescription: map['time_description'],
      imageUrl: map['image_url'],
      reportType: map['report_type'] ?? '',
    );
  }
}

List<ReportItem> globalReports = [];
