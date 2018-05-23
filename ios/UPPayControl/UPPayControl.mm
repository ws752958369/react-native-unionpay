//
//  UPPayControl.m
//
//  Created by wangsheng on 2018/5/11.
//  Copyright © 2018年 Facebook. All rights reserved.
//

#import "UPPayControl.h"
#import "UPPaymentControl.h"

static RCTPromiseResolveBlock UPPay_resolve;
static RCTPromiseRejectBlock UPPay_reject;

@implementation UPPayControl
//MARK:必须实现协议，指定模块名，如果不规定模块名，那么将以类名作为模块名（UPPayControl）；
RCT_EXPORT_MODULE();


RCT_REMAP_METHOD(pay, payTN:(NSString *)tn isProduction:(BOOL)isProduction resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
{
    //取URL Schemes
    NSArray *urls = [[NSBundle mainBundle] infoDictionary][@"CFBundleURLTypes"];
    NSMutableString *appScheme = [NSMutableString string];
    BOOL multiUrls = [urls count] > 1;
    for (NSDictionary *url in urls) {
        NSArray *schemes = url[@"CFBundleURLSchemes"];
        if (!multiUrls ||
            (multiUrls && [@"unionpay-giti" isEqualToString:url[@"CFBundleURLName"]])) {
            [appScheme appendString:schemes[0]];
            break;
        }
    }
    
    if ([appScheme isEqualToString:@""]) {
        NSString *error = @"url scheme cannot be empty";
        reject(@"10000", error, [NSError errorWithDomain:error code:10000 userInfo:NULL]);
        return;
    }
    
    UPPay_resolve = resolve;
    UPPay_reject = reject;
    
    NSString *model = isProduction?@"00":@"01";//00对应正式环境，01对应测试环境
    dispatch_async(dispatch_get_main_queue(), ^{
        [[UPPaymentControl defaultControl] startPay:tn fromScheme:appScheme mode:model viewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    });
}

//MARK:处理银联支付回调逻辑
+(void)handleCallBack:(NSURL *)url
{
    if ([url.host hasPrefix:@"uppayresult"]) {
        [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
            if ([code isEqual:@"cancel"]) {
                //交易取消
                NSString *error = @"cancel";
                UPPay_reject(@"10003",error, [NSError errorWithDomain:error code:10003 userInfo:data]);
            }else if ([code isEqual:@"success"]){
                //交易成功
                UPPay_resolve(@[data]);
            }else if ([code isEqual:@"fail"]){
                //交易失败
                NSString *error = @"fail";
                UPPay_reject(@"10002",error, [NSError errorWithDomain:error code:10002 userInfo:data]);
            }else{
                //交易出错
                NSString *error = @"error";
                UPPay_reject(@"10001",error, [NSError errorWithDomain:error code:10001 userInfo:data]);
            }
        }];
    }
}

@end
