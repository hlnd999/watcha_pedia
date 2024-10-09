import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:watcha_pedia/main.dart';
import 'book.dart';

class BookService extends ChangeNotifier {
  BookService() {
    loadLikedBookList();
  }

  List<Book> bookList = []; // 책 목록
  List<Book> likedBookList = [];

  void toggleLikeBook({required Book book}) {
    String bookId = book.id;
    // map은 Interable(리스트랑 비슷) 반환
    if (likedBookList.map((book) => book.id).contains(bookId)) {
      // 클래스를 통해 생성된 두개의 객체는 처음에 대입해주는
      // 값들(Book의 title, subtitle 등)이 같더라도, 서로 다른 존재.
      // var book1 = Book(id: "1", title: "톰 소여의 모험");
      // var book2 = Book(id: "1", title: "톰 소여의 모험");
      // print(book1 == book2) // false

      likedBookList.removeWhere((book) => book.id == bookId);
    } else {
      likedBookList.add(book);
    }
    notifyListeners();
    // print(likedBookList);
    saveLikedBookList();
  }

  // 검색에 관한 CRUD 로직은 서비스에 작성!
  // main.dart 에서는 이 로직을 가져다 쓰는 기능!

  void search(String q) async {
    bookList.clear(); // 검색 버튼 누를때 이전 데이터들을 지워주기

    if (q.isNotEmpty) {
      Response res = await Dio().get(
        "https://www.googleapis.com/books/v1/volumes?q=$q&startIndex=0&maxResults=40",
      );
      List items = res.data["items"];
      // print(items);

      for (Map<String, dynamic> item in items) {
        Book book = Book(
          id: item['id'],
          title: item['volumeInfo']['title'] ?? "",
          subtitle: item['volumeInfo']['subtitle'] ?? "",
          authors: item['volumeInfo']['authors'] ?? "",
          publishedDate: item['volumeInfo']['publishedDate'] ?? "",
          thumbnail: item['volumeInfo']['imageLinks']?['thumbnail'] ??
              "https://thumbs.dreamstime.com/b/no-image-available-icon-flat-vector-no-image-available-icon-flat-vector-illustration-132482953.jpg",
          previewLink: item['volumeInfo']['previewLink'] ?? "",
          // ?? 는 해당 변수에 담긴 값이 null일 경우, 즉 값이 없을 경우 뒤에 오는 값을 사용하겠다는 뜻
        );
        bookList.add(book);
      }
    }
    notifyListeners();
  }

  saveLikedBookList() {
    // List likedBookJsonList = likedBookList.map((book){return book.toJson()})
    List likedBookJsonList =
        likedBookList.map((book) => book.toJson()).toList();

    String jsonString = jsonEncode(likedBookJsonList);

    prefs.setString('likedBookList', jsonString); // 저장로직
  }

  loadLikedBookList() {
    String? jsonString = prefs.getString('likedBookList');

    if (jsonString == null) return;

    List likedBookJsonList = jsonDecode(jsonString);

    likedBookList =
        likedBookJsonList.map((json) => Book.fromJson(json)).toList();
  }
}
