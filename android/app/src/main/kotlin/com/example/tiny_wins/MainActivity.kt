package com.example.tiny_wins

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.Bundle
import android.content.Intent

class MainActivity: FlutterActivity() {
    private val HABIT_WIDGET_CHANNEL = "com.example.tiny_wins/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HABIT_WIDGET_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialHabitAction" -> {
                    val habitId = intent.getIntExtra("widget_habit_id", -1)
                    val action = intent.getStringExtra("widget_action")
                    if (habitId != -1 && action != null) {
                        result.success(mapOf("habitId" to habitId, "action" to action))
                        // Clear the intent to avoid重复处理
                        intent.removeExtra("widget_habit_id")
                        intent.removeExtra("widget_action")
                    } else {
                        result.success(null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        this.intent = intent
    }
}