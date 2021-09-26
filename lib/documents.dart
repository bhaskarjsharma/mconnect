
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/services/webservice.dart';
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
class DocumentList extends StatefulWidget {

  final String docName;
  final String docType;

  DocumentList(this.docName, this.docType);

  @override
  State<DocumentList> createState() => _DocumentListState();
}
class _DocumentListState extends State<DocumentList>{

  late Future<List<Document>> _docList;
  bool _loadImageError = false;
  String savePath = '';
  @override
  void initState() {
    super.initState();
    _docList = fetchDocuments(widget.docName,widget.docType);
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
      body: getPeople(),
    );
  }

  FutureBuilder getPeople(){
    return FutureBuilder<List<Document>>(
      future: _docList,
      builder: (BuildContext context, AsyncSnapshot<List<Document>> snapshot){
        if (snapshot.hasData) {
          List<Document>? data = snapshot.data;
          return createListDocument(data);
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
  ListView createListDocument(data) {
    return ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Card(
              child: createListTileDocument(data,index)
          );
        }
    );
  }
  ListTile createListTileDocument(data,index) {
    return ListTile(
      onTap: () {
        downloadFile(data[index].docPath,data[index].docFileName);
      },
      title: Text(data[index].docDisplayName,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 18,
          )),
      subtitle: Text("Added: "+data[index].docDate + " Size: "+data[index].docSize,
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
    );
  }

  Future<void> downloadFile(String filePath,String fileName) async {
    final dir = await _getDownloadDirectory();
    final savePath = path.join(dir.path, fileName);

    try {
      var dio = Dio();
      var response = await dio.download(filePath+"/"+fileName,savePath);
    } catch (e) {
      print(e);
    }

    //final isPermissionStatusGranted = await _requestPermissions();

    // if (isPermissionStatusGranted) {
    //   final savePath = path.join(dir.path, _fileName);
    //   await _startDownload(savePath);
    // } else {
    //   // handle the scenario when user declines the permissions
    // }
  }
  Future<Directory> _getDownloadDirectory() async {
    return await getApplicationDocumentsDirectory();
  }
}

class DocumentScreenArguments {
  final String docId;
  final String docName;
  final String docType;

  DocumentScreenArguments(this.docId,this.docName, this.docType);
}