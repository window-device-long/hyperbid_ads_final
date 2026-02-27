package com.it.newDev.hyperbid_ads.hyperbid_ads.views

import android.content.Context
import android.util.Log
import android.app.Activity
import android.view.View
import android.widget.FrameLayout
import com.it.newDev.hyperads.core.interfaces.NativeAdStateListener
import com.it.newDev.hyperads.core.modals.entities.HBAdUnit
import com.it.newDev.hyperads.core.modals.enums.HBTypeAd
import com.it.newDev.hyperads.core.provider.HBAdsNativeController
import com.it.newDev.hyperbid_ads.hyperbid_ads.HyperbidAdsPlugin
import com.it.newDev.hyperbid_ads.hyperbid_ads.controller.HBAdsControllerStore
import com.it.newDev.hyperbid_ads.hyperbid_ads.controller.HBAdsManager
import io.flutter.plugin.platform.PlatformView

class HbNativePlatformView(
    context: Context,
    viewId: String?,
    private val activity: Activity,
    name: String,
    placementId: String,
    type: HBTypeAd,
    args: Map<String, Any>
) : PlatformView {

    private val container = FrameLayout(context)
    private val controller: HBAdsNativeController
    private var _viewId: String? = null

    init {

        val adUnit = HBAdUnit(
            name = args["group"] as String,
            placementId = args["placementId"] as String,
            type = type
        )
        _viewId = args["viewId"] as String?

        controller = HBAdsNativeController(activity, adUnit, container, _viewId!!)
        controller.setStateListener(object : NativeAdStateListener {
            override fun onNativeReady(viewId: String) {
                HBAdsManager.dispatchNativeState(
                    viewId = viewId,
                    state = "READY"
                )
            }

            override fun onNativeFailed(viewId: String) {
                HBAdsManager.dispatchNativeState(
                    viewId = viewId,
                    state = "FAILED"
                )
            }

        })
        HBAdsControllerStore.put("$_viewId", controller)

        controller.loadAndShow()
    }

    override fun getView(): View = container

    override fun dispose() {
        HBAdsControllerStore.get("$_viewId")?.destroy()
        HBAdsControllerStore.remove("$_viewId")
        controller.setStateListener(null)
    }
}