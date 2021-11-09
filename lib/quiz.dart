
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'app_drawer.dart';
import 'constants.dart';
import 'home.dart';
import 'main.dart';
import 'models/models.dart';

class QuizView extends StatefulWidget {
  const QuizView({Key? key}) : super(key: key);

  @override
  State<QuizView> createState() => _QuizViewState();
}
class _QuizViewState extends State<QuizView>{
  late List<QuizData> quizData;
  late Future<APIResponseData> _apiResponseData;
  late var _endpointProvider;
  bool isLoading = true;
  @override
  initState() {
    super.initState();
    DioClient _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
    if(connectionStatus != ConnectivityResult.none){
      _apiResponseData = _endpointProvider.fetchQuizes();
      _apiResponseData.then((result) {
        if(result.isAuthenticated && result.status){
          final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
          setState(() {
            quizData =  parsed.map<QuizData>((json) => QuizData.fromJson(json)).toList();
            isLoading = false;
          });
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
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [startColor, endColor]
          )
      ),
      child: Scaffold(
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
          title: Text('Connect - People',style: TextStyle(
            color:appBarTextColor,
          ),),
        ),
        endDrawer: AppDrawer(),
        body: isLoading? waiting(context) : ListView.builder(
            itemCount: quizData.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  title: Text(quizData[index].title ?? ''),
                  subtitle: Text(quizData[index].StartTime ?? ''),
                  onTap: () async{
                    Navigator.pushNamed(context, quizDetailRoute, arguments: quizData[index],);
                  },
                ),
              );
            }
        ),
      ),
    );
  }
}

class QuizDetail extends StatefulWidget {
  @override
  State<QuizDetail> createState() => _QuizDetailState();
}
class _QuizDetailState extends State<QuizDetail> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final QuizData quizData = ModalRoute.of(context)!.settings.arguments as QuizData;
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              //colors: [Color.fromRGBO(255, 239, 186, 1), Color.fromRGBO(255, 255, 255, 1)]
              colors: [startColor, endColor]
          )
      ),
      child: Scaffold(
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
          title: Text('Connect - News & Events',style: TextStyle(
            color:appBarTextColor,
          ),),
        ),
        endDrawer: AppDrawer(),
        body: Column(
          children: [
            connectionStatus != ConnectivityResult.none ? SizedBox(height:0) : noConnectivityError(),
            Text(quizData.title,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),),
            ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, quizStartRoute, arguments: quizData,);
                },
                child: Text('Start Quiz'))
          ],
        ),
      ),
    );
  }
}

class QuizStart extends StatefulWidget {
  final QuizData quizData;
  QuizStart(this.quizData);
  @override
  State<QuizStart> createState() => _QuizStartState();
}
class _QuizStartState extends State<QuizStart> with SingleTickerProviderStateMixin{
  int qnsId = 0;
  Color ansColor = Colors.white;
  int _answer = 0;
  Duration _elapsed = Duration.zero;
  late final Ticker _ticker;
  double timer = 0;

  @override
  void initState() {
    super.initState();
    _ticker = this.createTicker((elapsed) {
      setState(() {
        _elapsed = elapsed;
        timer = _elapsed.inSeconds.toDouble() / widget.quizData.timeDuration;
      });
    });
    _ticker.start();
  }
  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    //final QuizData quizData = ModalRoute.of(context)!.settings.arguments as QuizData;
    final QuestionData question = widget.quizData.Questions.elementAt(qnsId) as QuestionData;
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              //colors: [Color.fromRGBO(255, 239, 186, 1), Color.fromRGBO(255, 255, 255, 1)]
              colors: [startColor, endColor]
          )
      ),
      child: Scaffold(
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
          title: Text('Connect - News & Events',style: TextStyle(
            color:appBarTextColor,
          ),),
        ),
        endDrawer: AppDrawer(),
        body: Column(
          children: [
            connectionStatus != ConnectivityResult.none ? SizedBox(height:0) : noConnectivityError(),
            LinearProgressIndicator(
              value: timer,
              backgroundColor: Colors.yellow,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
            ),
            Text('$_elapsed'),
            Text('$timer'),
            SizedBox(height: 20,),
            Card(
              elevation: 10,
              child: Container(
                padding: EdgeInsets.all(20),
                child:Text(question.QuestionText,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),),
              ),
            ),

            Expanded(
              child: Card(
                child: ListView.builder(
                    itemCount: question.AnswerChoices.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(question.AnswerChoices[index].AnswerText ?? ''),
                        leading: Radio<int>(
                          value: question.AnswerChoices[index].AnswerChoiceID,
                          groupValue: _answer,
                          onChanged: (int? value) {
                            setState(() {
                              _answer = value!;
                            });
                          },
                        ),
                        onTap: (){
                          int selAns = question.AnswerChoices[index].AnswerChoiceID;
                          setState(() {
                            _answer = selAns!;
                          });
                        },
                      );
                    }
                ),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: (){
                      if(qnsId != 0){
                        setState(() {
                          qnsId = qnsId - 1;
                        });
                      }
                    },
                    child: Text('Back'),
                  ),
                  ElevatedButton(
                    onPressed: (){

                      setState(() {
                        qnsId = qnsId + 1;
                      });
                    },
                    child: Text('Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}