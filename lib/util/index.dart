import 'entities.dart';

Iterable<Map<String, String>> parseText(String article) {
  var content = article.replaceAll(RegExp(r'\r\n|\n|\r'), '');
  for (var key in entityMap.keys) {
    var val = entityMap[key] as String;
    var re = RegExp("&" + key + ";");
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

void main() {
  parseText('asdf');
}
