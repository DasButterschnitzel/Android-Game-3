package io.github.dasbutterschnitzel.nachhall.ads;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.pm.ApplicationInfo;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.ads.AdError;
import com.google.android.gms.ads.AdRequest;
import com.google.android.gms.ads.FullScreenContentCallback;
import com.google.android.gms.ads.LoadAdError;
import com.google.android.gms.ads.MobileAds;
import com.google.android.gms.ads.RequestConfiguration;
import com.google.android.gms.ads.interstitial.InterstitialAd;
import com.google.android.gms.ads.interstitial.InterstitialAdLoadCallback;
import com.google.android.ump.ConsentDebugSettings;
import com.google.android.ump.ConsentInformation;
import com.google.android.ump.ConsentRequestParameters;
import com.google.android.ump.FormError;
import com.google.android.ump.UserMessagingPlatform;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * NachhallAds: minimal bridge from Godot (singleton "NachhallAds") to Google Mobile Ads
 * (interstitials) and the User Messaging Platform (consent). Experimental test builds only.
 *
 * <p>SDK calls run on the host (UI) thread; results go back to Godot as signals (emitSignal hands
 * them to the render thread). Every request ends in one result signal; the GDScript side still
 * guards each wait with a timeout. Hard guard of this spike: only Google's public test ids are
 * accepted, for the app id in the manifest as well as for ad units.
 *
 * <p>Method names are snake_case on purpose: they are the GDScript-facing API.
 */
public class NachhallAdsPlugin extends GodotPlugin {
    private static final String TAG = "NachhallAds";

    /** Publisher id of Google's public sample ids (app id "~...", ad units "/..."). */
    static final String TEST_PUBLISHER = "ca-app-pub-3940256099942544";
    private static final String APP_ID_KEY = "com.google.android.gms.ads.APPLICATION_ID";

    // Error codes of this plugin; the SDKs use non-negative codes.
    static final int ERROR_REFUSED = -1; // not one of Google's test ids
    static final int ERROR_NO_CONSENT = -2; // UMP does not allow ad requests (yet)
    static final int ERROR_NOT_READY = -3; // not initialized, no activity or nothing loaded

    private static final SignalInfo INITIALIZED =
            new SignalInfo("initialized", String.class, Boolean.class, String.class);
    private static final SignalInfo CONSENT_FORM_SHOWN = new SignalInfo("consent_form_shown");
    private static final SignalInfo CONSENT_RESULT =
            new SignalInfo("consent_result", String.class, Boolean.class, String.class);
    private static final SignalInfo INTERSTITIAL_LOADED = new SignalInfo("interstitial_loaded");
    private static final SignalInfo INTERSTITIAL_FAILED_TO_LOAD =
            new SignalInfo("interstitial_failed_to_load", Integer.class, String.class);
    private static final SignalInfo INTERSTITIAL_SHOWN = new SignalInfo("interstitial_shown");
    private static final SignalInfo INTERSTITIAL_FAILED_TO_SHOW =
            new SignalInfo("interstitial_failed_to_show", Integer.class, String.class);
    private static final SignalInfo INTERSTITIAL_CLOSED = new SignalInfo("interstitial_closed");

    // UI thread only.
    private ConsentInformation consent;
    private InterstitialAd interstitial;
    private boolean sdkStarted;
    private boolean consentBusy;
    private boolean testMode = true;
    private final List<String> testDeviceIds = new ArrayList<>();

    // Also read from the render thread.
    private volatile boolean initialized; // the app id passed the test-id guard
    private volatile boolean interstitialReady;

    public NachhallAdsPlugin(Godot godot) {
        super(godot);
    }

    @NonNull
    @Override
    public String getPluginName() {
        return "NachhallAds";
    }

    @NonNull
    @Override
    public Set<SignalInfo> getPluginSignals() {
        return new HashSet<>(Arrays.asList(INITIALIZED, CONSENT_FORM_SHOWN, CONSENT_RESULT,
                INTERSTITIAL_LOADED, INTERSTITIAL_FAILED_TO_LOAD, INTERSTITIAL_SHOWN,
                INTERSTITIAL_FAILED_TO_SHOW, INTERSTITIAL_CLOSED));
    }

