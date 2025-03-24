package com.example.fymemos

import io.flutter.embedding.android.FlutterActivity
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        handleShortcut(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        handleShortcut(intent)
    }

    private fun handleShortcut(intent: Intent) {
        if (intent.action == "android.intent.action.VIEW") {
            val path = intent.data?.path
            if (path == "/create_memo") {
                val flutterEngine = FlutterEngine(this)
                flutterEngine.navigationChannel.setInitialRoute("/create_memo")
            } else if (path == "/search_memo") {
                val flutterEngine = FlutterEngine(this)
                flutterEngine.navigationChannel.setInitialRoute("/search_memo")
            }
        }
    }
}
