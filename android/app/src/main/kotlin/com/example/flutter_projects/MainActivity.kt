package com.example.flutter_projects

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

//Commenting original to use local authentication
/*class MainActivity: FlutterActivity() {
}*/
//local_auth plugin requires the use of a FragmentActivity as opposed to FlutterActivity
class MainActivity: FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
