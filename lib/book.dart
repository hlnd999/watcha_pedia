class Book {
  // 요소들
  String id;
  String title;
  String subtitle;
  List authors;
  String publishedDate;
  String thumbnail; // 썸네일 이미지 링크
  String previewLink; // ListTile 을 눌렀을 때 이동하는 링크

  Book({
    // 소괄호는 클래스 이름과 같은 함수 = 생성자
    // 중괄호안은 이름을 지정해주는 파라미터
    required this.id,
    required this.title,
    required this.subtitle,
    required this.authors,
    required this.publishedDate,
    required this.thumbnail,
    required this.previewLink,
  });

  // SharedPreferences는 객체(여기서는 Book객체)를 그대로 저장할수 없고, String 형태로 바꿔야 하기 때문
  // 한번 Map형태로 바꾼 후 -> String으로

  Map toJson() {
    // 각각 변수를 Map 형태로 만들어줌
    return {
      "id": id,
      "title": title,
      "authors": authors,
      "publishedDate": publishedDate,
      "thumbnail": thumbnail,
      "previewLink": previewLink,
    };
  }

  // json 의 key값으로 다시 다 가져옴
  factory Book.fromJson(json) {
    return Book(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      authors: json['authors'],
      publishedDate: json['publishedDate'],
      thumbnail: json['thumbnail'],
      previewLink: json['previewLink'],
    );
  }
}
