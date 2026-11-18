package com.hancolors.han_colors;

import android.app.WallpaperManager;
import android.content.ContentValues;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.MediaStore;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

/**
 * Native bridge for wallpaper + gallery. Pure Java, no Kotlin.
 *   setWallpaper {bytes, target: home|lock|both}
 *   saveToGallery {bytes, name}
 */
public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "han.colors/wallpaper";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler((call, result) -> {
                    byte[] bytes = call.argument("bytes");
                    if (bytes == null) {
                        result.error("BAD_ARGS", "missing bytes", null);
                        return;
                    }
                    switch (call.method) {
                        case "setWallpaper": {
                            String target = call.argument("target");
                            if (target == null) target = "home";
                            final String t = target;
                            new Thread(() -> {
                                try {
                                    setWallpaperInternal(bytes, t);
                                    runOnUiThread(() -> result.success(true));
                                } catch (Exception e) {
                                    runOnUiThread(() -> result.error(
                                            "SET_FAILED", e.getMessage(), null));
                                }
                            }).start();
                            break;
                        }
                        case "saveToGallery": {
                            String name = call.argument("name");
                            if (name == null) name = "han_colors";
                            final String n = name;
                            new Thread(() -> {
                                try {
                                    saveToGalleryInternal(bytes, n);
                                    runOnUiThread(() -> result.success(true));
                                } catch (Exception e) {
                                    runOnUiThread(() -> result.error(
                                            "SAVE_FAILED", e.getMessage(), null));
                                }
                            }).start();
                            break;
                        }
                        default:
                            result.notImplemented();
                    }
                });
    }

    private void setWallpaperInternal(byte[] bytes, String target) throws Exception {
        Bitmap bmp = BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
        WallpaperManager wm = WallpaperManager.getInstance(getApplicationContext());
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            switch (target) {
                case "lock":
                    wm.setBitmap(bmp, null, true, WallpaperManager.FLAG_LOCK);
                    break;
                case "both":
                    wm.setBitmap(bmp, null, true, WallpaperManager.FLAG_SYSTEM);
                    wm.setBitmap(bmp, null, true, WallpaperManager.FLAG_LOCK);
                    break;
                default:
                    wm.setBitmap(bmp, null, true, WallpaperManager.FLAG_SYSTEM);
            }
        } else {
            wm.setBitmap(bmp);
        }
    }

    private void saveToGalleryInternal(byte[] bytes, String name) throws Exception {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            ContentValues v = new ContentValues();
            v.put(MediaStore.Images.Media.DISPLAY_NAME, name + ".png");
            v.put(MediaStore.Images.Media.MIME_TYPE, "image/png");
            v.put(MediaStore.Images.Media.RELATIVE_PATH,
                    Environment.DIRECTORY_PICTURES + "/HanColors");
            Uri uri = getContentResolver().insert(
                    MediaStore.Images.Media.EXTERNAL_CONTENT_URI, v);
            if (uri == null) throw new Exception("MediaStore insert failed");
            try (OutputStream os = getContentResolver().openOutputStream(uri)) {
                if (os == null) throw new Exception("openOutputStream failed");
                os.write(bytes);
            }
        } else {
            File dir = new File(
                    Environment.getExternalStoragePublicDirectory(
                            Environment.DIRECTORY_PICTURES), "HanColors");
            //noinspection ResultOfMethodCallIgnored
            dir.mkdirs();
            File f = new File(dir, name + ".png");
            try (FileOutputStream fos = new FileOutputStream(f)) {
                fos.write(bytes);
            }
            Intent scan = new Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE);
            scan.setData(Uri.fromFile(f));
            sendBroadcast(scan);
        }
    }
}
