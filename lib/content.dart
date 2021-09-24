import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_projects/services/webservice.dart';

import 'account.dart';
import 'constants.dart';
import 'home.dart';
import 'models/models.dart';

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
          return createListNews(data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return SizedBox(
          height: MediaQuery.of(context).size.height / 1.3,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
  ListView createListNews(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Card(
              child: createListTileNews(data,index, Icons.article)
          );
        }
    );
  }
  ListTile createListTileNews(data,index, IconData icon) {
    return ListTile(
      onTap: (){
        Navigator.pushNamed(context, newsDetailsRoute, arguments: NewsContentArguments(
            data[index].contentId ?? 0,data[index].contentType ?? '',data[index].contentTitle ?? '',data[index].contentDescription ?? '',
            data[index].creationDate ?? ''
          ),
        );
      },
      title: Text(data[index].contentTitle,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
          )),
      subtitle: Text(data[index].creationDate,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 15,
            color: Colors.blue[500],
          )),
      leading: Icon(
        icon,
        color: Colors.blue[500],
      ),
    );
  }
}
class NewsDetails extends StatefulWidget {
  final int contentId;
  final String contentType;
  final String contentTitle;
  final String contentDescription;
  final String creationDate;

  NewsDetails(this.contentId, this.contentType,this.contentTitle, this.contentDescription,
      this.creationDate);

  @override
  State<NewsDetails> createState() => _NewsDetailsState();
}
class _NewsDetailsState extends State<NewsDetails>{

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
      body: ListView(
        padding: EdgeInsets.all(10.0),
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            //color: Colors.amber[600],

            child: Text(widget.contentTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                )),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            //color: Colors.amber[500],
            child: Text('Date: '+widget.creationDate,
                style: TextStyle(
                  fontWeight: FontWeight.bold,

                  fontSize: 15,
                )),
          ),
          Container(
            //color: Colors.amber[100],
            child: Html(data: widget.contentDescription) ,
          ),
        ],
      ),
    );
  }
}
class NewsContentArguments{
  final int contentId;
  final String contentType;
  final String contentTitle;
  final String contentDescription;
  final String creationDate;

  NewsContentArguments( this.contentId,  this.contentType,  this.contentTitle,
     this.contentDescription, this.creationDate);
}
