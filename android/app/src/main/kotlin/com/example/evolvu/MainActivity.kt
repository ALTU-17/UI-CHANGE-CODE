package `in`.aceventura.evolvuschool

import android.content.Intent
import android.content.pm.ShortcutInfo
import android.content.pm.ShortcutManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.graphics.drawable.Icon
import android.os.Build
import android.os.Bundle

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "evolvu.dynamic_launcher"

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                "setSchoolShortcut" -> {

                    val schoolName =
                        call.argument<String>("schoolName")

                    val logoBytes =
                        call.argument<ByteArray>("logoBytes")

                    if (schoolName.isNullOrBlank()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    if (logoBytes == null ||
                        logoBytes.isEmpty()
                    ) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    try {

                        val success =
                            createOrUpdateSchoolShortcut(
                                schoolName,
                                logoBytes
                            )

                        result.success(success)

                    } catch (e: Exception) {

                        e.printStackTrace()

                        result.success(false)
                    }
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun createOrUpdateSchoolShortcut(
        schoolName: String,
        logoBytes: ByteArray
    ): Boolean {

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return createLegacyShortcut(
                schoolName,
                logoBytes
            )
        }

        val shortcutManager =
            getSystemService(
                ShortcutManager::class.java
            )

        if (shortcutManager == null) {
            return false
        }

        if (!shortcutManager.isRequestPinShortcutSupported) {
            return false
        }

        val bitmap =
            BitmapFactory.decodeByteArray(
                logoBytes,
                0,
                logoBytes.size
            ) ?: return false

        val shortcutBitmap =
            prepareShortcutBitmap(bitmap)

        val icon =
            Icon.createWithBitmap(
                shortcutBitmap
            )

        val launchIntent =
            packageManager.getLaunchIntentForPackage(
                packageName
            ) ?: return false

        launchIntent.addFlags(
            Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_SINGLE_TOP
        )

        val shortcut =
            ShortcutInfo.Builder(
                this,
                SCHOOL_SHORTCUT_ID
            )
                .setShortLabel(
                    shortenLabel(schoolName)
                )
                .setLongLabel(
                    "$schoolName - Evolvu"
                )
                .setIcon(icon)
                .setIntent(launchIntent)
                .setLongLived(true)
                .build()

        // -----------------------------------------
        // Already pinned?
        // -----------------------------------------

        val existing =
            shortcutManager.pinnedShortcuts
                .any { it.id == SCHOOL_SHORTCUT_ID }

        if (existing) {

            // Update existing school shortcut
            shortcutManager.updateShortcuts(
                listOf(shortcut)
            )

            return true
        }

        // -----------------------------------------
        // First time
        // -----------------------------------------

        return shortcutManager.requestPinShortcut(
            shortcut,
            null
        )
    }

    private fun prepareShortcutBitmap(
        source: Bitmap
    ): Bitmap {

        val size = 512

        val output =
            Bitmap.createBitmap(
                size,
                size,
                Bitmap.Config.ARGB_8888
            )

        val canvas = Canvas(output)

        // Transparent background
        canvas.drawColor(Color.TRANSPARENT)

        val paint = Paint(
            Paint.ANTI_ALIAS_FLAG or
                    Paint.FILTER_BITMAP_FLAG
        )

        val padding = 35

        val availableSize =
            size - (padding * 2)

        val scale =
            minOf(
                availableSize.toFloat() /
                        source.width,

                availableSize.toFloat() /
                        source.height
            )

        val width =
            source.width * scale

        val height =
            source.height * scale

        val left =
            (size - width) / 2f

        val top =
            (size - height) / 2f

        val destination =
            RectF(
                left,
                top,
                left + width,
                top + height
            )

        canvas.drawBitmap(
            source,
            null,
            destination,
            paint
        )

        return output
    }

    private fun shortenLabel(
        value: String
    ): String {

        val clean =
            value.trim()

        return if (clean.length <= 25) {
            clean
        } else {
            clean.substring(
                0,
                25
            )
        }
    }

    private fun createLegacyShortcut(
        schoolName: String,
        logoBytes: ByteArray
    ): Boolean {

        return try {

            val bitmap =
                BitmapFactory.decodeByteArray(
                    logoBytes,
                    0,
                    logoBytes.size
                ) ?: return false

            val shortcutIntent =
                packageManager
                    .getLaunchIntentForPackage(
                        packageName
                    ) ?: return false

            shortcutIntent.addFlags(
                Intent.FLAG_ACTIVITY_CLEAR_TOP
            )

            val intent =
                Intent(
                    "com.android.launcher.action.INSTALL_SHORTCUT"
                )

            intent.putExtra(
                Intent.EXTRA_SHORTCUT_NAME,
                shortenLabel(schoolName)
            )

            intent.putExtra(
                Intent.EXTRA_SHORTCUT_ICON,
                bitmap
            )

            intent.putExtra(
                Intent.EXTRA_SHORTCUT_INTENT,
                shortcutIntent
            )

            sendBroadcast(intent)

            true

        } catch (e: Exception) {

            e.printStackTrace()

            false
        }
    }

    companion object {

        private const val SCHOOL_SHORTCUT_ID =
            "evolvu_school_launcher"
    }
}
