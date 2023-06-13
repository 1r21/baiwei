import 'entities.dart';

Iterable<Map<String, String>> parseText(String text) {
  var content = text.replaceAll(RegExp(r'\r\n|\n|\r'), '');
  for (var key in entityMap.keys) {
    var val = entityMap[key] as String;
    var re = RegExp("&$key;");
    content = content.replaceAll(re, val);
  }

  var hReg = RegExp(r'<p[^>]*>(.*?)<\/p>');

  return hReg.allMatches(content).map((match) {
    var item = match.group(0);
    if (item!.contains("</strong>")) {
      var tRe = RegExp(r'<p><strong[^>]*>(.*?)<\/strong><\/p>');
      return {
        'type': "title",
        'value': item.replaceAllMapped(tRe, (Match m) => m[1].toString()),
      };
    }
    return {
      'type': "text",
      'value': item.replaceAllMapped(
          RegExp(r'<p[^>]*>(.*?)<\/p>'), (Match m) => m[1].toString()),
    };
  });
}

class Pager<T> {
  final int total;
  final int page;
  final int pageSize;
  final List<T> list;

  Pager(this.list, this.total, this.page, this.pageSize);

  Pager.fromJson(Map<String, dynamic> json)
      : this(json["list"] as List<T>, json['total'], json['page'],
            json['pageSize']);
}
