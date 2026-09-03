package io.github.yashmanghnani.ym_fluttertoast

import android.content.Context
import android.graphics.Typeface
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.LayoutInflater
import android.widget.TextView
import android.widget.Toast
import androidx.core.content.ContextCompat
import io.flutter.FlutterInjector
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

internal class MethodCallHandlerImpl(context: Context) : MethodChannel.MethodCallHandler {
    private val appContext = context.applicationContext
    private val mainHandler = Handler(Looper.getMainLooper())
    private var activeToast: Toast? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "showToast" -> showToast(call, result)
            "cancel" -> cancel(result)
            else -> result.notImplemented()
        }
    }

    private fun showToast(call: MethodCall, result: MethodChannel.Result) {
        val message = call.argument<String>("msg")
        if (message == null) {
            result.error("invalid_arguments", "The toast message must be a String.", null)
            return
        }

        val length = call.argument<String>("length")
        val gravity = call.argument<String>("gravity")
        val backgroundColor = call.argument<Number>("bgcolor")
        val textColor = call.argument<Number>("textcolor")
        val fontSize = call.argument<Number>("fontSize")
        val fontAsset = call.argument<String>("fontAsset")
        val duration = if (length == "long") Toast.LENGTH_LONG else Toast.LENGTH_SHORT

        mainHandler.post {
            activeToast?.cancel()
            activeToast = createToast(
                message = message,
                duration = duration,
                gravity = gravity,
                backgroundColor = backgroundColor,
                textColor = textColor,
                fontSize = fontSize,
                fontAsset = fontAsset,
            )
            activeToast?.show()
            result.success(true)
        }
    }

    private fun createToast(
        message: String,
        duration: Int,
        gravity: String?,
        backgroundColor: Number?,
        textColor: Number?,
        fontSize: Number?,
        fontAsset: String?,
    ): Toast {
        val toast: Toast
        val textView: TextView?

        // Android 11+ ignores custom Toast views when the app is in the
        // background. Use the platform-rendered toast for consistent behavior.
        if (backgroundColor != null && Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            val layout = (appContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE)
                as LayoutInflater).inflate(R.layout.toast_custom, null)
            textView = layout.findViewById(R.id.text)
            textView.text = message
            val background: Drawable? = ContextCompat.getDrawable(appContext, R.drawable.corner)
            background?.mutate()?.setTint(backgroundColor.toInt())
            textView.background = background
            toast = Toast(appContext)
            toast.view = layout
        } else {
            toast = Toast.makeText(appContext, message, duration)
            textView = if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
                toast.view?.findViewById(android.R.id.message)
            } else {
                null
            }
        }

        toast.duration = duration
        textView?.apply {
            fontSize?.toFloat()?.takeIf { it > 0 }?.let { textSize = it }
            textColor?.toInt()?.let { setTextColor(it) }
            fontAsset?.let { typeface = loadTypeface(it) }
        }

        val toastGravity = when (gravity) {
            "top" -> Gravity.TOP
            "center" -> Gravity.CENTER
            else -> Gravity.BOTTOM
        }
        val yOffset = if (toastGravity == Gravity.CENTER) 0 else 100
        toast.setGravity(toastGravity, 0, yOffset)
        return toast
    }

    private fun loadTypeface(fontAsset: String): Typeface {
        val assetManager = appContext.assets
        val key = FlutterInjector.instance().flutterLoader().getLookupKeyForAsset(fontAsset)
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Typeface.Builder(assetManager, key).build()
        } else {
            @Suppress("DEPRECATION")
            Typeface.createFromAsset(assetManager, key)
        }
    }

    private fun cancel(result: MethodChannel.Result) {
        mainHandler.post {
            activeToast?.cancel()
            activeToast = null
            result.success(true)
        }
    }
}
