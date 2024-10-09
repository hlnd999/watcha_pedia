import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:watcha_pedia/book.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'book_service.dart';

late SharedPreferences prefs;

void main() async {
  // prefs(SharedPreferences)초기화 해줘야 에러가 안남
  // getInstance()는 Future -> await 걸어줘야 함, async 는 꼭 따라와야 함
  // 비동기로 처리해주려면 WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BookService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var bottomNavIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        SearchPage(),
        LikedBookPage(),
      ].elementAt(bottomNavIndex),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        iconSize: 28,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          setState(() {
            bottomNavIndex = value;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '검색',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: '좋아요',
          ),
        ],
        currentIndex: bottomNavIndex,
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookService>(
      builder: (context, bookService, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            toolbarHeight: 80,
            title: TextField(
              // 'done'버튼 눌렀을때 -> onSubmitted
              onSubmitted: (value) {
                bookService.search(value);
              },
              cursorColor: Colors.grey,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                hintText: "작품, 감독, 배우, 컬렉션, 유저 등",
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
              ),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.separated(
              itemCount: bookService.bookList.length,
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemBuilder: (context, index) {
                if (bookService.bookList.isEmpty) return SizedBox();
                Book book = bookService.bookList.elementAt(index);
                return BookTile(book: book); // Extract Widget 으로
              },
            ),
          ),
        );
      },
    );
  }
}

class BookTile extends StatelessWidget {
  const BookTile({
    super.key,
    required this.book,
  });

  final Book book;

  @override
  Widget build(BuildContext context) {
    BookService bookService = context.read<BookService>();

    return ListTile(
      // ListTile()의 형태로 보여줌
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(
              url: book.previewLink.replaceFirst("http", "https"),
            ),
          ),
        );
      },
      leading: Image.network(
        book.thumbnail,
        fit: BoxFit.fitHeight,
      ),
      title: Text(
        book.title,
        style: TextStyle(fontSize: 16),
      ),
      subtitle: Text(
        // book.authors.toString(), -> 둘다 문자열로 같이 써주고 싶으면
        // join 쓰면 리스트 안에 있는 요소들을 지정한 구분자로 나누면서 다 문자열로 이어줌
        "${book.authors.join(", ")}\n${book.publishedDate}",
        style: TextStyle(color: Colors.grey),
      ),
      trailing: IconButton(
        onPressed: () {
          bookService.toggleLikeBook(book: book);
        },
        icon: bookService.likedBookList.map((book) => book.id).contains(book.id)
            ? Icon(
                Icons.star,
                color: Colors.amber,
              )
            : Icon(Icons.star_border),
      ),
    );
  }
}

class LikedBookPage extends StatelessWidget {
  const LikedBookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BookService>(
      builder: (context, bookService, child) {
        return Scaffold(
          // Scaffold()를 Wrap with Builder로
          // Builder를 Consumer<BookService>로 변경
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.separated(
              itemCount: bookService.likedBookList.length,
              separatorBuilder: (context, index) {
                return Divider();
              },
              itemBuilder: (context, index) {
                if (bookService.likedBookList.isEmpty) return SizedBox();
                Book book = bookService.likedBookList.elementAt(index);
                return BookTile(book: book);
              },
            ),
          ),
        );
      },
    );
  }
}

class WebViewPage extends StatelessWidget {
  WebViewPage({super.key, required this.url});

  String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text(url),
      ),
      body: WebView(initialUrl: url),
    );
  }
}
