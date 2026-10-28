package com.salimjemai.mushafplus

import android.content.pm.PackageManager
import android.content.res.Configuration
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Tells the Dart side whether it runs on a Wear OS watch (and whether
        // the screen is round) so it can show the compact watch interface.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "mushafplus/device").setMethodCallHandler { call, result ->
            when (call.method) {
                "formFactor" -> {
                    val config = resources.configuration
                    val watch = packageManager.hasSystemFeature(PackageManager.FEATURE_WATCH) ||
                        (config.uiMode and Configuration.UI_MODE_TYPE_MASK) == Configuration.UI_MODE_TYPE_WATCH
                    result.success(mapOf("watch" to watch, "round" to config.isScreenRound))
                }
                else -> result.notImplemented()
            }
        }
    }
}
