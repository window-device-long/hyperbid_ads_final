package com.it.newDev.hyperbid_ads.hyperbid_ads

import HbNativeViewFactory
import android.app.Activity
import android.content.Context
import com.it.newDev.hyperads.core.HBAdsSDK
import com.it.newDev.hyperads.core.modals.enums.HBSDKState
import com.it.newDev.hyperbid_ads.hyperbid_ads.factory.HbBannerViewFactory
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.embedding.engine.plugins.activity.ActivityAware;


class HyperbidAdsPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {

    private lateinit var commandChannel: MethodChannel
    private lateinit var lifecycleChannel: EventChannel

    private var lifecycleSink: EventChannel.EventSink? = null
    private lateinit var context: Context

    companion object {
        var activity: Activity? = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext

        commandChannel = MethodChannel(binding.binaryMessenger, "hyperbid_ads/command")
        lifecycleChannel = EventChannel(binding.binaryMessenger, "hyperbid_ads/lifecycle")

        commandChannel.setMethodCallHandler(this)

        lifecycleChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                lifecycleSink = events
            }

            override fun onCancel(arguments: Any?) {
                lifecycleSink = null
            }
        })

        binding.platformViewRegistry.registerViewFactory(
            "hyperbid_ads/banner",
            HbBannerViewFactory()
        )

        binding.platformViewRegistry.registerViewFactory(
            "hyperbid_ads/native",
            HbNativeViewFactory()
        )

    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initSDK" -> {
                val appId = call.argument<String>("appId")
                val appKey = call.argument<String>("appKey")

                if (appId.isNullOrEmpty() || appKey.isNullOrEmpty()) {
                    result.error("INVALID_PARAM", "appId or appKey is null or empty", null)
                    return
                }

                initSDK(appId, appKey)
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    private fun initSDK(appId: String, appKey: String) {
        // báo Flutter: đang init
        sendSDKState(HBSDKState.SDK_INITIALIZING)

        try {
            HBAdsSDK.initialize(
                context = context,
                appId = appId,
                appKey = appKey,
                enableDebugLog = true
            )

            HBAdsSDK.whenInitialized { success ->
                if (success) {
                    sendSDKState(HBSDKState.SDK_INITIALIZED)
                } else {
                    sendSDKState(HBSDKState.SDK_INITIALIZATION_FAILED)
                }
            }

        } catch (e: Exception) {
            sendSDKState(HBSDKState.SDK_INITIALIZATION_FAILED, e.message)
        }
    }

    private fun sendSDKState(state: HBSDKState, message: String? = null) {
        val map = mutableMapOf<String, Any>(
            "type" to "sdk_state",
            "state" to state.name
        )
        message?.let { map["message"] = it }

        lifecycleSink?.success(map)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        lifecycleSink = null
        commandChannel.setMethodCallHandler(null)
    }
}
