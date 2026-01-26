package com.it.newDev.hyperbid_ads.hyperbid_ads.factory

import android.app.Activity
import android.content.Context
import com.it.newDev.hyperads.core.modals.entities.HBAdUnit
import com.it.newDev.hyperads.core.modals.enums.HBTypeAd
import com.it.newDev.hyperbid_ads.hyperbid_ads.HyperbidAdsPlugin
import com.it.newDev.hyperbid_ads.hyperbid_ads.views.HbBannerPlatformView
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec


class HbBannerViewFactory(
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val activity = HyperbidAdsPlugin.activity
            ?: throw IllegalStateException("Activity is null, banner cannot be created")


        val params = args as Map<*, *>

        val placementId = params["placementId"] as String
        val name = params["name"] as String
        val typeId = params["type"] as String

        val adUnit = HBAdUnit(
            name = name,
            placementId = placementId,
            type = HBTypeAd.from(typeId)
        )

        return HbBannerPlatformView(activity, adUnit)
    }
}
