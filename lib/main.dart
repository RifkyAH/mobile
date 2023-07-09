import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<dynamic> newsList = [];
  int currentPage = 1;
  int itemsPerPage = 5;

  Future<void> fetchNews() async {
    String apiUrl =
        'https://the-lazy-media-api.vercel.app/api/games?page=$currentPage';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<dynamic> fetchedNews = data as List<dynamic>;

      setState(() {
        newsList.addAll(fetchedNews);
        currentPage++; // Increment the page for the next fetch
      });
    } else {
      throw Exception('Failed to load news');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    List<dynamic> displayedNews = newsList.sublist(
        startIndex, endIndex < newsList.length ? endIndex : newsList.length);

    int totalPages = (newsList.length / itemsPerPage).ceil();

    return MaterialApp(
      title: 'Lazy News',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor:
              Colors.transparent, // Hapus background color agar transparan
          elevation: 0, // Hapus bayangan di bawah AppBar
          toolbarHeight: 120,

          flexibleSpace: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background.jpg'), // Ganti dengan path gambar yang diinginkan
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        body: ListView.builder(
          itemCount: displayedNews.length + (currentPage <= totalPages ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == displayedNews.length && currentPage <= totalPages) {
              if (totalPages > 1) {
                return Container(
                  height: 50,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List<Widget>.generate(totalPages, (pageIndex) {
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            if (pageIndex + 1 <= totalPages) {
                              setState(() {
                                currentPage = pageIndex + 1;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: currentPage == pageIndex + 1
                                ? Colors.orange
                                : Colors.grey,
                          ),
                          child: Text(
                            (pageIndex + 1).toString(),
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              } else {
                return SizedBox.shrink();
              }
            } else {
              var news = displayedNews[index];
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news['title'],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      news['desc'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'By ${news['author']} - ${news['time']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
