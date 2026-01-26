package com.it.newDev.hyperbid_ads.hyperbid_ads.views

import android.app.Activity
import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.it.newDev.hyperads.core.modals.entities.HBAdUnit
import com.it.newDev.hyperads.core.provider.HBAdsBannerController
import io.flutter.plugin.platform.PlatformView


class HbBannerPlatformView(
    private val context: Activity,
    private val adUnit: HBAdUnit
) : PlatformView {

    private val container: FrameLayout = FrameLayout(context.applicationContext)
    private var bannerController: HBAdsBannerController? = null

    init {
        bannerController = HBAdsBannerController(
            activity = context,
            adUnit = adUnit,
            container = container
        )
        bannerController?.load()
    }

    override fun getView(): View = container

    override fun dispose() {
        bannerController?.destroy()
        bannerController = null
    }
}
