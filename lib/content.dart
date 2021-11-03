import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_projects/services/permissions.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as path;
import 'app_drawer.dart';
import 'constants.dart';
import 'fonts_icons/connect_app_icon_icons.dart';
import 'home.dart';
import 'main.dart';
import 'models/models.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:open_file/open_file.dart';

import 'models/models.dart';


class News extends StatefulWidget {
  @override
  State<News> createState() => _NewsState();
}
class _NewsState extends State<News>{

  late Future<NewsContent> contentData;
  //late Future<List<NewsContent>> _contentData;
  late Future<APIResponseData> _apiResponseData;
  late var _endpointProvider;
  List<NewsContent> _contentData = <NewsContent>[];
  bool _showBackToTopButton = false;
  late ScrollController _scrollController;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    DioClient _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
    final newsContentBox = Hive.box<NewsContent>('newsContent');
    if(newsContentBox.values.isEmpty){
      if(connectionStatus != ConnectivityResult.none){
        _apiResponseData = _endpointProvider.fetchNews();
        _apiResponseData.then((result) {
          if(result.isAuthenticated && result.status){
            final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
            setState(() {
              _contentData =  parsed.map<NewsContent>((json) => NewsContent.fromJson(json)).toList();
              isLoading = false;
            });
            newsContentBox.addAll(_contentData);
          }
        });
      }
      else{
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No internet connection. Please check your settings")),
        );
      }

    }
    else{
      setState(() {
        _contentData =  newsContentBox.values.toList();
        isLoading = false;
      });
    }

    _scrollController = ScrollController()..addListener(() {
        setState(() {
          if (_scrollController.offset >= 400) {
            _showBackToTopButton = true; // show the back-to-top button
          } else {
            _showBackToTopButton = false; // hide the back-to-top button
          }
        });
      });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Row(
          children:[
            Text('News & Events'),
            Spacer(),
            IconButton(
              icon: Icon(Icons.sync),
              onPressed: () {
                if(connectionStatus != ConnectivityResult.none){
                  setState(() {
                    isLoading = true;
                  });
                  _apiResponseData = _endpointProvider.fetchNews();
                  _apiResponseData.then((result) {
                    if(result.isAuthenticated && result.status){
                      final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                      setState(() {
                        _contentData =  parsed.map<NewsContent>((json) => NewsContent.fromJson(json)).toList();
                        isLoading = false;
                      });
                      final newsContentBox = Hive.box<NewsContent>('newsContent');
                      newsContentBox.clear();
                      newsContentBox.addAll(_contentData);
                    }
                  });
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("No internet connection. Please check your settings")),
                  );
                }
              },
              color: Colors.white,
            )
          ],
        ),
      ),
      endDrawer: AppDrawer(),
      body: isLoading? waiting(context) : ListView.builder(
          controller: _scrollController,
          itemCount: _contentData.length,
          itemBuilder: (context, index) {
            return Card(
                child: createListTileNews(_contentData,index, Icons.article)
            );
          }
      ),
      floatingActionButton: _showBackToTopButton == false
          ? null
          : FloatingActionButton(
        onPressed: _scrollToTop,
        child: Icon(Icons.arrow_upward),
      ),
    );
  }


  // FutureBuilder getNews(){
  //   return FutureBuilder<List<NewsContent>>(
  //     future: _contentData,
  //     builder: (BuildContext context, AsyncSnapshot<List<NewsContent>> snapshot){
  //       if (snapshot.hasData) {
  //         List<NewsContent>? data = snapshot.data;
  //         print(data![0].contentTitle);
  //         return createListNews(data);
  //       } else if (snapshot.hasError) {
  //         return Text("${snapshot.error}");
  //       }
  //       return Container(
  //         height: MediaQuery.of(context).size.height / 1.3,
  //         child: Center(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: <Widget>[
  //               CircularProgressIndicator(),
  //               Container(
  //                 padding: EdgeInsets.all(10),
  //                 child:Text('Fetching Data. Please Wait...',style: TextStyle(
  //                   fontWeight: FontWeight.w500,
  //                   fontSize: 18,
  //                 ),),
  //               ),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }
  ListView createListNews(data) {
    return ListView.builder(
        controller: _scrollController,
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

  // This function is triggered when the user presses the back-to-top button
  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 3), curve: Curves.linear);
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

