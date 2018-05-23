package com.unionpay;

import android.app.Activity;
import android.content.Intent;

import com.facebook.react.bridge.ActivityEventListener;
import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;

/**
 * Created by USER on 2018/5/17.
 */

public class UnionPayModule extends ReactContextBaseJavaModule implements ActivityEventListener {

    public UnionPayModule(ReactApplicationContext reactContext) {
        super(reactContext);
        reactContext.addActivityEventListener(this);
    }

    @Override
    public String getName() {
        return "UPPayControl";
    }

    private Promise mPromise;
    @ReactMethod
    public void pay(String tn,boolean isProduction,Promise promise){
        String mode = "01";
        if(isProduction){
            mode = "00";
        }
        mPromise = promise;
        UPPayAssistEx.startPay(getCurrentActivity(), null, null, tn, mode);
    }

    @Override
    public void onActivityResult(Activity activity, int requestCode, int resultCode, Intent data) {
        /*************************************************
         * 步骤3：处理银联手机支付控件返回的支付结果
         ************************************************/
        if (data == null || mPromise == null) {
            return;
        }
        String msg = "";
        /*
         * 支付控件返回字符串:success、fail、cancel 分别代表支付成功，支付失败，支付取消
         */
        String str = data.getExtras().getString("pay_result");
        if (str.equalsIgnoreCase("success")) {
            // 如果想对结果数据验签，可使用下面这段代码，但建议不验签，直接去商户后台查询交易结果
            // result_data结构见c）result_data参数说明
            if (data.hasExtra("result_data")) {
                String result = data.getExtras().getString("result_data");
                mPromise.resolve(result);
            }
            // 结果result_data为成功时，去商户后台查询一下再展示成功
        } else if (str.equalsIgnoreCase("fail")) {
            mPromise.reject("10002", "fail");
        } else if (str.equalsIgnoreCase("cancel")) {
            mPromise.reject("10003", "cancel");
        } else {
            mPromise.reject("10001", "error");
        }
    }


    @Override
    public void onNewIntent(Intent intent) {
        if(intent != null){
            String str = intent.getExtras().getString("pay_result");
        }
    }
}
