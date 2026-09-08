package com.vanecho.echoday

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.vanecho.echoday/document_backup"
        private const val CREATE_DOCUMENT_REQUEST = 7341
    }

    private var pendingDocumentResult: MethodChannel.Result? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        allowContentInDisplayCutout()
        enterImmersiveMode()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) enterImmersiveMode()
    }

    private fun allowContentInDisplayCutout() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) return
        window.attributes = window.attributes.apply {
            layoutInDisplayCutoutMode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_ALWAYS
            } else {
                WindowManager.LayoutParams.LAYOUT_IN_DISPLAY_CUTOUT_MODE_SHORT_EDGES
            }
        }
    }

    @Suppress("DEPRECATION")
    private fun enterImmersiveMode() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.apply {
                hide(WindowInsets.Type.systemBars())
                systemBarsBehavior =
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            window.decorView.systemUiVisibility =
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                View.SYSTEM_UI_FLAG_FULLSCREEN or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_STABLE
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler(::handleDocumentCall)
    }

    private fun handleDocumentCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "chooseExportDocument" -> chooseExportDocument(call, result)
            "writeExportDocument" -> writeExportDocument(call, result)
            else -> result.notImplemented()
        }
    }

    private fun chooseExportDocument(call: MethodCall, result: MethodChannel.Result) {
        if (pendingDocumentResult != null) {
            result.error("document_picker_busy", "A document picker is already open.", null)
            return
        }
        val suggestedName = call.argument<String>("suggestedName")
            ?: "EchoDay-backup.json"
        val mimeType = call.argument<String>("mimeType") ?: "application/json"
        pendingDocumentResult = result
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, suggestedName)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
        }
        try {
            startActivityForResult(intent, CREATE_DOCUMENT_REQUEST)
        } catch (error: Exception) {
            pendingDocumentResult = null
            result.error("document_picker_failed", error.message, null)
        }
    }

    private fun writeExportDocument(call: MethodCall, result: MethodChannel.Result) {
        val documentUri = call.argument<String>("documentUri")
        val sourcePath = call.argument<String>("sourcePath")
        if (documentUri.isNullOrBlank() || sourcePath.isNullOrBlank()) {
            result.error("invalid_arguments", "Document URI and source path are required.", null)
            return
        }

        Thread {
            try {
                val source = File(sourcePath)
                check(source.isFile) { "Backup staging file does not exist." }
                val uri = Uri.parse(documentUri)
                check(uri.scheme == "content") { "Only content document URIs are supported." }
                val output = contentResolver.openOutputStream(uri, "wt")
                    ?: error("The selected document cannot be opened for writing.")
                output.use { stream -> source.inputStream().use { it.copyTo(stream) } }
                runOnUiThread { result.success(null) }
            } catch (error: Exception) {
                runOnUiThread {
                    result.error("document_write_failed", error.message, null)
                }
            }
        }.start()
    }

    @Deprecated("Deprecated in Android, required by FlutterActivity's activity result bridge")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == CREATE_DOCUMENT_REQUEST) {
            val pending = pendingDocumentResult
            pendingDocumentResult = null
            if (resultCode == Activity.RESULT_OK) {
                pending?.success(data?.data?.toString())
            } else {
                pending?.success(null)
            }
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }
}
