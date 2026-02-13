package com.it.newDev.hyperbid_ads.hyperbid_ads.controller

import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Listens to app foreground/background changes
 * and forwards events to Flutter.
 */
class AppStateNotifier(
    messenger: BinaryMessenger
) : LifecycleEventObserver,
    MethodChannel.MethodCallHandler,
    EventChannel.StreamHandler {

    companion object {
        private const val METHOD_CHANNEL_NAME =
            "hyperbid_ads/app_state_method"

        private const val EVENT_CHANNEL_NAME =
            "hyperbid_ads/app_state_event"
    }

    private val methodChannel =
        MethodChannel(messenger, METHOD_CHANNEL_NAME)

    private val eventChannel =
        EventChannel(messenger, EVENT_CHANNEL_NAME)

    private var eventSink: EventChannel.EventSink? = null

    init {
        methodChannel.setMethodCallHandler(this)
        eventChannel.setStreamHandler(this)
    }

    /** Start observing app lifecycle */
    private fun start() {
        ProcessLifecycleOwner.get()
            .lifecycle
            .addObserver(this)
    }

    /** Stop observing app lifecycle */
    fun stop() {
        ProcessLifecycleOwner.get()
            .lifecycle
            .removeObserver(this)
    }

    // -------------------------
    // MethodChannel
    // -------------------------

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {
        when (call.method) {
            "start" -> {
                start()
                result.success(null)
            }

            "stop" -> {
                stop()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    // -------------------------
    // Lifecycle Observer
    // -------------------------

    override fun onStateChanged(
        source: LifecycleOwner,
        event: Lifecycle.Event
    ) {
        when (event) {
            Lifecycle.Event.ON_START -> {
                eventSink?.success("foreground")
            }

            Lifecycle.Event.ON_STOP -> {
                eventSink?.success("background")
            }

            else -> {}
        }
    }

    // -------------------------
    // EventChannel
    // -------------------------

    override fun onListen(
        arguments: Any?,
        events: EventChannel.EventSink?
    ) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }
}