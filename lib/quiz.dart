
import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_projects/services/webservice.dart';
import 'package:lottie/lottie.dart';
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
                  subtitle: Text('Starting: ${quizData[index].StartTime} and Ending: ${quizData[index].EndTime}'),
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
          title: Text('Quiz Details',style: TextStyle(
            color:appBarTextColor,
          ),),
        ),
        endDrawer: AppDrawer(),
        body: Column(
          children: [
            connectionStatus != ConnectivityResult.none ? SizedBox(height:0) : noConnectivityError(),
            SizedBox(height:20),
            Container(
              decoration: BoxDecoration(
                color:Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(15),
              child: Text(quizData.title,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),),
            ),
            SizedBox(height:20),
            buildRow('Start Time','${quizData.StartTime}'),
            buildRow('End Time','${quizData.EndTime}'),
            buildRow('No. of Questions','${quizData.noOfQns}'),
            buildRow('Time Duration','${quizData.timeDuration}'),
            SizedBox(height:20),
            Container(
              decoration: BoxDecoration(
                color:Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(15),
              child: Text('Once started, quiz can not be attempted again. Do not close the app or press the back button once the quiz starts and complete the quiz at one go',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),),
            ),
            SizedBox(height:20),
            Container(
              decoration: BoxDecoration(
                color:Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(15),
              child: Text('At the end of the time duration, quiz responses will be automatically submitted',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),),
            ),
            SizedBox(height:20),
            ElevatedButton(
                onPressed: (){
                  Navigator.pushNamed(context, quizStartRoute, arguments: quizData.QuizID);
                  //Navigator.pushNamed(context, quizStartRoute, arguments: quizData);
                },
                child: Text('Start Quiz'))
          ],
        ),
      ),
    );
  }
  Widget buildRow(String title, String data){
    return Row(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
          ),
          width:150,
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(left:5,bottom: 5),
          alignment: Alignment.centerLeft,
          child: Text(title,style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),),
        ),
        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(left:3,right:5,bottom: 5),
            alignment: Alignment.centerLeft,
            child: Text(data,textAlign: TextAlign.center,style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),),
          ),
        ),
      ],
    );
  }
}

class QuizStart extends StatefulWidget {
  final int quizID;
  //final QuizData quizData;
  QuizStart(this.quizID);
  @override
  State<QuizStart> createState() => _QuizStartState();
}
class _QuizStartState extends State<QuizStart>{
  int qnsId = 0;
  Color ansColor = Colors.white;
  late Future<APIResponseData> _apiResponseData;
  late var _endpointProvider;
  bool isLoading = false;

  late QuizData quizData;
  late QuestionData question;
  Duration duration = const Duration(seconds: 0);
  Duration progressBarDuration = const Duration(seconds: 0);
  Timer? timer;
  double progressTimer = 0;
  List<QuestionAnswer> answeredQns = [];
  DateTime quizStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    DioClient _dio = new DioClient();
    _endpointProvider = new EndPointProvider(_dio.init());
    if(connectionStatus != ConnectivityResult.none){
      setState(() {
        isLoading = true;
      });
      _apiResponseData = _endpointProvider.startQuiz(widget.quizID.toString());
      _apiResponseData.then((result) {
        if(result.isAuthenticated && result.status){
          final parsed = jsonDecode(result.data ?? '').cast<Map<String, dynamic>>();
          setState(() {
            quizData =  parsed.map<QuizData>((json) => QuizData.fromJson(json)).toList();
            question = quizData.Questions!.elementAt(qnsId);
            duration = Duration(seconds: quizData.timeDuration);
            isLoading = false;
          });
          quizStartTime = DateTime.now();
          startTimer();
        }
        else{
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${result.error_details}')),
          );
          setState(() {
            isLoading = false;
          });
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
      setState(() {
        isLoading = false;
      });
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No internet connection. Please check your settings")),
      );
    }
  }
  void startTimer(){
    timer = Timer.periodic(Duration(seconds: 1),(_) => reduceTime());
  }
  void reduceTime(){
    setState(() {
      final seconds = duration.inSeconds - 1;
      final secondsProgress = progressBarDuration.inSeconds + 1;
      if (seconds < 0){
        timer?.cancel();
        submitQuizResponse();
/*        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Time ends")),
        );*/
      }
      else{
        duration = Duration(seconds: seconds);
        progressBarDuration = Duration(seconds: secondsProgress);
        progressTimer = secondsProgress.toDouble() / quizData.timeDuration;
      }
    });
  }

