package com.it.newDev.hyperbid_ads.hyperbid_ads.controller


import com.it.newDev.hyperads.core.provider.HBAdsNativeController

object HBAdsControllerStore {

    private val nativeControllers =
        mutableMapOf<String, HBAdsNativeController>()

    fun put(viewId: String, controller: HBAdsNativeController) {
        nativeControllers[viewId] = controller
    }

    fun get(viewId: String): HBAdsNativeController? {
        return nativeControllers[viewId]
    }

    fun remove(viewId: String) {
        nativeControllers.remove(viewId)
    }

}