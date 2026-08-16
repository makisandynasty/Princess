/// Quote entity for the daily quotes engine (FR-5.x).
class QuoteEntity {
  const QuoteEntity({
    required this.id,
    required this.text,
    required this.author,
    required this.category,
  });

  final int id;
  final String text;
  final String author;

  /// One of: 'Motivational', 'Sweet', 'Mindfulness'
  final String category;

  factory QuoteEntity.fromJson(Map<String, dynamic> json) => QuoteEntity(
        id: json['id'] as int,
        text: json['text'] as String,
        author: json['author'] as String,
        category: json['category'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'author': author,
        'category': category,
      };
}
