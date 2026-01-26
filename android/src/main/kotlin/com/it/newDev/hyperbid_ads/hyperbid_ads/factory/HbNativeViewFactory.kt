import android.content.Context
import com.it.newDev.hyperads.core.modals.enums.HBTypeAd
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.StandardMessageCodec


class HbNativeViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as Map<String, Any>
        val group = params["group"] as String
        val placementId = params["placementId"] as String
        val typeId = params["type"] as String

        val typeAd = HBTypeAd.from(typeId)

        if (typeAd == HBTypeAd.UNKNOWN) {
            throw IllegalArgumentException("Unknown HBTypeAd: $typeId")
        }

        return HbNativePlatformView(context, group, placementId, typeAd)
    }
}