    /**
     * Checks the manifest app id (must be Google's test id) and reads the consent decision cached
     * from an earlier session. Emits initialized(consent_status, can_request_ads, sdk_version);
     * consent_status "refused" means the guard stopped the plugin for good.
     *
     * @param test_mode UMP debug settings (EEA geography, forced test device); always on here.
     * @param test_device_hashed_ids optional comma-separated UMP test device ids (from logcat).
     */
    @UsedByGodot
    public void initialize(boolean test_mode, String test_device_hashed_ids) {
        runOnHostThread(() -> {
            Activity activity = getActivity();
            if (activity == null) {
                emitSignal(INITIALIZED, "unknown", false, "no activity");
                return;
            }
            String appId = manifestAppId(activity);
            if (appId == null || !appId.startsWith(TEST_PUBLISHER + "~")) {
                Log.e(TAG, "Refusing to run: AdMob app id is not Google's public test id: " + appId);
                emitSignal(INITIALIZED, "refused", false, "app id is not a Google test id");
                return;
            }
            testMode = test_mode;
            testDeviceIds.clear();
            if (test_device_hashed_ids != null) {
                for (String id : test_device_hashed_ids.split(",")) {
                    if (!id.trim().isEmpty()) {
                        testDeviceIds.add(id.trim());
                    }
                }
            }
            consent = UserMessagingPlatform.getConsentInformation(activity);
            initialized = true;
            Log.i(TAG, "Initialized with test app id " + appId + ", test mode " + testMode);
            emitSignal(INITIALIZED, consentStatus(activity), consent.canRequestAds(),
                    MobileAds.getVersion().toString());
        });
    }

    /**
     * UMP flow: refreshes the consent information, then shows the consent form if a decision is
     * required or, with force, the privacy options form so the player can change it. Emits
     * consent_form_shown() when a form appears, then always
     * consent_result(status, can_request_ads, error); status: granted | denied | not_required |
     * unknown (no decision, e.g. offline: ask again later).
     */
    @UsedByGodot
    public void request_consent(boolean force) {
        runOnHostThread(() -> {
            Activity activity = getActivity();
            if (!initialized || activity == null) {
                emitSignal(CONSENT_RESULT, "unknown", false, "not initialized");
                return;
            }
            if (consentBusy) {
                return; // the running flow emits the result
            }
            consentBusy = true;
            consent.requestConsentInfoUpdate(activity, consentParameters(activity),
                    () -> showConsentForm(activity, force),
                    error -> finishConsent(activity, error));
        });
    }

    /**
     * Loads one interstitial. unit_id must be a Google test unit; personalized false requests
     * non-personalised ads only. Emits interstitial_loaded() or
     * interstitial_failed_to_load(code, message).
     */
    @UsedByGodot
    public void load_interstitial(String unit_id, boolean personalized) {
        runOnHostThread(() -> {
            Activity activity = getActivity();
            if (unit_id == null || !unit_id.startsWith(TEST_PUBLISHER + "/")) {
                Log.e(TAG, "Refusing ad unit that is not a Google test unit: " + unit_id);
                emitSignal(INTERSTITIAL_FAILED_TO_LOAD, ERROR_REFUSED, "not a Google test ad unit");
                return;
            }
            if (!initialized || activity == null) {
                emitSignal(INTERSTITIAL_FAILED_TO_LOAD, ERROR_NOT_READY, "not initialized");
                return;
            }
            if (!consent.canRequestAds()) {
                emitSignal(INTERSTITIAL_FAILED_TO_LOAD, ERROR_NO_CONSENT, "consent does not allow ad requests");
                return;
            }
            if (!sdkStarted) {
                // Only after consent, and off the UI thread as Google recommends.
                sdkStarted = true;
                Context app = activity.getApplicationContext();
                new Thread(() -> MobileAds.initialize(app), "NachhallAdsInit").start();
            }
            MobileAds.setRequestConfiguration(MobileAds.getRequestConfiguration().toBuilder()
                    .setPublisherPrivacyPersonalizationState(personalized
                            ? RequestConfiguration.PublisherPrivacyPersonalizationState.DEFAULT
                            : RequestConfiguration.PublisherPrivacyPersonalizationState.DISABLED)
                    .build());
            InterstitialAd.load(activity, unit_id, new AdRequest.Builder().build(),
                    new InterstitialAdLoadCallback() {
                        @Override
                        public void onAdLoaded(@NonNull InterstitialAd ad) {
                            interstitial = ad;
                            interstitialReady = true;
                            emitSignal(INTERSTITIAL_LOADED);
                        }

                        @Override
                        public void onAdFailedToLoad(@NonNull LoadAdError error) {
                            Log.w(TAG, "Interstitial failed to load: " + error.getCode() + " " + error.getMessage());
                            emitSignal(INTERSTITIAL_FAILED_TO_LOAD, error.getCode(), error.getMessage());
                        }
                    });
        });
    }

    /** True while a loaded interstitial waits to be shown. */
    @UsedByGodot
    public boolean is_interstitial_ready() {
        return interstitialReady;
    }