class _NewsDetailsState extends State<NewsDetails> {
  String _progress = "";
  late Future<APIResponseData> _apiResponseData;
  //late Future<List<NewsAttachment>> _attachmentDataFuture;
  List<NewsAttachment> _attachmentData = [];
  int gridImageCount = 1;

  @override
  void initState() {
    DioClient _dio = new DioClient();
    var _endpointProvider = new EndPointProvider(_dio.init());
    if(connectionStatus != ConnectivityResult.none){
      _apiResponseData = _endpointProvider.fetchContentAttachments(widget.contentId, "News");
      _apiResponseData.then((result) {
        if(result.isAuthenticated && result.status){
          final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
          setState(() {
            _attachmentData =  parsed.map<NewsAttachment>((json) => NewsAttachment.fromJson(json)).toList();
          });
        }
      }).catchError( (error) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error in fetching data")),
        );
      });
    }
    else{
      /*ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No internet connection. Please check your settings")),
      );*/
    }

    super.initState();
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
                connectionStatus != ConnectivityResult.none ? SizedBox(height:0) : noConnectivityError(),
                Card(
                  elevation: 10,
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(254, 249, 248, 1),
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
                            child: Text('Date: ' + widget.creationDate,
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
                  margin: EdgeInsets.only(top: 10, left: 5, right: 5),

                  child: Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(254, 253, 249, 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    //color: Colors.amber[500],
                    child: Html(
                      data: widget.contentDescription, style: {"body": Style(
                      fontSize: FontSize(18.0),
                      fontWeight: FontWeight.w400,
                      textAlign: TextAlign.justify,
                    ),
                    },
                    ),
                  ),
                ),
              ],
            ),
          ),
          getImage(),
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

  Widget getImage(){
    return SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
        delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index){
              String attachmentUrl = "https://connect.bcplindia.co.in/MobileAppAPI/Download?id=" +
                  _attachmentData[index].attachmentID.toString();
              String fileName = _attachmentData[index].attachmentFileName;
              String fileType = _attachmentData[index].attachmentFileType;

              if (fileType.contains("image/")) {
                return InkWell(
                  onTap: () {
                    showDialog(attachmentUrl);
                  },
                  child: CachedNetworkImage(
                    imageUrl: attachmentUrl,
                    placeholder: (context, url) =>
                        SizedBox(width: 50,
                            height: 50,
                            child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                );
              }
              else if (fileType == "application/pdf") {
                return InkWell(
                  onTap: () {
                    downloadFile(attachmentUrl, fileName);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(ConnectAppIcon.file_pdf, size: 40, color: Colors.red),
                      Text('Download PDF',
                          style: TextStyle(fontSize: 15, color: Colors.black),
                          textAlign: TextAlign.center),
                      Text('$_progress', style: TextStyle(
                          color: Colors.red, fontSize: 15),),
                    ],
                  ),

                );
              }
              else if (fileType == "application/msword") {
                return InkWell(
                  onTap: () {
                    downloadFile(attachmentUrl, fileName);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(ConnectAppIcon.file_word, size: 40, color: Colors
                          .blue),
                      Text('Download PDF',
                          style: TextStyle(fontSize: 15, color: Colors.black),
                          textAlign: TextAlign.center),
                      Text('$_progress', style: TextStyle(
                          color: Colors.red, fontSize: 15),),
                    ],
                  ),
                );
              }
              else if (fileType == "application/vnd.ms-excel") {
                return InkWell(
                  onTap: () {
                    downloadFile(attachmentUrl, fileName);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(ConnectAppIcon.file_excel, size: 40,
                          color: Colors.green),
                      Text('Download PDF',
                          style: TextStyle(fontSize: 15, color: Colors.black),
                          textAlign: TextAlign.center),
                      Text('$_progress',
                        style: TextStyle(color: Colors.red, fontSize: 15),),
                    ],
                  ),
                );
              }
              else if (fileType.contains("video/")) {
                return Center(
                  child: Text('Video'),
                );
              }
              else {
                return Center(
                  child: Text('Invalid Type'),
                );
              }
            },
          childCount: _attachmentData.length,
        ),
    );
  }
