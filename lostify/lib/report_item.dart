class ReportItem {
  final String id;
  final String title;
  final String? brand;
  final String? description;
  final String? imageUrl;
  final String reportType;
  final String status;

  ReportItem({
    required this.id,
    required this.title,
    this.brand,
    this.description,
    this.imageUrl,
    required this.reportType,
    required this.status,
  });

  factory ReportItem.fromMap(Map<String, dynamic> map) {
    return ReportItem(
      id: map['id'],
      title: map['title'],
      brand: map['brand'],
      description: map['description'],
      imageUrl: map['image_url'],
      reportType: map['report_type'],
      status: map['status'],
    );
  }
}