    /**
     * Shows the loaded interstitial (each ad at most once). Emits interstitial_shown() and, when
     * the player closes it, interstitial_closed(); or interstitial_failed_to_show(code, message).
     */
    @UsedByGodot
    public void show_interstitial() {
        runOnHostThread(() -> {
            Activity activity = getActivity();
            InterstitialAd ad = interstitial;
            if (activity == null || ad == null) {
                emitSignal(INTERSTITIAL_FAILED_TO_SHOW, ERROR_NOT_READY, "no interstitial loaded");
                return;
            }
            interstitial = null;
            interstitialReady = false;
            ad.setFullScreenContentCallback(new FullScreenContentCallback() {
                @Override
                public void onAdShowedFullScreenContent() {
                    emitSignal(INTERSTITIAL_SHOWN);
                }

                @Override
                public void onAdFailedToShowFullScreenContent(@NonNull AdError error) {
                    Log.w(TAG, "Interstitial failed to show: " + error.getCode() + " " + error.getMessage());
                    emitSignal(INTERSTITIAL_FAILED_TO_SHOW, error.getCode(), error.getMessage());
                }

                @Override
                public void onAdDismissedFullScreenContent() {
                    emitSignal(INTERSTITIAL_CLOSED);
                }
            });
            ad.setImmersiveMode(true);
            ad.show(activity);
        });
    }

    /** Testing aid: forgets the UMP decision so the first-run consent flow can be repeated. */
    @UsedByGodot
    public void reset_consent() {
        runOnHostThread(() -> {
            if (consent != null) {
                consent.reset();
            }
        });
    }

    @Override
    public void onMainDestroy() {
        interstitial = null;
        interstitialReady = false;
    }

    private ConsentRequestParameters consentParameters(Activity activity) {
        ConsentRequestParameters.Builder params = new ConsentRequestParameters.Builder();
        if (testMode) {
            ConsentDebugSettings.Builder debug = new ConsentDebugSettings.Builder(activity)
                    .setDebugGeography(ConsentDebugSettings.DebugGeography.DEBUG_GEOGRAPHY_EEA)
                    .setForceTesting(true);
            for (String id : testDeviceIds) {
                debug.addTestDeviceHashedId(id);
            }
            params.setConsentDebugSettings(debug.build());
        }
        return params.build();
    }

    private void showConsentForm(Activity activity, boolean force) {
        if (force && consent.getPrivacyOptionsRequirementStatus()
                == ConsentInformation.PrivacyOptionsRequirementStatus.REQUIRED) {
            emitSignal(CONSENT_FORM_SHOWN);
            UserMessagingPlatform.showPrivacyOptionsForm(activity, error -> finishConsent(activity, error));
        } else if (consent.getConsentStatus() == ConsentInformation.ConsentStatus.REQUIRED
                && consent.isConsentFormAvailable()) {
            UserMessagingPlatform.loadConsentForm(activity, form -> {
                emitSignal(CONSENT_FORM_SHOWN);
                form.show(activity, error -> finishConsent(activity, error));
            }, error -> finishConsent(activity, error));
        } else {
            finishConsent(activity, null);
        }
    }

    private void finishConsent(Activity activity, FormError error) {
        consentBusy = false;
        String message = "";
        if (error != null) {
            message = error.getErrorCode() + ": " + error.getMessage();
            Log.w(TAG, "Consent flow: " + message);
        }
        emitSignal(CONSENT_RESULT, consentStatus(activity), consent.canRequestAds(), message);
    }

    /** UMP state in the vocabulary of the game's AdAdapter. */
    private String consentStatus(Context context) {
        int status = consent.getConsentStatus();
        if (status == ConsentInformation.ConsentStatus.NOT_REQUIRED) {
            return "not_required";
        }
        if (status == ConsentInformation.ConsentStatus.OBTAINED) {
            return personalizedAdsAllowed(context) ? "granted" : "denied";
        }
        return "unknown"; // REQUIRED (no decision yet) or UNKNOWN (e.g. offline)
    }

    /**
     * TCF v2 strings written by UMP: personalised ads need consent for purposes 1, 3 and 4 and
     * for Google (vendor 755). Where the GDPR does not apply the SDK decides by itself.
     * Simplification of this spike: legitimate-interest signals are not evaluated.
     */
    private static boolean personalizedAdsAllowed(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(
                context.getPackageName() + "_preferences", Context.MODE_PRIVATE);
        Object gdpr = prefs.getAll().get("IABTCF_gdprApplies");
        boolean applies = gdpr instanceof Integer ? (Integer) gdpr == 1 : "1".equals(String.valueOf(gdpr));
        if (!applies) {
            return true;
        }
        String purposes = prefs.getString("IABTCF_PurposeConsents", "");
        String vendors = prefs.getString("IABTCF_VendorConsents", "");
        return bit(purposes, 1) && bit(purposes, 3) && bit(purposes, 4) && bit(vendors, 755);
    }

    private static boolean bit(String bits, int id) {
        return bits != null && bits.length() >= id && bits.charAt(id - 1) == '1';
    }

    @SuppressWarnings("deprecation") // the ApplicationInfoFlags overload needs API 33, minSdk is 24
    private static String manifestAppId(Context context) {
        try {
            ApplicationInfo info = context.getPackageManager()
                    .getApplicationInfo(context.getPackageName(), PackageManager.GET_META_DATA);
            Bundle meta = info.metaData;
            return meta == null ? null : meta.getString(APP_ID_KEY);
        } catch (PackageManager.NameNotFoundException e) {
            return null;
        }
    }
}