/*  Widget getImage1() {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2),
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
          return FutureBuilder(
            future: _apiResponseData,
            builder: (context, AsyncSnapshot<APIResponseData> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                WidgetsBinding.instance!.addPostFrameCallback((_) {
                  final parsed = jsonDecode(snapshot.data!.data ?? '').cast<Map<String, dynamic>>();
                  setState(() {
                    _attachmentData =  parsed.map<NewsAttachment>((json) => NewsAttachment.fromJson(json)).toList();
                    gridImageCount = _attachmentData.length;
                  });
*//*                  setState(() {
                    gridImageCount = snapshot.data!.length;
                  });*//*
                });

                if(_attachmentData.isNotEmpty){
                  String attachmentUrl = "https://connect.bcplindia.co.in/MobileAppAPI/Download?id=" +
                      _attachmentData![index].attachmentID.toString();
                  String fileName = _attachmentData![index].attachmentFileName;

                  if (_attachmentData![index].attachmentFileType.contains(
                      "image/")) {
                    return InkWell(
                      onTap: () {
                        showDialog(attachmentUrl);
                      },
                      child: CachedNetworkImage(
                        imageUrl: attachmentUrl,
                        placeholder: (context, url) =>
                            SizedBox(width: 50,
                                height: 50,
                                child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    );
                  }
                  else if (_attachmentData![index].attachmentFileType ==
                      "application/pdf") {
                    return InkWell(
                      onTap: () {
                        downloadFile(attachmentUrl, fileName);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(ConnectAppIcon.file_pdf, size: 40, color: Colors.red),
                          Text('Download PDF',
                              style: TextStyle(fontSize: 15, color: Colors.black),
                              textAlign: TextAlign.center),
                          Text('$_progress', style: TextStyle(
                              color: Colors.red, fontSize: 15),),
                        ],
                      ),

                    );
                  }
                  else if (_attachmentData![index].attachmentFileType ==
                      "application/msword") {
                    return InkWell(
                      onTap: () {
                        downloadFile(attachmentUrl, fileName);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(ConnectAppIcon.file_word, size: 40, color: Colors
                              .blue),
                          Text('Download PDF',
                              style: TextStyle(fontSize: 15, color: Colors.black),
                              textAlign: TextAlign.center),
                          Text('$_progress', style: TextStyle(
                              color: Colors.red, fontSize: 15),),
                        ],
                      ),
                    );
                  }
                  else if (_attachmentData![index].attachmentFileType ==
                      "application/vnd.ms-excel") {
                    return InkWell(
                      onTap: () {
                        downloadFile(attachmentUrl, fileName);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(ConnectAppIcon.file_excel, size: 40,
                              color: Colors.green),
                          Text('Download PDF',
                              style: TextStyle(fontSize: 15, color: Colors.black),
                              textAlign: TextAlign.center),
                          Text('$_progress',
                            style: TextStyle(color: Colors.red, fontSize: 15),),
                        ],
                      ),
                    );
                  }
                  else if (_attachmentData![index].attachmentFileType.contains(
                      "video/")) {
                    return Center(
                      child: Text('Video'),
                    );
                  }
                  else {
                    return Center(
                      child: Text('Invalid Type'),
                    );
                  }
                }
                else {
                  return Center(
                    child: Text('Please Wait...'),
                  );
                }

              }
              else {
                return Center(
                  child: Text('Please Wait...'),
                );
              }
            },
          );
        },
        childCount: gridImageCount,
      ),
    );
  }*/

  showDialog(String url) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(1),
      // Background color
      barrierDismissible: false,
      barrierLabel: 'Dialog',
      transitionDuration: Duration(milliseconds: 400),
      // How long it takes to popup dialog after button click
      pageBuilder: (_, __, ___) {
        // Makes widget fullscreen
        return SizedBox.expand(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 10,
                child: SizedBox.expand(child: CachedNetworkImage(
                  imageUrl: url,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),),
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
                        Icon(Icons.cancel, size: 20),
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

  Future<void> downloadFile(String url, String fileName) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'contentType': false,
      'filePath': null,
      'error': null,
    };
    String saveDirPath = await getDownloadDirectory();
    String finalSavePath = path.join(saveDirPath, fileName);
    final isPermissionStatusGranted = await requestStoragePermissions();
    if (isPermissionStatusGranted) {
      try {
        final Dio _dio = Dio();
        var response = await _dio.download(url,
            finalSavePath, onReceiveProgress: _onReceiveProgress);
        result['isSuccess'] = response.statusCode == 200;
        result['contentType'] = 'FileDownload';
        result['filePath'] = finalSavePath;
      } catch (ex) {
        result['error'] = ex.toString();
      }
      finally {
        await showNotification(result);
      }
    }
  }

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress =
            "Downlading File: " + (received / total * 100).toStringAsFixed(0) +
                "%";
      });
    }
  }
}

