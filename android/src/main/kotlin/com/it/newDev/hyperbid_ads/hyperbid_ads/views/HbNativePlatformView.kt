
import android.content.Context
import android.view.View
import android.widget.FrameLayout
import com.it.newDev.hyperads.core.modals.entities.HBAdUnit
import com.it.newDev.hyperads.core.modals.enums.HBTypeAd
import com.it.newDev.hyperads.core.provider.HBAdsNativeController
import com.it.newDev.hyperbid_ads.hyperbid_ads.HyperbidAdsPlugin
import io.flutter.plugin.platform.PlatformView

class HbNativePlatformView(
    context: Context,
    private val group: String,
    private val placementId: String,
    private val hbTypeAd: HBTypeAd
) : PlatformView {

    private val container = FrameLayout(context)
    private var controllerView: HBAdsNativeController? = null

    init {
        val act = HyperbidAdsPlugin.activity
            ?: throw IllegalStateException("Activity null")

        val adUnit = HBAdUnit(
            name = group,
            placementId = placementId,
            type = hbTypeAd
        )

        controllerView = HBAdsNativeController(act, adUnit, container)
        controllerView?.load()
    }

    override fun getView(): View = container

    override fun dispose() {
        controllerView?.destroy()
        controllerView = null
    }
}
