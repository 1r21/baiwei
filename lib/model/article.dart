class Article {
  final int id;
  final String cover;
  final String date;
  final String title;
  final String transcript;
  final String src;

  Article(
      {required this.id,
      required this.cover,
      required this.date,
      required this.title,
      this.transcript = '',
      this.src = ''});

  Article.fromJson(Map<String, dynamic> json)
      : this(
            id: json['id'],
            cover: json['cover'],
            date: json['date'],
            title: json['title'],
            src: json['src'] ?? "",
            transcript: json['transcript'] ?? "");

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "cover": cover,
      "date": date,
      "title": title,
      "src": src,
      "transcript": transcript
    };
  }
}