class NewsDisplay extends StatefulWidget {
  final String contentID;
  NewsDisplay(this.contentID);

  @override
  State<NewsDisplay> createState() => _NewsDisplayState();
}
class _NewsDisplayState extends State<NewsDisplay> {
  String _progress = "";
  bool isLoading = true;
  late Future<APIResponseData> _apiResponseData;
  late NewsContentWithAttachment content;
  late EndPointProvider _endpointProvider;
  int gridImageCount = 1;

  @override
  void initState() {
    DioClient _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
    _apiResponseData = _endpointProvider.fetchSingleContent(widget.contentID, "News");
    _apiResponseData.then((result) {
      if(result.isAuthenticated && result.status){
        setState(() {
          content = NewsContentWithAttachment.fromJson(jsonDecode(result.data ?? ''));
          isLoading = false;
        });
      }
    }).catchError( (error) {
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error in fetching data")),
      );
    });
    super.initState();
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
      body: isLoading? waiting(context) : getContentFromId(),
    );
  }

   Widget getContentFromId(){
     return CustomScrollView(
       slivers: <Widget>[
         SliverList(
           delegate: SliverChildListDelegate(
             [
               Card(
                 elevation: 10,
                 child: Container(
                   padding: EdgeInsets.all(10.0),
                   decoration: BoxDecoration(
                     color: Color.fromRGBO(254, 249, 248, 1),
                     borderRadius: BorderRadius.circular(12),
                   ),

                   child: Column(
                     children: [
                       Text(content.contentTitle,
                           textAlign: TextAlign.justify,
                           style: TextStyle(
                             fontWeight: FontWeight.bold,
                             fontSize: 18,
                           )),
                       Container(
                         padding: EdgeInsets.only(top: 10.0),
                         child: Align(
                           alignment: Alignment.centerLeft,
                           child: Text('Date: ' + content.creationDate,
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
                 margin: EdgeInsets.only(top: 10, left: 5, right: 5),

                 child: Container(
                   decoration: BoxDecoration(
                     color: Color.fromRGBO(254, 253, 249, 1),
                     borderRadius: BorderRadius.circular(12),
                   ),
                   //color: Colors.amber[500],
                   child: Html(
                     data: content.contentDescription, style: {"body": Style(
                     fontSize: FontSize(18.0),
                     fontWeight: FontWeight.w400,
                     textAlign: TextAlign.justify,
                   ),
                   },
                   ),
                 ),
               ),
             ],
           ),
         ),
         getImage(),
       ],
     );
  }
  Widget getImage(){
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index){
          String attachmentUrl = "https://connect.bcplindia.co.in/MobileAppAPI/Download?id=" +
              content.attachments[index].attachmentID.toString();
          String fileName = content.attachments[index].attachmentFileName;
          String fileType = content.attachments[index].attachmentFileType;

          if (fileType.contains("image/")) {
            return InkWell(
              onTap: () {
                showDialog(attachmentUrl);
              },
              child: CachedNetworkImage(
                imageUrl: attachmentUrl,
                placeholder: (context, url) =>
                    SizedBox(width: 50,
                        height: 50,
                        child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            );
          }
          else if (fileType == "application/pdf") {
            return InkWell(
              onTap: () {
                downloadFile(attachmentUrl, fileName);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(ConnectAppIcon.file_pdf, size: 40, color: Colors.red),
                  Text('Download PDF',
                      style: TextStyle(fontSize: 15, color: Colors.black),
                      textAlign: TextAlign.center),
                  Text('$_progress', style: TextStyle(
                      color: Colors.red, fontSize: 15),),
                ],
              ),

            );
          }
          else if (fileType == "application/msword") {
            return InkWell(
              onTap: () {
                downloadFile(attachmentUrl, fileName);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(ConnectAppIcon.file_word, size: 40, color: Colors
                      .blue),
                  Text('Download PDF',
                      style: TextStyle(fontSize: 15, color: Colors.black),
                      textAlign: TextAlign.center),
                  Text('$_progress', style: TextStyle(
                      color: Colors.red, fontSize: 15),),
                ],
              ),
            );
          }
          else if (fileType == "application/vnd.ms-excel") {
            return InkWell(
              onTap: () {
                downloadFile(attachmentUrl, fileName);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(ConnectAppIcon.file_excel, size: 40,
                      color: Colors.green),
                  Text('Download PDF',
                      style: TextStyle(fontSize: 15, color: Colors.black),
                      textAlign: TextAlign.center),
                  Text('$_progress',
                    style: TextStyle(color: Colors.red, fontSize: 15),),
                ],
              ),
            );
          }
          else if (fileType.contains("video/")) {
            return Center(
              child: Text('Video'),
            );
          }
          else {
            return Center(
              child: Text('Invalid Type'),
            );
          }
        },
        childCount: content.attachments.length,
      ),
    );
  }

  showDialog(String url) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black12.withOpacity(1),
      // Background color
      barrierDismissible: false,
      barrierLabel: 'Dialog',
      transitionDuration: Duration(milliseconds: 400),
      // How long it takes to popup dialog after button click
      pageBuilder: (_, __, ___) {
        // Makes widget fullscreen
        return SizedBox.expand(
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 10,
                child: SizedBox.expand(child: CachedNetworkImage(
                  imageUrl: url,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),),
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
                        Icon(Icons.cancel, size: 20),
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

  Future<void> downloadFile(String url, String fileName) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'contentType': false,
      'filePath': null,
      'error': null,
    };
    String saveDirPath = await getDownloadDirectory();
    String finalSavePath = path.join(saveDirPath, fileName);
    final isPermissionStatusGranted = await requestStoragePermissions();
    if (isPermissionStatusGranted) {
      try {
        final Dio _dio = Dio();
        var response = await _dio.download(url,
            finalSavePath, onReceiveProgress: _onReceiveProgress);
        result['isSuccess'] = response.statusCode == 200;
        result['contentType'] = 'FileDownload';
        result['filePath'] = finalSavePath;
      } catch (ex) {
        result['error'] = ex.toString();
      }
      finally {
        await showNotification(result);
      }
    }
  }

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress =
            "Downlading File: " + (received / total * 100).toStringAsFixed(0) +
                "%";
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