  @override
  void dispose() {
    //_ticker.dispose();
    timer!.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope (
      onWillPop: () async {
        return true;
      },
      child: Container(
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
            title: Text('Quiz',style: TextStyle(
              color:appBarTextColor,
            ),),
          ),
          //endDrawer: AppDrawer(),
          body: isLoading ? Container(
            height: MediaQuery.of(context).size.height / 1.3,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //CircularProgressIndicator(),
                  Center(
                    child: Lottie.asset('animations/ani_loading_hexa.json',
                      width: 200,
                      height: 200,),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child:Text('Please wait. Submitting quiz responses',style: TextStyle(
                      fontWeight: FontWeight.w500,fontSize: 16,),
                    ),
                  ),
                ],
              ),
            ),
          ): Column(
            children: [
              connectionStatus != ConnectivityResult.none ? SizedBox(height:0) : noConnectivityError(),
              isLoading? waiting(context) :
              Center(
                child: Text('Question',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),),
              ),
              Container(
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  //border: Border.all(color:Colors.black38),
                  color: Colors.white,
                ),
                padding: EdgeInsets.all(20),
                child:Text(question.QuestionText,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),),
              ),
              Center(
                child: Text('Choose Answer',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),),
              ),
              Expanded(
                flex: 4,
                child: ListView.builder(
                    itemCount: question.AnswerChoices.length,
                    itemBuilder: (context, index) {
                      int selIndex = 0;
                      if(answeredQns.map((item) => item.QuestionId).contains(question.QuestionId)){
                        selIndex = answeredQns.elementAt(answeredQns.indexWhere((element) => element.QuestionId == question.QuestionId)).AnswerId;
                      }
                      return Container(
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color:Colors.black38),
                            color: selIndex == question.AnswerChoices[index].AnswerChoiceID ? Colors.lightGreen : Colors.white,
                          ),
                          child: ListTile(
                            title: Text(question.AnswerChoices[index].AnswerText ?? ''),
                            onTap: (){
                              int selAns = question.AnswerChoices[index].AnswerChoiceID;
                              if(answeredQns.map((item) => item.QuestionId).contains(question.QuestionId)){
                                setState(() {
                                  QuestionAnswer newAnswer = QuestionAnswer(
                                      QuestionId: question.QuestionId,
                                      AnswerId: selAns);
                                  answeredQns[answeredQns.indexWhere((element) => element.QuestionId == question.QuestionId)] = newAnswer;
                                });
                              }
                              else{
                                QuestionAnswer newAnswer = QuestionAnswer(
                                    QuestionId: question.QuestionId,
                                    AnswerId: selAns);
                                setState(() {
                                  answeredQns.add(newAnswer);
                                });
                              }
                            },
                          )
                      );
                    }
                ),
              ),
              Center(
                child: Text('Remaining Time',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 14,
                  ),),
              ),
              SizedBox(height: 5,),
/*              CircularProgressIndicator(
                value: progressTimer,
                backgroundColor: Colors.lightGreen,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
              ),*/
              buildTime(),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.all(10),
                  child:Text('Do not close the app or press the back button. Please complete the quiz at one go',style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                    color: Colors.red,
                  )),
                ),
              ),
              Expanded(
                flex: 1,
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: (){
                        if(qnsId != 0){
                          setState(() {
                            qnsId = qnsId - 1;
                            question = quizData.Questions!.elementAt(qnsId);
                          });
                        }
                      },
                      child: Text('Back'),
                    ),
                    ElevatedButton(
                      onPressed: (){
                        qnsId = qnsId + 1;
                        if(qnsId < quizData.Questions!.length){
                          setState(() {
                            question = quizData.Questions!.elementAt(qnsId);
                          });
                        }
                        else{
                          timer?.cancel();
                          showDialog(
                            context: context,
                            builder: (context){
                              return StatefulBuilder(
                                builder: (context, setState){
                                  return AlertDialog (
                                    insetPadding: EdgeInsets.all(0),
                                    content: Builder(
                                      builder: (context) {
                                        // Get available height and width of the build area of this widget. Make a choice depending on the size.
                                        var height = MediaQuery.of(context).size.height;
                                        var width = MediaQuery.of(context).size.width;

                                        return Container(
                                          height: height - (height/2.5),
                                          width: width - (width/4),
                                          child: isLoading ? Container(
                                            height: MediaQuery.of(context).size.height / 1.3,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  //CircularProgressIndicator(),
                                                  Center(
                                                    child: Lottie.asset('animations/ani_loading_hexa.json',
                                                      width: 200,
                                                      height: 200,),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.all(10),
                                                    child:Text('Please wait. Submitting quiz responses',style: TextStyle(
                                                      fontWeight: FontWeight.w500,fontSize: 16,),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ) :
                                          Column(
                                            children: [
                                              Center(
                                                child: Text('You have reached the end of the questionnaire. Please click End Quiz to end and submit your responses. '
                                                    'Click Cancel to review your answers',style: TextStyle(
                                                  fontWeight: FontWeight.w500,fontSize: 16,),
                                                ),
                                              ),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text('Cancel'),
                                                    style: ButtonStyle(
                                                      backgroundColor: MaterialStateProperty.all(Colors.red),
                                                    ),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        isLoading = true;
                                                      });
                                                      submitQuizResponse();
                                                    },
                                                    child: const Text('End Quiz'),
                                                    style: ButtonStyle(
                                                      backgroundColor: MaterialStateProperty.all(Colors.green),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }
                      },
                      child: Text('Next'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  submitQuizResponse(){
    setState(() {
      isLoading = true;
    });
    QuizRespnse quizResponse = QuizRespnse(
        QuizID: quizData.QuizID,
        QuizStartTime: quizStartTime.toIso8601String(),
        QuizEndTime: DateTime.now().toIso8601String(),
        answer: answeredQns);

    if(connectionStatus != ConnectivityResult.none){
      _apiResponseData = _endpointProvider.postQuizResponse(quizResponse);
      _apiResponseData.then((result) {
        if(result.isAuthenticated && result.status){
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
          Navigator.pushNamed(context, homeRoute);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Quiz response submitted successfully")),
          );
        }
      }).catchError( (error) {
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);
        Navigator.pushNamed(context, homeRoute);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error in submitting quiz data")),
        );
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

  Widget buildTime(){
    String twoDigits(int n) => n.toString().padLeft(2,'0');
    final minutes =twoDigits(duration.inMinutes.remainder(60));
    final seconds =twoDigits(duration.inSeconds.remainder(60));
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildTimeCard(minutes,'Minutes'),
          SizedBox(width: 10,),
          buildTimeCard(seconds,'Seconds'),
        ]
    );
  }
  Widget buildTimeCard(String time, String header) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20)
          ),
          child: Text(
            time, style: TextStyle(fontWeight: FontWeight.bold,
              color: Colors.black,fontSize: 30),),
        ),
        SizedBox(height: 5,),
        Text(header,style: TextStyle(color: Colors.black45)),
      ],
    );
  }
}