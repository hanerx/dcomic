package top.hanerx.flutterdmzj

import android.view.KeyEvent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity : FlutterActivity() {
    private val VOLUME_CHANNEL = "top.hanerx/volume"
    private var event: EventChannel.EventSink? = null;
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, VOLUME_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                event = events!!;
            }

            override fun onCancel(arguments: Any?) {
                event = null;
            }

        });
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        if (this.event != null) {
            if (keyCode == KeyEvent.KEYCODE_VOLUME_UP) {
                this.event!!.success(0);
                return true;
            } else if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
                this.event!!.success(1);
                return true;
            }
        }
        return super.onKeyDown(keyCode, event)
    }
}
