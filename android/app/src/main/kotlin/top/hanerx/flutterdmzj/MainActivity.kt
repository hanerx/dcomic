package top.hanerx.flutterdmzj

import android.os.Bundle
import android.os.PersistableBundle
import android.view.KeyEvent
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.textile.ipfslite.Peer


class MainActivity : FlutterActivity() {
    private val VOLUME_CHANNEL = "top.hanerx/volume";
    private val IPFS_CHANNEL = "top.hanerx/ipfs-lite";
    private var event: EventChannel.EventSink? = null;
    private var litePeer: Peer? = null;
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
        MethodChannel(
                flutterEngine.dartExecutor.binaryMessenger, IPFS_CHANNEL
        ).setMethodCallHandler { call, result ->
            if (call.method == "startPeer") {
                if (litePeer == null) {
                    Thread { litePeer = Peer(call.argument("path"), call.argument("debug"), true);Peer.start(); }.start();
                    result.success(true);
                } else {
                    result.error("002", "litePeer is already start", "");
                }
            } else if (call.method == "cat") {
                if (litePeer != null && litePeer!!.started()) {
                    val data: ByteArray = litePeer!!.getFileSync(call.argument("cid"));
                    result.success(data);
                } else {
                    result.error("001", "litePeer is null", "");
                }
            } else if (call.method == "add") {
                if (litePeer != null && litePeer!!.started()) {
                    val cid = litePeer!!.addFileSync(call.argument("bytes"));
                    result.success(cid);
                } else {
                    result.error("001", "litePeer is null", "");
                }
            } else if (call.method == "stopPeer") {
                if (litePeer != null) {
                    Peer.stop();
                    litePeer=null;
                    result.success(true);
                } else {
                    result.error("001", "litePeer is null", "");
                }
            }
        };
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
