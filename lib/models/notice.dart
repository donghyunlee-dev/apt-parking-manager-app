class Notice {
  final int id;
  final String title;
  final String content;
  final String category;
  final String createdAt;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
  });

  factory Notice.fromJson(Map<String, dynamic> json) {
    return Notice(
      id: json['id'] as int,
      title: json['subject'] as String? ?? '',
      content: json['content'] as String? ?? '',
      category: json['category'] is Map 
          ? (json['category']['name'] ?? '공지') 
          : (json['category'] ?? '공지'),
      createdAt: json['created_at'] ?? '',
    );
  }
}
