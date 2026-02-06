package com.it.newDev.hyperbid_ads.hyperbid_ads.factory

import android.content.Context
import com.it.newDev.hyperads.core.modals.enums.HBTypeAd
import com.it.newDev.hyperbid_ads.hyperbid_ads.views.HbNativePlatformView
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec


class HbNativeViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(
        context: Context,
        viewId: Int,
        args: Any?
    ): PlatformView {

        val params = args as? Map<String, Any>
            ?: throw IllegalArgumentException("NativeAd params missing")

        val group = params["group"] as String
        val placementId = params["placementId"] as String
        val typeId = params["type"] as String
        val flutterViewId = params["viewId"] as String


        val typeAd = HBTypeAd.from(typeId)
        require(typeAd != HBTypeAd.UNKNOWN) {
            "Unknown HBTypeAd: $typeId"
        }


        return HbNativePlatformView(
            context = context,
            viewId = flutterViewId,
            name = group,
            placementId = placementId,
            type = typeAd,
            args = params
        )
    }
}