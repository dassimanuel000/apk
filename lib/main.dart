// ignore_for_file: prefer_const_constructors_in_immutables, prefer_const_constructors, sized_box_for_whitespace, avoid_print, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, use_key_in_widget_constructors, must_be_immutable, unnecessary_new, override_on_non_overriding_member, deprecated_member_use, prefer_final_fields, non_constant_identifier_names

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new Texts(),
    );
  }
}

class Texts extends StatefulWidget {
  const Texts({Key? key}) : super(key: key);

  @override
  _TextsState createState() => _TextsState();
}

class _TextsState extends State<Texts> {
  var keyword = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TextField(
        controller: keyword, //set user_pass controller
        decoration: InputDecoration(
          hintText: 'Search..',
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.all(0),
        ),
        textAlignVertical: TextAlignVertical.center,
        onSubmitted: (value) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MyHomePage(
                  title: keyword.text,
                ),
              ));
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  //late String reims;

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: true,
        forceWebView: true,
        enableJavaScript: true,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  Future getData() async {
    var url = 'http://localhost/tuc/search.php?keyword=${widget.title}';
    var response = await http.get(Uri.parse(url));
    Map<String, dynamic> map = json.decode(response.body);
    List<dynamic> data = map["job"];
    return data;
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  String _text(String link) {
    if (link.contains("indeed")) {
      return "https://i.ibb.co/8j6XTC7/indeed-small.png";
    } else {
      return "https://i.ibb.co/QP8jHZ7/ic-launcher.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text("$_counter" + widget.title),
      ),
      body: Container(
        height: MediaQuery.of(context).size.width + 200.0,
        child: ListView(
          children: [
            FutureBuilder(
              future: getData(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasError) print(snapshot.error);
                return snapshot.hasData
                    ? SingleChildScrollView(
                        physics: ScrollPhysics(),
                        child: Column(children: <Widget>[
                          ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                List list = snapshot.data;
                                print(snapshot.data.length);
                                //list = list['job_alert'];
                                return ExpansionTile(
                                  leading: CircleAvatar(
                                    child: Image.network(
                                        _text(list[index]['link'])),
                                    backgroundColor: Colors.white,
                                  ),
                                  title: Text("${list[index]['post_title ']}"),
                                  children: [
                                    Container(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(children: [
                                          Padding(
                                            padding: EdgeInsets.all(0.0),
                                            child: Text(
                                              "Add to : "
                                              "${list[index]['date']}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(0.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    "${list[index]['post_content']}"),
                                              ],
                                            ),
                                          ),
                                        ]),
                                      ),
                                    ),
                                  ],
                                  trailing: TextButton(
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty
                                            .resolveWith<Color?>(
                                          (Set<MaterialState> states) {
                                            return Colors
                                                .green; // Use the component's default.
                                          },
                                        ),
                                        overlayColor: MaterialStateProperty
                                            .resolveWith<Color?>(
                                                (Set<MaterialState> states) {
                                          Colors
                                              .white; // Defer to the widget's default.
                                        }),
                                      ),
                                      onPressed: () {
                                        _launchURL(list[index]['link']);
                                      },
                                      child: Text(
                                        'Postulez',
                                        style: TextStyle(color: Colors.white),
                                      )),
                                );
                              })
                        ]))
                    : CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
