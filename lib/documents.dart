
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_projects/services/permissions.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'package:hive/hive.dart';
import 'app_drawer.dart';
import 'main.dart';
import 'models/models.dart';
import 'constants.dart';
import 'home.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

@immutable
class Documents extends StatefulWidget {
  @override
  State<Documents> createState() => _DocumentsState();
}
class _DocumentsState extends State<Documents>{
  bool isLoading = false;
  bool _showBackToTopButton = false;
  late ScrollController _scrollController;
  String savePath = '';
  double _progress = 0.0;
  bool isDownloading = false;
  String _downloadPerc = '' ;
  late DioClient _dio;
  late var _endpointProvider;
  late Future<APIResponseData> _apiResponseData;
  late List<Document> documentList;

  @override
  void initState() {
    super.initState();
    _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
    _scrollController = ScrollController()
      ..addListener(() {
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
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              //colors: [Color.fromRGBO(255, 239, 186, 1), Color.fromRGBO(255, 255, 255, 1)]
              colors: [startColor, endColor]
          )
      ),
      child: getScaffold(),
    );
  }

  Scaffold getScaffold(){
    List<Document> _documents = ModalRoute.of(context)!.settings.arguments as List<Document>;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        iconTheme: IconThemeData(
            color: appBarTextColor
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: appBarBackgroundColor,
          statusBarIconBrightness: statusBarBrightness,),
        backgroundColor: appBarBackgroundColor,
        bottomOpacity: 0.0,
        elevation: appBarElevation,
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Row(
          children:[
            Text('Connect - Documents',style: TextStyle(
              color:appBarTextColor,
            ),),
            Spacer(),
            IconButton(
              icon: Icon(Icons.sync),
              onPressed: () {
                if(connectionStatus != ConnectivityResult.none){
                  setState(() {
                    isLoading = true;
                  });
                  _apiResponseData = _endpointProvider.fetchDocuments('','');
                  _apiResponseData.then((result) async {
                    if(result.isAuthenticated && result.status){
                      final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
                      setState(() {
                        _documents =  parsed.map<Document>((json) => Document.fromJson(json)).toList();
                        isLoading = false;
                      });
                      var documentsBox = await Hive.openBox<Document>('documentList');
                      documentsBox.clear();
                      documentsBox.addAll(_documents);
                    }
                    else{
                      setState(() {
                        isLoading = false;
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error in data fetching")),
                      );
                    }
                  }).catchError( (error) {
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error in data fetching")),
                    );
                  });
                }
                else{
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("No internet connection. Please check your settings")),
                  );
                }
              },
              color: appBarTextColor,
            )
          ],
        ),
      ),
      endDrawer: AppDrawer(),
      body: isLoading ? refresh(context) : Column(
        children:[
          Container(
            child: isDownloading? Column(
              children :[
                connectionStatus != ConnectivityResult.none ? SizedBox(height:0) : noConnectivityError(),
                LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: Colors.yellow,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
                Text('$_downloadPerc'),
              ],) : Text(''),
          ),

          Expanded(
            child: ListView.builder(
                itemCount: _documents.length,
                itemBuilder: (context, index) {
                  return Card(
                      child: createListTileDocument(_documents,index)
                  );
                }
            ),
          ),
        ],
      ),
      floatingActionButton: _showBackToTopButton == false
          ? null
          : FloatingActionButton(
        onPressed: _scrollToTop,
        child: Icon(Icons.arrow_upward),
      ),
    );
  }
  ListTile createListTileDocument(data,index) {
    return ListTile(
        onTap: () {
          if(connectionStatus != ConnectivityResult.none){
            setState((){
              isDownloading = true;
              _progress = 0.0;
            });
            String attachmentUrl = "https://connect.bcplindia.co.in/MobileAppAPI/DownloadHRDocument?id="+data[index].docId;
            String fileName = data[index].docFileName;
            downloadFile(attachmentUrl,fileName, index);
          }
          else{
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No internet connection. Please check your settings")),
            );
          }
        },
        title: Text(data[index].docDisplayName,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 18,
            )),
        subtitle: Text("Added: "+data[index].docDate,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 15,
              color: Colors.blue[500],
            )),
        leading: CircleAvatar(
          backgroundColor: RandomColorModel().getColor(),
          child: Text(data[index].docDisplayName.substring(0,1).toUpperCase(),style: TextStyle(
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
        trailing: CircleAvatar(
          backgroundColor: Colors.black12,
          child: Icon(Icons.download,size:20,color:Colors.black38),
        ),
    );
  }

  Future<void> downloadFile(String url, String fileName, int index) async {
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
            finalSavePath, onReceiveProgress: (int received, int total) {
              if (total != -1) {
                double val = (received / total * 100) as double;
                num mod = pow(10.0, 1);
                setState(() {
                  _downloadPerc = 'Downloading: ' + val.toStringAsFixed(2) + ' %';
                  _progress = val / 100;
                });
              }
            });
        result['isSuccess'] = response.statusCode == 200;
        result['contentType'] = 'FileDownload';
        result['filePath'] = finalSavePath;
      } catch (ex) {
        result['error'] = ex.toString();
        setState((){
          isDownloading = false;
          _progress = 0.0;
          _downloadPerc = '';
        });
      }
      finally {
        setState((){
          isDownloading = false;
          _progress = 0.0;
          _downloadPerc = '';
        });
        await showNotification(result);
      }
    }
  }
  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 3), curve: Curves.linear);
  }
  @override
  void dispose() {
    _scrollController.dispose(); // dispose the controller
    super.dispose();
  }
}
// @immutable
// class DocumentList extends StatefulWidget {
//
//   final String docName;
//   final String docType;
//
//   DocumentList(this.docName, this.docType);
//
//   @override
//   State<DocumentList> createState() => _DocumentListState();
// }
// class _DocumentListState extends State<DocumentList>{
//
//   late List<Document> _docList;
//   late Future<APIResponseData> _apiResponseData;
//   bool isLoading = true;
//   String savePath = '';
//   String _progress = '';
//   bool _showBackToTopButton = false;
//   late ScrollController _scrollController;
//
//   @override
//   void initState() {
//     super.initState();
//     DioClient _dio = new DioClient();
//     var _endpointProvider = new EndPointProvider(_dio.init());
//     _apiResponseData = _endpointProvider.fetchDocuments(widget.docName,widget.docType);
//     _apiResponseData.then((result) {
//       if(result.isAuthenticated && result.status){
//         final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
//         setState(() {
//           _docList =  parsed.map<Document>((json) => Document.fromJson(json)).toList();
//           isLoading = false;
//         });
//       }
//     });
//     _scrollController = ScrollController()
//       ..addListener(() {
//         setState(() {
//           if (_scrollController.offset >= 400) {
//             _showBackToTopButton = true; // show the back-to-top button
//           } else {
//             _showBackToTopButton = false; // hide the back-to-top button
//           }
//         });
//       });
//   }
//   @override
//   void dispose() {
//     _scrollController.dispose(); // dispose the controller
//     super.dispose();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: Container(
//           width: 40,
//           child: Image.asset('images/bcpl_logo.png'),
//         ),
//         title: Text('Connect'),
//       ),
//       endDrawer: AppDrawer(),
//       body: isLoading? Container(
//         height: MediaQuery.of(context).size.height / 1.3,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               CircularProgressIndicator(),
//               Container(
//                 padding: EdgeInsets.all(10),
//                 child:Text('Getting your data. Please wait...',style: TextStyle(
//                   fontWeight: FontWeight.w500,fontSize: 18,),
//                 ),
//               ),
//             ],
//           ),
//         ),
//
//       ) : ListView.builder(
//           itemCount: _docList.length,
//           itemBuilder: (context, index) {
//             //_progress = List<String>.generate(_docList.length,(counter) => "Item $counter");
//             return Card(
//                 child: createListTileDocument(_docList,index)
//             );
//           }
//       ),
//       floatingActionButton: _showBackToTopButton == false
//           ? null
//           : FloatingActionButton(
//         onPressed: _scrollToTop,
//         child: Icon(Icons.arrow_upward),
//       ),
//     );
//   }
//
//   ListView createListDocument(data) {
//     return ListView.builder(
//         itemCount: data.length,
//         itemBuilder: (context, index) {
//           //_progress = List<String>.generate(data.length,(counter) => "Item $counter");
//           return Card(
//               child: createListTileDocument(data,index)
//           );
//         }
//     );
//   }
//   ListTile createListTileDocument(data,index) {
//     return ListTile(
//       onTap: () {
//               String attachmentUrl = "https://connect.bcplindia.co.in/MobileAppAPI/DownloadHRDocument?id="+data[index].docId;
//               String fileName = data[index].docFileName;
//               downloadFile(attachmentUrl,fileName, index);
//             },
//       title: Text(data[index].docDisplayName,
//           style: TextStyle(
//             fontWeight: FontWeight.w400,
//             fontSize: 18,
//           )),
//       subtitle: Text("Added: "+data[index].docDate,
//           style: TextStyle(
//             fontWeight: FontWeight.w400,
//             fontSize: 15,
//             color: Colors.blue[500],
//           )),
//       leading: CircleAvatar(
//           backgroundColor: RandomColorModel().getColor(),
//           child: Text(data[index].docDisplayName.substring(0,1).toUpperCase(),style: TextStyle(
//             color: Colors.black,
//           ),),
//           // backgroundImage: this._loadImageError ? null : NetworkImage("https://connect.bcplindia.co.in/MobileAppAPI/imageFile?empno="+data[index].emp_no),
//           // onBackgroundImageError: this._loadImageError ? null : (dynamic exception, StackTrace? stackTrace){
//           //   this.setState((){
//           //     this._loadImageError = true;
//           //   });
//           // },
//           // child:this._loadImageError? Text(title.substring(0,1).toUpperCase(),style: TextStyle(
//           //   color: Colors.black,
//           // )) : null
//       ),
//       trailing: CircleAvatar(
//         backgroundColor: Colors.black12,
//         child: Icon(Icons.download,size:20,color:Colors.black38),
//       ),
//     );
//   }
//
//   Future<void> downloadFile(String url, String fileName, int index) async {
//     Map<String, dynamic> result = {
//       'isSuccess': false,
//       'filePath': null,
//       'error': null,
//     };
//     String saveDirPath = await getDownloadDirectory();
//     String finalSavePath = path.join(saveDirPath, fileName);
//     final isPermissionStatusGranted = await requestStoragePermissions();
//     if (isPermissionStatusGranted) {
//       try {
//         final Dio _dio = Dio()..interceptors.add(ApiInterceptors());
//         var response = await _dio.download(url,
//             finalSavePath, onReceiveProgress: (int received, int total) {
//               if (total != -1) {
//                 setState(() {
//                   _progress = (received / total * 100) as double;
//                 });
//               }
//             });
//         result['isSuccess'] = response.statusCode == 200;
//         result['filePath'] = finalSavePath;
//       } catch (ex) {
//         result['error'] = ex.toString();
//       }
//       finally {
//         await showNotification(result);
//       }
//     }
//   }
//   void _scrollToTop() {
//     _scrollController.animateTo(0,
//         duration: Duration(seconds: 3), curve: Curves.linear);
//   }
//
//    // void _onReceiveProgress(int received, int total) {
//    //   if (total != -1) {
//    //     setState(() {
//    //       _progress[index] = (received / total * 100).toStringAsFixed(0) + "%";
//    //     });
//    //   }
//    // }
//
// }
//
// class DocumentScreenArguments {
//   final String docId;
//   final String docName;
//   final String docType;
//
//   DocumentScreenArguments(this.docId,this.docName, this.docType);
// }