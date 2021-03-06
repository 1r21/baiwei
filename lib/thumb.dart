import 'package:baiwei/util/request.dart';
import 'package:flutter/material.dart';

Widget articleOverview(Article article) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      FadeInImage(
        width: 400,
        height: 200,
        fit: BoxFit.cover,
        placeholder: AssetImage("assets/102.jpeg"),
        image: NetworkImage(article.cover, scale: 1.0),
      ),
      Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: Text(
          article.date,
          style: const TextStyle(fontSize: 14),
        ),
      ),
      Text(
        article.title,
        style: const TextStyle(fontSize: 16),
      ),
    ],
  );
}
