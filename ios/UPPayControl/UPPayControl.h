//
//  UPPayControl.h
//  UPPayControl
//
//  Created by wangsheng on 2018/5/11.
//  Copyright © 2018年 wangsheng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"

@interface UPPayControl : NSObject <RCTBridgeModule>
+ (void)handleCallBack:(NSURL *)url;
@end
