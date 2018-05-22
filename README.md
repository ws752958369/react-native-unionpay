#  react-native-giti-unionpay

银联支付，RN组件。
银联手机支付官网：https://open.unionpay.com/ajweb/product/detail?id=3

## install
npm install react-native-giti-unionpay --save

## link
react-native link react-native-giti-unionpay

## js前端调用步骤：
### 1.第一步导入头文件
    import UPPayControl from 'react-native-giti-unionpay';
### 2.新增方法
    UPPayControl.pay(tn,false).then((resp)=>{
        console.log("支付成功："+resp);
    },(err)=>{
        console.log("支付失败:"+err);
    });
这里的tn是后台服务器根据银联相关规则生成的订单信息；第二个参数为bool类型，表示是否为生产环境，如果不是则为false,否则为true.

## IOS配置步骤
### 1.导入依赖库文件.Targets -> Genneral -> Linked Frameworks And Libraries
  CFNetwork.framework <br />
  SystemConfiguration.framework <br />
  libz
### 2.Add Url Schemes
在info.plist下 新增 URL Schemes
  <key>CFBundleURLTypes</key>
  <array>
  <dict>
  <key>CFBundleURLName</key>
  <string>unionpay</string>
  <key>CFBundleURLSchemes</key>
  <array>
  <string>unionpay</string>
  </array>
  </dict>
  </array>
  ### 3.修改APPDelegate.m，导入头文件#import "UPPayControl.h"，新增方法：

//MARK:9.0以前使用的方法
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(id)annotation
{
  if ([url.host hasPrefix:@"uppayresult"]) {
    [UPPayControl handleCallBack:url];
    return YES;
  }
  return NO;
}

//MARK:9.0以后使用的方法
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
  if ([url.host hasPrefix:@"uppayresult"]) {
    [UPPayControl handleCallBack:url];
    return YES;
  }
  return NO;
}

