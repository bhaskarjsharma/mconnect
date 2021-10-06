
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/services/permissions.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'main.dart';
import 'models/models.dart';
import 'constants.dart';
import 'home.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class DocumentScreen extends StatefulWidget {
  @override
  State<DocumentScreen> createState() => _DocumentState();
}
class _DocumentState extends State<DocumentScreen>{

  final _formKey = GlobalKey<FormState>();
  final docNameContrl = TextEditingController();
  final docTypeControl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(
          width: 40,
          child: Image.asset('images/bcpl_logo.png'),
        ),
        title: Text('Connect - Documents'),
      ),
      endDrawer: AppDrawer(),
      body: DocumentFinderForm(),
    );
  }

  Form DocumentFinderForm(){
    return Form(
      key: _formKey,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20),
        child:Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(

              padding: EdgeInsets.all(10),
              child: Center(child: Text('Find Documents',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                    color: Colors.blue[500],
                  ))) ,
            ),
            Container(

              padding: EdgeInsets.all(10),
              child: TextFormField(
                controller: docNameContrl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Document Name',
                ),
                // The validator receives the text that the user has entered.
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter some text';
                //   }
                //   return null;
                // },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child:TextFormField(
                controller: docTypeControl,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Document Type',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10.0),
              child: Center( child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, documentListRoute, arguments: DocumentScreenArguments(
                      '',docNameContrl.text,docTypeControl.text),);
                  //Navigator.pushNamed(context, peopleRoute, arguments: 'Data from home');
                  // Validate returns true if the form is valid, or false otherwise.
                  // if (_formKey.currentState!.validate()) {
                  //   // If the form is valid, display a snackbar. In the real world,
                  //   // you'd often call a server or save the information in a database.
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     const SnackBar(content: Text('Fetching Data')),
                  //   );
                  // }
                },
                child: const Text('Submit'),
              ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
@immutable
class DocumentList extends StatefulWidget {

  final String docName;
  final String docType;

  DocumentList(this.docName, this.docType);

  @override
  State<DocumentList> createState() => _DocumentListState();
}
class _DocumentListState extends State<DocumentList>{

  late List<Document> _docList;
  late Future<APIResponseData> _apiResponseData;
  bool isLoading = true;
  String savePath = '';
  //List<String>? _progress;
  List<String>? _progress;
  bool _showBackToTopButton = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    DioClient _dio = new DioClient();
    var _endpointProvider = new EndPointProvider(_dio.init());
    _apiResponseData = _endpointProvider.fetchDocuments(widget.docName,widget.docType);
    _apiResponseData.then((result) {
      if(result.isAuthenticated && result.status){
        final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
        setState(() {
          _docList =  parsed.map<Document>((json) => Document.fromJson(json)).toList();
          isLoading = false;
        });
      }
    });
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
        title: Text('Connect'),
      ),
      endDrawer: AppDrawer(),
      body: isLoading? Container(
        height: MediaQuery.of(context).size.height / 1.3,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              Container(
                padding: EdgeInsets.all(10),
                child:Text('Getting your data. Please wait...',style: TextStyle(
                  fontWeight: FontWeight.w500,fontSize: 18,),
                ),
              ),
            ],
          ),
        ),

      ) : ListView.builder(
          itemCount: _docList.length,
          itemBuilder: (context, index) {
            _progress = List<String>.generate(_docList.length,(counter) => "Item $counter");
            return Card(
                child: createListTileDocument(_docList,index)
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

  // FutureBuilder getDocuments(){
  //   return FutureBuilder<List<Document>>(
  //     future: _docList,
  //     builder: (BuildContext context, AsyncSnapshot<List<Document>> snapshot){
  //       if (snapshot.hasData) {
  //         List<Document>? data = snapshot.data;
  //         return createListDocument(data);
  //       } else if (snapshot.hasError) {
  //         return Text("${snapshot.error}");
  //       }
  //       return SizedBox(
  //         height: MediaQuery.of(context).size.height / 1.3,
  //         child: Center(
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             children: <Widget>[
  //
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
  //
  //         ),
  //       );
  //     },
  //   );
  // }
  ListView createListDocument(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          _progress = List<String>.generate(data.length,(counter) => "Item $counter");
          return Card(
              child: createListTileDocument(data,index)
          );
        }
    );
  }
  ListTile createListTileDocument(data,index) {
    return ListTile(
      onTap: () {
        String attachmentUrl = "https://connect.bcplindia.co.in/MobileAppAPI/DownloadHRDocument?id=" +
            data[index].docId;
        String fileName = data[index].docFileName;
        downloadFile(attachmentUrl,fileName, index);
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
      trailing: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.black12,
            child: Icon(Icons.download,size:20,color:Colors.black38),
          ),
          Text(_progress![index],
            style: TextStyle(color: Colors.red, fontSize: 13),),
        ],
      )
    );
  }

  Future<void> downloadFile(String url, String fileName, int index) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };
    String saveDirPath = await getDownloadDirectory();
    String finalSavePath = path.join(saveDirPath, fileName);
    final isPermissionStatusGranted = await requestStoragePermissions();
    if (isPermissionStatusGranted) {
      try {
        final Dio _dio = Dio()..interceptors.add(ApiInterceptors());
        var response = await _dio.download(url,
            finalSavePath, onReceiveProgress: (int received, int total) {
              if (total != -1) {
                setState(() {
                  _progress![index] = (received / total * 100).toStringAsFixed(0) + "%";
                });
              }
            });
        result['isSuccess'] = response.statusCode == 200;
        result['filePath'] = finalSavePath;
      } catch (ex) {
        result['error'] = ex.toString();
      }
      finally {
        await showNotification(result);
      }
    }
  }
  void _scrollToTop() {
    _scrollController.animateTo(0,
        duration: Duration(seconds: 3), curve: Curves.linear);
  }

   // void _onReceiveProgress(int received, int total) {
   //   if (total != -1) {
   //     setState(() {
   //       _progress[index] = (received / total * 100).toStringAsFixed(0) + "%";
   //     });
   //   }
   // }

}

class DocumentScreenArguments {
  final String docId;
  final String docName;
  final String docType;

  DocumentScreenArguments(this.docId,this.docName, this.docType);
}