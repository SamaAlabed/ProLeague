import 'package:cloud_firestore/cloud_firestore.dart';

class NewsItem {
  final String id;
  final String title;
  final String imgUrl;
  final String category;
  final String author;
  final String time;
  final String link;

  NewsItem({
    required this.id,
    required this.title,
    required this.imgUrl,
    required this.category,
    required this.author,
    required this.time,
    required this.link,
  });

  factory NewsItem.fromFirestore(Map<String, dynamic> data) {
    return NewsItem(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      imgUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      author: data['team'] ?? '',
      time: data['Time'] ?? '',
      link: data['content'] ?? '',
    );
  }
}

List<NewsItem> news = [];

Future<List<NewsItem>> getNews() async {
  try {
    final snapshot =
        await FirebaseFirestore.instance.collection('NewsLatest').get();

    final newsList =
        snapshot.docs.map((doc) {
          return NewsItem.fromFirestore(doc.data());
        }).toList();

    return newsList;
  } catch (e) {
    throw Exception('Failed to load news: $e');
  }
}
