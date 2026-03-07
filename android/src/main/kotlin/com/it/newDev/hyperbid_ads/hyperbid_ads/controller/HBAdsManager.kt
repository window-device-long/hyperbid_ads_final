package com.it.newDev.hyperbid_ads.hyperbid_ads.controller

import android.app.Activity
import android.widget.FrameLayout
import android.os.Handler
import android.os.Looper
import com.it.newDev.hyperads.core.HBAdsSDK
import com.it.newDev.hyperads.core.interfaces.AdRevenueListener
import com.it.newDev.hyperads.core.modals.entities.HBAdUnit
import com.it.newDev.hyperads.core.provider.HBAdsAppOpenController
import com.it.newDev.hyperads.core.provider.HBAdsInterstitialController
import com.it.newDev.hyperads.core.provider.HBAdsRewardedController
import android.util.Log


object HBAdsManager {

    private var interstitialController: HBAdsInterstitialController? = null
    private var rewardController: HBAdsRewardedController? = null


    private var lifecycleEvent: ((Map<String, Any>) -> Unit)? = null
    private val pendingEvents = mutableListOf<Map<String, Any>>()

    fun setLifecycleListener(listener: ((Map<String, Any>) -> Unit)?) {
        lifecycleEvent = listener

        if (listener != null) {
            flushPendingEvents()
        }
    }

    private fun emit(event: Map<String, Any>) {
        Handler(Looper.getMainLooper()).post {

            if (lifecycleEvent == null) {
                Log.e("HB_EVENT_FLOW", "BUFFER EVENT: $event")
                pendingEvents.add(event)
            } else {
                Log.e("HB_EVENT_FLOW", "SEND EVENT: $event")
                lifecycleEvent?.invoke(event)
            }
        }
    }

    private fun flushPendingEvents() {
        lifecycleEvent?.let { listener ->
            pendingEvents.forEach {
                listener.invoke(it)
            }
            pendingEvents.clear()
        }
    }

    var sdkRevenueListener = object : AdRevenueListener {
        override fun onAdRevenue(json: String) {
            emit(
                mapOf(
                    "type" to "revenue",
                    "data" to json
                )
            )
        }
    }

    fun attachRevenueListener() {
        HBAdsSDK.addAdRevenueListener(sdkRevenueListener)
    }

    fun detachRevenueListener() {
        HBAdsSDK.removeAdRevenueListener(sdkRevenueListener)
    }


    fun initInterstitial(activity: Activity, adUnit: HBAdUnit) {
        if (interstitialController == null) {
            interstitialController = HBAdsInterstitialController(
                activity = activity,
                adUnit = adUnit
            ).apply {
                setOnHiddenListener {
                    emit(
                        mapOf(
                            "type" to "interstitial_hidden"
                        )
                    )
                }

                load()
            }
        }
    }

    fun initReward(activity: Activity, adUnit: HBAdUnit) {
        if (rewardController == null) {
            rewardController = HBAdsRewardedController(
                activity = activity,
                adUnit = adUnit
            ).apply {
                setOnRewardEarnedListener {
                    emit(
                        mapOf(
                            "type" to "reward_earned",
                            "placementId" to adUnit.placementId
                        )
                    )
                }

                setOnHiddenListener {
                    emit(
                        mapOf(
                            "type" to "reward_hidden",
                            "placementId" to adUnit.placementId
                        )
                    )
                }

                load()
            }
        }


    }


    private var appOpenController: HBAdsAppOpenController? = null

    fun initAppOpen(
        activity: Activity,
        placementId: String,
        event: (Map<String, Any>) -> Unit
    ) {
        appOpenController = HBAdsAppOpenController(
            activity = activity,
            placementId = placementId,
        )
    }

    fun loadAppOpen() {
        appOpenController?.load()
    }

    fun showAppOpen() {
        appOpenController?.show()
    }


    fun destroyAppOpen() {
        appOpenController?.destroy()
        appOpenController = null
    }

    fun showReward() {
        rewardController?.show()
    }


    fun destroyReward() {
        rewardController?.destroy()
        rewardController = null
    }


    fun showInterstitial() {
        interstitialController?.show()
    }


    fun destroyInterstitial() {
        interstitialController?.destroy()
        interstitialController = null
    }

    fun isInterstitialReady(): Boolean {
        return interstitialController?.isReady() == true
    }

    fun isRewardReady(): Boolean {
        return rewardController?.isReady() == true
    }


    fun dispatchNativeState(viewId: String, state: String) {
        emit(
            mapOf(
                "type" to "native_state",
                "viewId" to viewId,
                "state" to state
            )
        )
    }

}