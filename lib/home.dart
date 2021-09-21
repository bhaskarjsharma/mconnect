
import 'dart:convert';

import 'package:flutter_projects/services/webservice.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'account.dart';
import 'models/news.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home>  {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Text('Connect'),
      ),
      endDrawer: AppDrawer(),
      body: Container(
        child: GridView.count(
          crossAxisCount: 3,
          padding: EdgeInsets.all(3.0), // 3px padding all around
          scrollDirection: Axis.vertical,
          children: <Widget>[
            makeDashboardItem("News & Events",Icons.feed,Colors.blue),
            makeDashboardItem("People",Icons.people,Colors.pink),
            makeDashboardItem("Documents",Icons.collections,Colors.green),
            makeDashboardItem("News & Events",Icons.feed,Colors.blue),
            makeDashboardItem("People",Icons.people,Colors.pink),
            makeDashboardItem("Documents",Icons.collections,Colors.green),
            makeDashboardItem("News & Events",Icons.feed,Colors.blue),
            makeDashboardItem("People",Icons.people,Colors.pink),
            makeDashboardItem("Documents",Icons.collections,Colors.green),
            makeDashboardItem("News & Events",Icons.feed,Colors.blue),
            makeDashboardItem("People",Icons.people,Colors.pink),
            makeDashboardItem("Documents",Icons.collections,Colors.green),
            makeDashboardItem("News & Events",Icons.feed,Colors.blue),
            makeDashboardItem("People",Icons.people,Colors.pink),
            makeDashboardItem("Documents",Icons.collections,Colors.green),
            makeDashboardItem("News & Events",Icons.feed,Colors.blue),
            makeDashboardItem("People",Icons.people,Colors.pink),
            makeDashboardItem("Documents",Icons.collections,Colors.green),
            makeDashboardItem("News & Events",Icons.feed,Colors.blue),
            makeDashboardItem("People",Icons.people,Colors.pink),
            makeDashboardItem("Documents",Icons.collections,Colors.green),
            makeDashboardItem("News & Events",Icons.feed,Colors.blue),
            makeDashboardItem("People",Icons.people,Colors.pink),
            makeDashboardItem("Documents",Icons.collections,Colors.green),


          ],
        ),
      ),
    );
  }

  Card makeDashboardItem(String title, IconData icon, MaterialColor colour){
    return Card(
      elevation: 1.0,
      margin: EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(color:Color.fromRGBO(220, 220, 220, 1.0)),

        child: InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => News()));

          },
          child:Column(
            children: [
              Icon(icon,size:40.0,
                color: colour,
              ),
              Text(title,
                  style: TextStyle(fontSize: 15, color: Colors.black),
                  textAlign: TextAlign.center)
            ],
          ),
        ),
      ),
    );
  }
}

class News extends StatefulWidget {
  @override
  State<News> createState() => _NewsState();
}
class _NewsState extends State<News>{

  late Future<NewsContent> contentData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Text('Connect'),
      ),
      endDrawer: AppDrawer(),
      body: getNews(),
    );
  }

  FutureBuilder getNews(){
    return FutureBuilder<List<NewsContent>>(
      future: fetchContent(),
      builder: (BuildContext context, AsyncSnapshot<List<NewsContent>> snapshot){
        if (snapshot.hasData) {
          List<NewsContent>? data = snapshot.data;
          return _newsData(data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return CircularProgressIndicator();
      },
    );
  }

  ListView _newsData(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Card(
              child: _tile(data[index].contentTitle, data[index].contentDescription, Icons.article)
          );
        }
    );
  }

  ListTile _tile(String title, String subtitle, IconData icon) {
    return ListTile(
      title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 20,
          )),
      subtitle: Text(subtitle),
      leading: Icon(
        icon,
        color: Colors.blue[500],
      ),
    );
  }

}

