package com.facebook.cordova;

import android.os.Bundle;
import android.util.Log;

import com.facebook.FacebookSdk;
import com.facebook.LoggingBehavior;
import com.facebook.appevents.AppEventsConstants;
import com.facebook.appevents.AppEventsLogger;

import org.apache.cordova.BuildConfig;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.math.BigDecimal;
import java.util.Currency;
import java.util.Iterator;

public class FacebookPlugin extends CordovaPlugin {

    private static final String TAG = "FacebookPlugin";
    private AppEventsLogger logger;

    @Override protected void pluginInitialize() {
        Log.e(TAG, "plugin initialized");

        FacebookSdk.sdkInitialize(cordova.getActivity().getApplicationContext());

        if (BuildConfig.DEBUG) {
            FacebookSdk.setIsDebugEnabled(true);
            FacebookSdk.addLoggingBehavior(LoggingBehavior.APP_EVENTS);
        }

        logger = AppEventsLogger.newLogger(cordova.getActivity());
    }

    @Override
    public void onResume(boolean multitasking) {
        super.onResume(multitasking);

        if (!BuildConfig.DEBUG) {
            // Logs 'install' and 'app activate' App Events.
            AppEventsLogger.activateApp(cordova.getActivity());
        }
    }

    @Override
    public void onPause(boolean multitasking) {
        super.onPause(multitasking);

        if (!BuildConfig.DEBUG) {
            // Logs 'app deactivate' App Event.
            AppEventsLogger.deactivateApp(cordova.getActivity());
        }
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (BuildConfig.DEBUG) {
            return false;
        }

        if ("logPurchase".equals(action)) {
            logPurchase(args);
            return true;
        } else if ("logEvent".equals(action)) {
            logEvent(args);
            return true;
        }

        return false;
    }

    private void logPurchase(JSONArray args) {
        BigDecimal purchaseAmount = BigDecimal.valueOf(optArgDouble(args, 0));
        String currencyString = optArgString(args, 1);
        Currency currency = Currency.getInstance(isNullOrEmpty(currencyString) ? "USD" : currencyString);
        Bundle parameters = makeParameters(args.optJSONObject(2));

        logger.logPurchase(purchaseAmount, currency, parameters);
    }

    private void logEvent(JSONArray args) {
        String eventName = stringToAppEventConstantValue(optArgString(args, 0));
        Double valueToSum = optArgDouble(args, 1);
        Bundle parameters = makeParameters(args.optJSONObject(2));

        logger.logEvent(eventName, valueToSum, parameters);
    }

    private static Bundle makeParameters(JSONObject jsonObject) {
        Bundle parameters = new Bundle();

        if (jsonObject != null) {

            Iterator<String> keysIter = jsonObject.keys();

            while (keysIter.hasNext()) {
                String key = keysIter.next();
                Object value = jsonObject.isNull(key) ? null : jsonObject.opt(key);

                key = stringToAppEventConstantValue(key);

                if (value != null) {
                    if (value instanceof Integer){
                        parameters.putInt(key, (Integer) value);
                    } else if(value instanceof Double){
                        parameters.putDouble(key, (Double) value);
                    } else if(value instanceof Float){
                        parameters.putFloat(key, (Float) value);
                    } else if(value instanceof Long){
                        parameters.putLong(key, (Long) value);
                    } else if(value instanceof String){
                        parameters.putString(key, (String) value);
                    } else if (value instanceof Boolean) {
                        parameters.putString(key, (Boolean) value ?
                                AppEventsConstants.EVENT_PARAM_VALUE_YES :
                                AppEventsConstants.EVENT_PARAM_VALUE_NO);
                    }
                }
            }
        }

        return parameters;
    }

    public static String stringToAppEventConstantValue(String key) {
        try {
            // maybe convert string constant name to constant value
            return (String) AppEventsConstants.class.getField(key).get(null);
        } catch (Exception e) {
            return key;
        }
    }

    public static String optArgString(JSONArray args, int index) {
        return args.isNull(index) ? null : args.optString(index);
    }

    public static Double optArgDouble(JSONArray args, int index) {
        return args.isNull(index) ? null : args.optDouble(index);
    }

    public static boolean isNullOrEmpty(String str) {
        return str == null || str.isEmpty();
    }
}