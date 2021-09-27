import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_projects/services/permissions.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'package:path/path.dart' as path;
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'constants.dart';
import 'home.dart';
import 'main.dart';
import 'models/models.dart';

class News extends StatefulWidget {
  @override
  State<News> createState() => _NewsState();
}
class _NewsState extends State<News>{

  late Future<NewsContent> contentData;
  late Future<List<NewsContent>> _contentData;
  @override
  void initState() {
    super.initState();
    _contentData = fetchContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Text('Connect - News & Events'),
      ),
      endDrawer: AppDrawer(),
      body: getNews(),
    );
  }

  FutureBuilder getNews(){
    return FutureBuilder<List<NewsContent>>(
      future: _contentData,
      builder: (BuildContext context, AsyncSnapshot<List<NewsContent>> snapshot){
        if (snapshot.hasData) {
          List<NewsContent>? data = snapshot.data;
          print(data![0].contentTitle);
          return createListNews(data);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return SizedBox(
          height: MediaQuery.of(context).size.height / 1.3,
          child: Center(
            child: Column(
              children: <Widget>[
                CircularProgressIndicator(),
                Container(
                  padding: EdgeInsets.all(10),
                  child:Text('Fetching Data. Please Wait...',style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),),
                ),
              ],
            ),
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
      leading: CircleAvatar(
        backgroundColor: RandomColorModel().getColor(),
        child: Text(data[index].contentTitle.substring(0,1).toUpperCase(),style: TextStyle(
          color: Colors.black,
        ),),
        // backgroundImage: this._loadImageError ? null : NetworkImage("https://connect.bcplindia.co.in/MobileAppAPI/imageFile?empno="+data[index].emp_no),
        // onBackgroundImageError: this._loadImageError ? null : (dynamic exception, StackTrace? stackTrace){
        //   this.setState((){
        //     this._loadImageError = true;
        //   });
        // },
        // child:this._loadImageError? Text(title.substring(0,1).toUpperCase(),style: TextStyle(
        //   color: Colors.black,
        // )) : null
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
  String _progress = "-";
  late Future<List<NewsAttachment>> _attachmentDataFuture;
  late List<NewsAttachment> _attachmentData;

  @override
  void initState(){
    super.initState();
    _attachmentDataFuture = fetchContentAttachments(widget.contentId,"News");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Text('Connect - News & Events'),
      ),
      endDrawer: AppDrawer(),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Card(
                  elevation: 10,
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color:Color.fromRGBO(254, 249, 248, 1),
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Column(
                      children: [
                        Text(widget.contentTitle,
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            )),
                        Container(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child:Text('Date: '+widget.creationDate,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.blue,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 5,
                  margin: EdgeInsets.only(top: 10,left: 5,right:5),

                  child: Container(
                    decoration: BoxDecoration(
                      color:Color.fromRGBO(254, 253, 249, 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    //color: Colors.amber[500],
                    child: Html(data: widget.contentDescription,style: {"body": Style(
                      fontSize: FontSize(18.0),
                      fontWeight: FontWeight.w400,
                      textAlign: TextAlign.justify,
                    ),
                    },
                    ) ,
                  ),
                ),
              ],
            ),
          ),
          createImageGrid1(),
        ],

            // Container(
            //   //color: Colors.amber[100],
            //     child: ElevatedButton(
            //       onPressed: (){
            //         downloadFile(widget.contentId.toString());
            //       },
            //       child: const Text('Download'),
            //     )
            // ),
            // Container(
            //   //color: Colors.amber[100],
            //   child: Center(
            //     child:  Column(
            //       mainAxisAlignment: MainAxisAlignment.center,
            //       children: <Widget>[
            //         Text(
            //           'Download progress:',
            //         ),
            //         Text(
            //           '$_progress',
            //           style: TextStyle(color: Colors.red),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

      ),
    );
  }


  FutureBuilder getImage(){
    return FutureBuilder<List<NewsAttachment>>(
      future: _attachmentDataFuture,
      builder: (BuildContext context, AsyncSnapshot<List<NewsAttachment>> snapshot)
      {
        if (snapshot.hasData) {
          List<NewsAttachment>? _attachmentData = snapshot.data;
          //return createImageGrid1(_attachmentData);
        } else if (snapshot.hasError) {
          return Text("${snapshot.error}");
        }
        return SizedBox(
          height: MediaQuery.of(context).size.height / 1.3,
          child: Center(
            child: Column(
              children: <Widget>[
                CircularProgressIndicator(),
                Container(
                  padding: EdgeInsets.all(10),
                  child:Text('Fetching Data. Please Wait...',style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  SliverGrid createImageGrid1(){
    return SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return FutureBuilder(
                future: _attachmentDataFuture ,
                builder: (BuildContext context, AsyncSnapshot<List<NewsAttachment>> snapshot)
                {

                  if (snapshot.hasData) {
                    List<NewsAttachment>? _attachmentData = snapshot.data;
                    return InkWell(
                      onTap: (){
                        showDialog("https://connect.bcplindia.co.in/MobileAppAPI/Download?id="+_attachmentData![index].attachmentID.toString());
                        //Navigator.of(context).push(MaterialPageRoute(builder: (context) => SliderShowFullmages(listImagesModel: list, current: _current)));
                      },
                      child:Image.network("https://connect.bcplindia.co.in/MobileAppAPI/Download?id="+_attachmentData![index].attachmentID.toString()),
                    );
                    //return createImageGrid1(_attachmentData);
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 1.3,
                    child: Center(
                      child: Column(
                        children: <Widget>[
                          CircularProgressIndicator(),
                          Container(
                            padding: EdgeInsets.all(10),
                            child:Text('Fetching Data. Please Wait...',style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
              return InkWell(
                       onTap: (){
                         showDialog("https://connect.bcplindia.co.in/MobileAppAPI/Download?id="+_attachmentData[index].attachmentID.toString());
                         //Navigator.of(context).push(MaterialPageRoute(builder: (context) => SliderShowFullmages(listImagesModel: list, current: _current)));
                      },
                       child:Image.network("https://connect.bcplindia.co.in/MobileAppAPI/Download?id="+_attachmentData[index].attachmentID.toString()),
                     );
        },
        childCount: _attachmentData.length,
      ),
        // itemCount: _attachmentData.length,
        // itemBuilder: (BuildContext context, int index) {
        //   return InkWell(
        //     onTap: (){
        //       showDialog("https://connect.bcplindia.co.in/MobileAppAPI/Download?id="+_attachmentData[index].attachmentID.toString());
        //       //Navigator.of(context).push(MaterialPageRoute(builder: (context) => SliderShowFullmages(listImagesModel: list, current: _current)));
        //     },
        //     child:Image.network("https://connect.bcplindia.co.in/MobileAppAPI/Download?id="+_attachmentData[index].attachmentID.toString()),
        //   );
        // },
    );
  }
  GridView createImageGrid(_attachmentData){
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 5,
      mainAxisSpacing: 5,
      padding: EdgeInsets.all(10.0), // 3px padding all around
      shrinkWrap: true,
      children: <Widget>[
        InkWell(
          onTap: (){
            showDialog("https://connect.bcplindia.co.in/MobileAppAPI/Download?id="+_attachmentData[0].attachmentID.toString());
            //Navigator.of(context).push(MaterialPageRoute(builder: (context) => SliderShowFullmages(listImagesModel: list, current: _current)));
          },
          child:Image.network("https://connect.bcplindia.co.in/MobileAppAPI/Download?id="+_attachmentData[0].attachmentID.toString()),
        ),
      ],
    );
  }

  showDialog(String url){
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(1), // Background color
      barrierDismissible: false,
      barrierLabel: 'Dialog',
      transitionDuration: Duration(milliseconds: 400), // How long it takes to popup dialog after button click
      pageBuilder: (_, __, ___) {
        // Makes widget fullscreen
        return SizedBox.expand(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 10,
                child: SizedBox.expand(child: Image.network(url)),
              ),
              Expanded(
                flex: 1,
                child: SizedBox.expand(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Close',
                          style: TextStyle(fontSize: 18),
                        ),
                        Icon(Icons.cancel,size:20),
                      ],
                    ),

                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Card createPhotoGallery(_attachmentData){
    return Card(
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage("https://connect.bcplindia.co.in/MobileAppAPI/Download?id="+_attachmentData[index].attachmentID.toString()),
              initialScale: PhotoViewComputedScale.contained * 0.8,
              minScale: PhotoViewComputedScale.contained * 0.8,
              maxScale: PhotoViewComputedScale.covered * 1.1,
              heroAttributes: PhotoViewHeroAttributes(tag: _attachmentData[index].attachmentID.toString()),
            );
          },
          itemCount: _attachmentData.length,
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!.toInt(),
              ),
            ),
          ),
          //backgroundDecoration: widget.backgroundDecoration,
          //pageController: widget.pageController,
          //onPageChanged: onPageChanged,
        )
    );
  }

  Future<void> downloadFile(String id) async {
    String savePath = await getDownloadDirectory();
    final isPermissionStatusGranted = await requestStoragePermissions();
    if(isPermissionStatusGranted){
      try {
        final Dio _dio = Dio();
        //var response = await _dio.download("https://connect.bcplindia.co.in/MobileAppAPI/Download1?id=5902",
            //savePath, onReceiveProgress: _onReceiveProgress);
        var response = await _dio.get("https://connect.bcplindia.co.in/MobileAppAPI/Download1?id=5902");
        if (response.statusCode == 200) {
          //print(response.data);
        }
      } catch (e) { }
    }
  }
  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
      });
    }
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
