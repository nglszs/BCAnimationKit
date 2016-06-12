//
//  BaseViewController.m
//  BCAnimationKit
//
//  Created by Jack on 16/5/4.
//  Copyright © 2016年 毕研超. All rights reserved.
//

#import "BaseViewController.h"
#import "AppDelegate.h"
#import "BCKeyChain.h"
#import "BCClearCache.h"
#import "RealReachability.h"

@implementation BaseViewController

NSString * const KEY_USERNAME_PASSWORD = @"com.company.app.usernamepassword";
NSString * const KEY_USERNAME = @"com.company.app.username";
NSString * const KEY_PASSWORD = @"com.company.app.password";

- (void)viewDidLoad {
    [super viewDidLoad];
    
   //这里可以用单例也可以用AppDelegate，这里用AppDelegate来实现
    
    AppDelegate *newAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (newAppDelegate.isNightModel) {//这里也可以通过获取偏好存储，也就是说偏好和appdelegate二者取一0
       
        [self openNightModel];
        
    } else {
    
        [self openDayModel];
    
    }
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openDayModel) name:Day object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openNightModel) name:Night object:nil];
   
    
    
    //保存用户名和密码
    
   // NSMutableDictionary *usernamepasswordKVPairs = [NSMutableDictionary dictionary];
    //    [usernamepasswordKVPairs setObject:@"jack" forKey:KEY_USERNAME];
    //    [usernamepasswordKVPairs setObject:@"123" forKey:KEY_PASSWORD];
  //      [BCKeyChain save:KEY_USERNAME_PASSWORD data:usernamepasswordKVPairs];
    
    
    //获取用户名和密码
//    NSMutableDictionary *usernamepasswordKVPairs1 = (NSMutableDictionary *)[BCKeyChain load:KEY_USERNAME_PASSWORD];
//    NSString *name = [usernamepasswordKVPairs1 objectForKey:KEY_USERNAME];
//    NSString *pass = [usernamepasswordKVPairs1 objectForKey:KEY_PASSWORD];
//    
//    
//    NSLog(@"%@ -- %@",name,pass);
//    删除用户
//    [BCKeyChain delete:KEY_USERNAME_PASSWORD];

    
    //封装一个weakself
    //    WS(ws);
    //    ws.view
    
    
    //清除缓存
    
    // NSString *cacheSize = [BCClearCache getCacheSizeWithFilePath:filePath];
     //   NSLog(@"缓存大小为%@",cacheSize);
    
    //是否清除缓存成功
   // BOOL isSuccess = [BCClearCache clearCacheWithFilePath:filePath];
    
    
    //监听网络状态
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkChanged:)
                                                 name:kRealReachabilityChangedNotification
                                               object:nil];
    
    
    ReachabilityStatus status = [GLobalRealReachability currentReachabilityStatus];
   
    
    if (status == RealStatusNotReachable)
    {
        NSLog(@"无网络连接");

    }
    
    if (status == RealStatusViaWiFi)
    {
        NSLog(@"当前网络为WIFI");

    }
    
    if (status == RealStatusViaWWAN)
    {
         NSLog(@"手机网络");
    }
//
//下面这个方法也是监听网络的，只不过是block写的
//    [GLobalRealReachability reachabilityWithBlock:^(ReachabilityStatus status) {
//        switch (status)
//        {
//            case RealStatusNotReachable:
//            {
//                NSLog(@"Network unreachable!");
//                break;
//            }
//                
//            case RealStatusViaWiFi:
//            {
//                NSLog(@"Network wifi! Free!");
//                
//                break;
//            }
//                
//            case RealStatusViaWWAN:
//            {
//                NSLog(@"Network WWAN! In charge!");
//                
//                
//                WWANAccessType accessType = [GLobalRealReachability currentWWANtype];
//                
//                if (status == RealStatusViaWWAN)
//                {
//                    if (accessType == WWANType2G)
//                    {
//                        NSLog(@"RealReachabilityStatus2G");
//                    }
//                    else if (accessType == WWANType3G)
//                    {
//                        NSLog(@"RealReachabilityStatus3G");
//                    }
//                    else if (accessType == WWANType4G)
//                    {
//                        NSLog(@"RealReachabilityStatus4G");
//                        
//                    }
//                    else
//                    {
//                        NSLog(@"Unknown RealReachability WWAN Status, might be iOS6");
//                    }
//                }
//                
//                break;
//            }
//                
//            default:
//                break;
//        }
//    }];
// 
    

    //下面这个方法是参考知乎的退出app后再次进入会自动跳转上一次进入的界面
    
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationWillResignActiveNotification object:nil];
}
#pragma mark  进入后台的通知
- (void)appDidEnterBackground {


    NSLog(@"当前的界面为%@",NSStringFromClass([self class]));
    
   
        
        [[NSUserDefaults standardUserDefaults] setObject:NSStringFromClass([self class]) forKey:@"MAIN"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
   


}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    NSLog(@"当前界面已释放");

}

- (void)openNightModel {

    NSLog(@"开启夜间模式");

}
- (void)openDayModel {



}

- (void)sendData:(void (^)(BOOL))block {


    if (block) {
        block(YES);
    }


}
- (void)networkChanged:(NSNotification *)notification
{
    RealReachability *reachability = (RealReachability *)notification.object;
    ReachabilityStatus status = [reachability currentReachabilityStatus];
  //  ReachabilityStatus previousStatus = [reachability previousReachabilityStatus];
//    NSLog(@"networkChanged, currentStatus:%@, previousStatus:%@", @(status), @(previousStatus));
    
    if (status == RealStatusNotReachable)
    {
       NSLog(@"无网络");
    }
    
    if (status == RealStatusViaWiFi)
    {
        NSLog(@"WIFI");
    }
    
    if (status == RealStatusViaWWAN)
    {
        NSLog(@"手机网");
    }
    
    WWANAccessType accessType = [GLobalRealReachability currentWWANtype];
    
    if (status == RealStatusViaWWAN)
    {
        if (accessType == WWANType2G)
        {
          NSLog(@"2G");
        }
        else if (accessType == WWANType3G)
        {
            NSLog(@"3G");
        }
        else if (accessType == WWANType4G)
        {
            NSLog(@"4G");

        }
        else
        {
          NSLog(@"Unknown RealReachability WWAN Status, might be iOS6");
        }
    }
    
    
}

//汉字转拼音
//- (NSString *)chineseToPinyin:(NSString *)chinese withSpace:(BOOL)withSpace {
//    CFStringRef hanzi = (__bridge CFStringRef)chinese;
//    CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, hanzi);
//    CFStringTransform(string, NULL, kCFStringTransformMandarinLatin, NO);
//    CFStringTransform(string, NULL, kCFStringTransformStripDiacritics, NO);
//    NSString *pinyin = (NSString *)CFBridgingRelease(string);
//    if (!withSpace) {
//        pinyin = [pinyin stringByReplacingOccurrencesOfString:@" " withString:@""];
//    }
//    return pinyin;
//}
@end
