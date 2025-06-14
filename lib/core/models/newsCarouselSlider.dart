import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/link.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:grad_project/core/models/newsItem.dart';

class CustomCarouselSlider extends StatefulWidget {
  const CustomCarouselSlider({super.key});

  @override
  State<CustomCarouselSlider> createState() => _CustomCarouselSliderState();
}

class _CustomCarouselSliderState extends State<CustomCarouselSlider> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;
  List<NewsItem> _news = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('NewsLatest').get();
    final newsList =
        snapshot.docs.map((doc) => NewsItem.fromFirestore(doc.data())).toList();
    setState(() {
      _news = newsList;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    final List<Widget> imageSliders =
        _news
            .map(
              (item) => Container(
                margin: const EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(46.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(24.0)),
                  child: Stack(
                    children: <Widget>[
                      Link(
                        target: LinkTarget.self,
                        uri: Uri.parse(item.link),
                        builder:
                            (context, followLink) => InkWell(
                              onTap: followLink,
                              child: Image.network(
                                item.imgUrl,
                                fit: BoxFit.cover,
                                width: 1000.0,
                              ),
                            ),
                      ),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: Text(
                                '${item.author} • ${item.time}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color.fromARGB(200, 0, 0, 0),
                                    Color.fromARGB(0, 0, 0, 0),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 10.0,
                                horizontal: 20.0,
                              ),
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList();
    return Column(
      children: [
        CarouselSlider(
          items: imageSliders,
          carouselController: _controller,
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 2.0,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children:
              _news.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: _current == entry.key ? 25.0 : 12.0,
                    height: 12.0,
                    margin: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    decoration: BoxDecoration(
                      borderRadius:
                          _current == entry.key
                              ? BorderRadius.circular(8.0)
                              : null,
                      shape:
                          _current == entry.key
                              ? BoxShape.rectangle
                              : BoxShape.circle,
                      color:
                          _current == entry.key
                              ? Theme.of(context).colorScheme.secondary
                              : const Color.fromARGB(255, 129, 129, 129),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
