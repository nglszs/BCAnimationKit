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


@implementation BaseViewController

NSString * const KEY_USERNAME_PASSWORD = @"com.jack.app.usernamepassword";;
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
//   NSLog(@"%@ -- %@",name,pass);
//    删除用户
//    [BCKeyChain delete:KEY_USERNAME_PASSWORD];

    
    //封装一个weakself
    //    WS(ws);
    //    ws.view
    
     
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


    if (block) {//这里暂时用block代替，如果是网络请求可以用来判断是否有返回数据
        block(YES);
    }


}
#pragma  mark  网络请求缓存框架,这里用etag和LastModified两种方法结合


- (void)getDataFromInternet:(GetDataCompletion)completion {
    //支持etag
   NSString *kETagImageURL = @"http://ac-g3rossf7.clouddn.com/xc8hxXBbXexA8LpZEHbPQVB.jpg";
    
    //下面这个链接不支持etag
    NSString *kLastModifiedImageURL = @"http://image17-c.poco.cn/mypoco/myphoto/20151211/16/17338872420151211164742047.png";

    
    //上面不管用哪个连接，这里都会进行缓存，下面进行了判断
    NSURL *url = [NSURL URLWithString:kETagImageURL];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];

    if (isEtag) {
        // 发送 etag
        if (self.etag.length > 0) {
            [request setValue:self.etag forHTTPHeaderField:@"If-None-Match"];
        }

    } else {
    
        if (self.localLastModified.length > 0) {
            [request setValue:self.localLastModified forHTTPHeaderField:@"If-Modified-Since"];
        }

    
    }

    //请求
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
       
        //判断是否支持etag
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

        if (httpResponse.allHeaderFields[@"Etag"]) {
            
            isEtag = YES;
            NSLog(@"支持etag");
            
            if (httpResponse.statusCode == 304) {
                
                NSLog(@"加载本地缓存图片");
                // 如果是，使用本地缓存
                // 根据请求获取到`被缓存的响应`！
                NSCachedURLResponse *cacheResponse =  [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
                // 拿到缓存的数据
                data = cacheResponse.data;
           
            }
            
            // 获取并且纪录 etag，区分大小写
            self.etag = httpResponse.allHeaderFields[@"Etag"];
            

        } else {
        
            NSLog(@"不支持etag");
            isEtag = NO;
        
            if (httpResponse.statusCode == 304) {
                NSLog(@"加载本地缓存图片");
                // 如果是，使用本地缓存
                // 根据请求获取到`被缓存的响应`！
                NSCachedURLResponse *cacheResponse =  [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
                // 拿到缓存的数据
              
                data = cacheResponse.data;
            }
            
            // 获取并且纪录 LastModified
            self.localLastModified = httpResponse.allHeaderFields[@"Last-Modified"];
        
        }
        
        
        if (data) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
               
                completion(data);
            });
        }
        
        
    }] resume];

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    //[self getDataFromInternet:^(NSData *data) {
   
//    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
//    image.image = [UIImage imageWithData:data];
//    [[UIApplication sharedApplication].keyWindow addSubview:image];
    
//}];

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

//返回文字高度
//- (CGFloat)getStringHeightNotFormatWith:(NSString*)tempStr width:(CGFloat)tempWidth font:(UIFont*)tempFont {
//    
//    CGRect rect = [tempStr boundingRectWithSize:CGSizeMake(tempWidth, 0)
//                                        options:NSStringDrawingUsesLineFragmentOrigin|        NSStringDrawingUsesDeviceMetrics|NSStringDrawingUsesFontLeading
//                                     attributes:@{NSFontAttributeName:tempFont}
//                                        context:nil];
//    //文字的高度
//    float tempHeight = rect.size.height;
//    
//    return tempHeight;
//}



//四舍五入浮点数使用方法
 //NSLog(@"----%@---",[self decimalwithFormat:@"0" value:1.848]);

//- (NSString *) decimalwithFormat:(NSString *)format  value:(CGFloat)tempValue
//{
//    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
//    
//    [numberFormatter setPositiveFormat:format];
//    
//    return  [numberFormatter stringFromNumber:[NSNumber numberWithFloat:tempValue]];
//}


//下面这个方法获取当前应用所占的存储空间，或者单独计算  下面给出方法
//   NSLog(@"%@",[BCClearCache getCacheSizeWithFilePath:NSHomeDirectory()]);
//
//    //这个方法获取整个设备的存储空间用量
//    NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;
//    NSFileManager* fileManager = [[NSFileManager alloc ]init];
// NSDictionary *fileSysAttributes = [fileManager attributesOfFileSystemForPath:path error:nil];
//    NSNumber *freeSpace = [fileSysAttributes objectForKey:NSFileSystemFreeSize];
//    NSNumber *totalSpace = [fileSysAttributes objectForKey:NSFileSystemSize];
//    NSString *text = [NSString stringWithFormat:@"已占用%0.1fG/剩余%0.1fG",([totalSpace longLongValue] - [freeSpace longLongValue])/1000.0/1000.0/1000.0,[freeSpace longLongValue]/1000.0/1000.0/1000.0];
//    NSLog(@"%@",text);





//计算缓存大小，这里路径写死了，这个和上面计算缓存同理，上面计算缓存是单独写成一个类
//-(float)getCacheSizeAtPath {
//    
//    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSFileManager* manager = [NSFileManager defaultManager];
//    if (![manager fileExistsAtPath:cachPath]) return 0;
//    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:cachPath] objectEnumerator];//从前向后枚举器
//    NSString* fileName;
//    long long folderSize = 0;
//    while ((fileName = [childFilesEnumerator nextObject]) != nil){
//        
//        NSString* fileAbsolutePath = [cachPath stringByAppendingPathComponent:fileName];
//        
//        folderSize += [self fileSizeAtPath:fileAbsolutePath];
//    }
//    
//    return folderSize/(1000.0 * 1000.0);
//}
//- (long long)fileSizeAtPath:(NSString*)filePath{
//    NSFileManager* manager = [NSFileManager defaultManager];
//    if ([manager fileExistsAtPath:filePath]){
//        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
//    }
//    return 0;
//}
//
////清除缓存
//- (void)clearCacheAtPath {
//    
//    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    
//    NSFileManager *fileManager=[NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:path]) {
//        NSArray *childerFiles=[fileManager subpathsAtPath:path];
//        for (NSString *fileName in childerFiles) {
//            //如有需要，加入条件，过滤掉不想删除的文件
//            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
//            [fileManager removeItemAtPath:absolutePath error:nil];
//        }
//    }
//}




//下面这个方法用来实现登录按钮和输入框的联动，有两种方式，个人倾向第二种，如果用通知会大材小用
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//   
//      [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(change:) name:UITextFieldTextDidChangeNotification object:self.name];
//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(change:) name:UITextFieldTextDidChangeNotification object:self.password];
//    
//    
//    [self.name addTarget:self action:@selector(change:) forControlEvents:UIControlEventEditingChanged];
//    
//    [self.password addTarget:self action:@selector(change:) forControlEvents:UIControlEventEditingChanged];
//    
//    
//    
//}
//
//-(void)change:(NSNotification *)notif
//{
//    
//    
//    if (self.name.text.length >= 6 && self.password.text.length >= 3) {
//        
//        self.login.enabled = YES;
//    } else {
//        
//        self.login.enabled = NO;
//    }
//    
//    
//    
//    
//}



#pragma mark gcd 定时器 创建及释放，下面分别写在两个方法里


//@property (nonatomic, strong) dispatch_source_t timer;
//
//{
//dispatch_queue_t queue = dispatch_get_main_queue();
//self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
//
//
//dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC));//什么时候开始
//uint64_t interval = (uint64_t)(3.0 * NSEC_PER_SEC);//间隔
//dispatch_source_set_timer(self.timer, start, interval, 0);
//dispatch_source_set_event_handler(self.timer, ^{
//    
//    //做一些事
//    
//    
//    
//});
//
//dispatch_resume(self.timer);//开始
//
//}
//
//
////停止
//{
//dispatch_cancel(self.timer);
//self.timer = nil;
//}



#pragma mark 单个删除按钮，多个删除可以看云盘

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        [msgListArray removeObjectAtIndex:indexPath.row];
//        
//        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//        
//    }
//    
//}


#pragma mark  创建文件夹的用法~~二级文件夹和三级文件夹
//// 获得沙盒中Documents文件夹路径
//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//NSString *documentsPath = [paths objectAtIndex:0];
//
//
//
//// 二级文件夹~test文件夹
//NSFileManager *fileManager = [NSFileManager defaultManager];
//NSString *testDirectory = [documentsPath stringByAppendingPathComponent:@"test"];
//[fileManager createDirectoryAtPath:testDirectory withIntermediateDirectories:YES attributes:nil error:nil];
//
//// 在test文件夹中创建三个测试文件（test1.txt/test2.txt/test3.txt），并写入数据
//NSString *test1FilePath = [testDirectory stringByAppendingPathComponent:@"test1.txt"];
//NSString *test2FilePath = [testDirectory stringByAppendingPathComponent:@"test2.txt"];
//NSString *test3FilePath = [testDirectory stringByAppendingPathComponent:@"test3.txt"];
//// 三个文件的内容
//NSString *test1Content = @"helloWorld";
//NSString *test2Content = @"helloTest2";
//NSString *test3Content = @"helloTest3";
//// 写入对应文件
//[fileManager createFileAtPath:test1FilePath contents:[test1Content dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
//[fileManager createFileAtPath:test2FilePath contents:[test2Content dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
//[fileManager createFileAtPath:test3FilePath contents:[test3Content dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
//
////创建三级文件夹 subtest
//NSString *subtestDirectoryPath = [testDirectory stringByAppendingPathComponent:@"subtest"];
//[fileManager createDirectoryAtPath:subtestDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil];
//
//// 创建三个子文件
//
//[fileManager createFileAtPath:[subtestDirectoryPath stringByAppendingPathComponent:@"subtest1.txt"] contents:nil attributes:nil];
//[fileManager createFileAtPath:[subtestDirectoryPath stringByAppendingPathComponent:@"subtest2.txt"] contents:nil attributes:nil];
//[fileManager createFileAtPath:[subtestDirectoryPath stringByAppendingPathComponent:@"subtest3.txt"] contents:nil attributes:nil];
//
//
//
//NSLog(@"ddd%@",[fileManager subpathsAtPath:subtestDirectoryPath]);

#pragma mark 开发中的小技巧

/**
NSInteger count = 5;
//02代表:如果count不足2位 用0在最前面补全(2代表总输出的个数)
NSString *string = [NSString stringWithFormat:@"%02zd",count];
//输出结果是: 05
NSLog(@"%@", string);



NSInteger count = 50;
//%是一个特殊符号 如果在NSString中用到%需要如下写法
NSString *string = [NSString stringWithFormat:@"%zd%%",count];
//输出结果是: 50%
NSLog(@"%@", string);
 
 
 NSInteger count = 50;
 //"是一个特殊符号, 如果在NSString中用到"需要用\进行转义
 NSString *string = [NSString stringWithFormat:@"%zd\"",count];
 //输出结果是: 50"
 NSLog(@"%@", string);
 
 
 
 bloc里有定时器打印值的时候必须强引用他才有效
 LRWeakSelf(shop);
 shop.myBlock = ^{
 //强引用
 LRStrongSelf(shop)
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 NSLog(@"%@",shop.string);
 });
 };
 shop.myBlock();
 
 
 
5. 自定义控件里如何拿到导航控制器进行页面跳转
 如果有UITabBarController我们会这样获取导航控制器:
 
 UIViewController *viewC = [[UIViewController alloc]init];
 // 取出当前的导航控制器
 UITabBarController *tabBarVc = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
 //The view controller associated with the currently selected tab item
 //当前选择的导航控制器
 UINavigationController *navC = (UINavigationController *)tabBarVc.selectedViewController;
 [navC pushViewController:viewC animated:YES];
 
 
 
 如果通过modal出来的控制器并且用UITabBarController不好使, 我们会这样获取导航控制器:
 UIViewController *viewC = [[UIViewController alloc]init];
 //获取最终的根控制器
 UIViewController *rootC = [UIApplication sharedApplication].keyWindow.rootViewController;
 //如果是modal出来的控制器,它就会通过presentedViewController拿到上一个控制器
 UINavigationController *navC = (UINavigationController *)rootC.presentedViewController;
 [navC pushViewController:viewC animated:YES];
 
 
 6.修改了leftBarButtonItem如何恢复系统侧滑返回功能
 self.interactivePopGestureRecognizer.delegate = self;
 #pragma mark - <UIGestureRecognizerDelegate>
 //实现代理方法:return YES :手势有效, NO :手势无效
 - (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
 {
 //当导航控制器的子控制器个数 大于1 手势才有效
 return self.childViewControllers.count > 1;
 }
 
 
7。 等线程1和2都执行完再做些事情
 dispatch_group_t group = dispatch_group_create();
 dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
 //线程一
 });
 dispatch_group_async(group, dispatch_get_global_queue(0,0), ^{
 // 线程二
 });
 dispatch_group_notify(group, dispatch_get_global_queue(0,0), ^{
 //汇总
 });
 
 
 8.录屏
 
 - (void)viewDidLoad {
 [super viewDidLoad];
 
  
 
 
 UIButton *startBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 100, 100)];
 [self.view addSubview:startBtn];
 startBtn.backgroundColor = [UIColor blueColor];
 [startBtn setTitle:@"开始录制" forState:UIControlStateNormal];
 [startBtn addTarget:self action:@selector(start:) forControlEvents:UIControlEventTouchUpInside];
 
 
 UIButton *endBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
 [self.view addSubview:endBtn];
 endBtn.backgroundColor = [UIColor blueColor];
 [endBtn setTitle:@"结束录制" forState:UIControlStateNormal];
 [endBtn addTarget:self action:@selector(end:) forControlEvents:UIControlEventTouchUpInside];
 }
 
 
 - (void)start:(UIButton *)btn {
 RPScreenRecorder *recorder = [RPScreenRecorder sharedRecorder];
 [recorder startRecordingWithMicrophoneEnabled:YES handler:^(NSError * _Nullable error) {
 if (error) {
 NSLog(@"start recorder error - %@",error);
 }
 [btn setTitle:@"开始啦" forState:UIControlStateNormal];
 }];
 
 }
 
 - (void)end:(UIButton *)btn {
 RPScreenRecorder *recorder = [RPScreenRecorder sharedRecorder];
 [recorder stopRecordingWithHandler:^(RPPreviewViewController * _Nullable previewViewController, NSError * _Nullable error) {
 
 previewViewController.previewControllerDelegate = self;
 [self presentViewController:previewViewController animated:NO completion:^{
 NSLog(@"开始播放啦");
 }];
 }];
 
 
 }
 - (void)previewControllerDidFinish:(RPPreviewViewController *)previewController
 {
 [previewController dismissViewControllerAnimated:YES completion:nil];
 }
 
# 保存图片
 
 NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"bc.jpg"], 0.5);
 
 
 NSString *subPath = [kPathCache stringByAppendingPathComponent:@"IMG"];//二级文件
 NSString *str = @"Jack111";
 NSString *imageName = [NSString stringWithFormat:@"%@.jpg", str];
 NSString *imagePath = [subPath stringByAppendingPathComponent:imageName];
 [[NSFileManager defaultManager] createDirectoryAtPath:[imagePath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
 
 BOOL hehe = [imageData writeToFile:imagePath atomically:NO];
 
 if (hehe) {
 
 NSLog(@"%@",imagePath);
 } else {
 
 NSLog(@"失败");
 }
 UIImageView *im = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
 
 im.image = [UIImage imageWithContentsOfFile:[imagePath stringByExpandingTildeInPath]];//这里是为了获取绝对路径，因为每一次更新应用路径都会改变，这里是为了自动生成新的路径
 im.backgroundColor = [UIColor redColor];
 [self.view addSubview:im];

 
 
 
 */


/**
 *  有时候writetofile失败，就需要创建文件夹，这个在多级文件夹下回出现,也可以用上面的nsfilemanage方法
 */

//- (NSString *)getImagePath{
//    
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *path = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"IMG"];
//    NSFileManager *manager = [[NSFileManager alloc]init];
//    if (![manager fileExistsAtPath:path]) {
//        NSError *error ;
//        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
//        if (error) {
//            //            NSLog(@"creat error : %@",error.description);
//        }
//    }
//    
//    
//    
//    return path;
//}

#pragma mark 监听设备旋转旋转的角度


//[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//
//
///**
// *  添加 设备旋转 通知
// *
// *  当监听到 UIDeviceOrientationDidChangeNotification 通知时，调用handleDeviceOrientationDidChange:方法
// *  @param handleDeviceOrientationDidChange: handleDeviceOrientationDidChange: description
// *
// *  @return return value description
// */
//[[NSNotificationCenter defaultCenter] addObserver:self
//                                         selector:@selector(handleDeviceOrientationDidChange:)
//                                             name:UIDeviceOrientationDidChangeNotification
//                                           object:nil
// ];
//
//
///**
// *  销毁 设备旋转 通知
// *
// *  @return return value description
// */
//[[NSNotificationCenter defaultCenter] removeObserver:self
//                                                name:UIDeviceOrientationDidChangeNotification
//                                              object:nil
// ];
//
//
///**
// *  结束 设备旋转通知
// *
// *  @return return value description
// */
//[[UIDevice currentDevice]endGeneratingDeviceOrientationNotifications];
//
//
//- (void)handleDeviceOrientationDidChange:(UIInterfaceOrientation)interfaceOrientation
//{
//    //1.获取 当前设备 实例
//    UIDevice *device = [UIDevice currentDevice] ;
//    
//    
//    
//    
//    /**
//     *  2.取得当前Device的方向，Device的方向类型为Integer
//     *
//     *  必须调用beginGeneratingDeviceOrientationNotifications方法后，此orientation属性才有效，否则一直是0。orientation用于判断设备的朝向，与应用UI方向无关
//     *
//     *  @param device.orientation
//     *
//     */
//    
//    switch (device.orientation) {
//        case UIDeviceOrientationFaceUp:
//            NSLog(@"屏幕朝上平躺");
//            break;
//            
//        case UIDeviceOrientationFaceDown:
//            NSLog(@"屏幕朝下平躺");
//            break;
//            
//            //系統無法判斷目前Device的方向，有可能是斜置
//        case UIDeviceOrientationUnknown:
//            NSLog(@"未知方向");
//            break;
//            
//        case UIDeviceOrientationLandscapeLeft:
//            NSLog(@"屏幕向左横置");
//            break;
//            
//        case UIDeviceOrientationLandscapeRight:
//            NSLog(@"屏幕向右橫置");
//            break;
//            
//        case UIDeviceOrientationPortrait:
//            NSLog(@"屏幕直立");
//            break;
//            
//        case UIDeviceOrientationPortraitUpsideDown:
//            NSLog(@"屏幕直立，上下顛倒");
//            break;
//            
//        default:
//            NSLog(@"无法辨识");
//            break;
//    }
//    
//}

#pragma mark  并发控制

//- (NSOperationQueue *)queue
//{
//    if (_queue == nil) {
//        _queue = [[NSOperationQueue alloc] init];
//          _queue.maxConcurrentOperationCount = 3; // 最大并发数
//    }
//    return _queue;
//}
//
//- (void)hehe:(int)num {
//    
//    
//    [self.queue waitUntilAllOperationsAreFinished];//加上这句线程就会一步一步执行
//    
//    
//    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
//        
//        NSLog(@"%d",num);
//        
//        
//    }];
//    
//    
//    [self.queue addOperation:op];
//    
//}


#pragma mark 按钮动画用在多张图片选择时

//self.backGroudView.transform =CGAffineTransformMakeScale(0, 0);
//[UIView animateWithDuration:0.2 animations:^{
//    self.backGroudView.transform = CGAffineTransformMakeScale(1.1, 1.1);
//}
//                 completion:^(BOOL finished){
//                     [UIView animateWithDuration:0.1 animations:^{
//                         self.backGroudView.transform = CGAffineTransformMakeScale(1.0, 1.0);
//                     }];
//                 }];
//


#pragma mark 控制多张图片上传时的顺序
//dispatch_group_t group = dispatch_group_create();
//
//__block BOOL error = NO;
//
//[self.uploadImageArray enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL * _Nonnull stop) {
//    
//    dispatch_group_enter(group);
//    [[AFFileClient sharedClient] upload:@"app/upload_file/imageList"
//                             parameters:nil
//                                  files:@{@"upload":UIImageJPEGRepresentation(image, 0.8)}
//                               complete:^(ResponseData *response) {
//                                   dispatch_group_leave(group);
//                                   if (response.success) {
//                                       NSLog(@"第%@张图片上传完成...",@(idx));
//                                   }
//                                   else {
//                                       error = YES;
//                                       NSLog(@"第%@张图片上传失败：%@",@(idx),response.message);
//                                   }
//                               }];
//}];
//
//dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//    [self doSomethingWhenAllImageUpload:error];
//});


#pragma mark kvo监听按钮是否点击，类似于反射，用来vc种tableview点击了cell此时将改变按钮的状态，此时对按钮进行监听，类似于一种反射机制

//[self.selectedBtn addObserver:self forKeyPath:@"selected" options:NSKeyValueObservingOptionNew context:nil];


//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
//    
//    if ([keyPath isEqualToString:@"selected"] && object == self.selectedBtn) {
//        
//        
//        NSLog(@"%@",[change objectForKey:@"new"]);
//        
//        
//        if ([[change objectForKey:@"new"] integerValue] == 1) {
//            
//            dayLabel.textColor = [UIColor whiteColor];
//        } else {
//            
//            dayLabel.textColor = COLOR(174, 143, 101, 1);
//        }
//        
//        
//    } else {
//        
//        
//        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
//        
//    }
//    
//    
//    
//    
//    
//}
//
//- (void)willMoveToSuperview:(UIView *)newSuperview {
//    
//    if (!newSuperview) {
//        
//        
//        [self.selectedBtn removeObserver:self forKeyPath:@"selected" context:nil];
//    }
//    
//}

#pragma mark 删除数组及字典里的null，这个使用递归，第二种方法不是递归

//- (NSMutableArray *)removeNullFromArray:(NSArray *)arr
//{
//    NSMutableArray *marr = [NSMutableArray array];
//    for (int i = 0; i < arr.count; i++) {
//        NSValue *value = arr[i];
//        // 删除NSDictionary中的NSNull，再添加进数组
//        if ([value isKindOfClass:NSDictionary.class]) {
//            [marr addObject:[self removeNullFromDictionary:(NSDictionary *)value]];
//        }
//        // 删除NSArray中的NSNull，再添加进数组
//        else if ([value isKindOfClass:NSArray.class]) {
//            [marr addObject:[self removeNullFromArray:(NSArray *)value]];
//        }
//        // 剩余的非NSNull类型的数据添加进数组
//        else if (![value isKindOfClass:NSNull.class]) {
//            [marr addObject:value];
//        }
//    }
//    return marr;
//}
//// 删除Dictionary中的NSNull
//- (NSMutableDictionary *)removeNullFromDictionary:(NSDictionary *)dic
//{
//    NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
//    for (NSString *strKey in dic.allKeys) {
//        NSValue *value = dic[strKey];
//        // 删除NSDictionary中的NSNull，再保存进字典
//        if ([value isKindOfClass:NSDictionary.class]) {
//            mdic[strKey] = [self removeNullFromDictionary:(NSDictionary *)value];
//        }
//        // 删除NSArray中的NSNull，再保存进字典
//        else if ([value isKindOfClass:NSArray.class]) {
//            mdic[strKey] = [self removeNullFromArray:(NSArray *)value];
//        }
//        // 剩余的非NSNull类型的数据保存进字典
//        else if (![value isKindOfClass:NSNull.class]) {
//            mdic[strKey] = dic[strKey];
//        }
//    }
//    return mdic;
//}
//- (NSObject *)removeNullFrom:(NSObject *)object
//{
//    NSObject *objResult = nil;
//    NSMutableArray *marrSearch = nil;
//    if ([object isKindOfClass:NSNull.class]) {
//        return nil;
//    }
//    else if ([object isKindOfClass:NSArray.class]) {
//        objResult = [NSMutableArray arrayWithArray:(NSArray *)object];
//        marrSearch = [NSMutableArray arrayWithObject:objResult];
//    }
//    else if ([object isKindOfClass:NSDictionary.class]) {
//        objResult = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)object];
//        marrSearch = [NSMutableArray arrayWithObject:objResult];
//    }
//    else {
//        return object;
//    }
//    while (marrSearch.count > 0) {
//        NSObject *header = marrSearch[0];
//        if ([header isKindOfClass:NSMutableDictionary.class]) {
//            // 遍历这个字典
//            NSMutableDictionary *mdicTemp = (NSMutableDictionary *)header;
//            for (NSString *strKey in mdicTemp.allKeys) {
//                NSObject *objTemp = mdicTemp[strKey];
//                // 将NSDictionary替换为NSMutableDictionary
//                if ([objTemp isKindOfClass:NSDictionary.class]) {
//                    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)objTemp];
//                    mdicTemp[strKey] = mdic;
//                    [marrSearch addObject:mdic];
//                }
//                // 将NSArray替换为NSMutableArray
//                else if ([objTemp isKindOfClass:NSArray.class]) {
//                    NSMutableArray *marr = [NSMutableArray arrayWithArray:(NSArray *)objTemp];
//                    mdicTemp[strKey] = marr;
//                    [marrSearch addObject:marr];
//                }
//                // 删除NSNull
//                else if ([objTemp isKindOfClass:NSNull.class]) {
//                    mdicTemp[strKey] = nil;
//                }
//            }
//        }
//        else if ([header isKindOfClass:NSMutableArray.class]) {
//            // 遍历这个数组
//            NSMutableArray *marrTemp = (NSMutableArray *)header;
//            for (int i = marrTemp.count-1; i >= 0; i--) {
//                NSObject *objTemp = marrTemp[i];
//                // 将NSDictionary替换为NSMutableDictionary
//                if ([objTemp isKindOfClass:NSDictionary.class]) {
//                    NSMutableDictionary *mdic = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)objTemp];
//                    [marrTemp replaceObjectAtIndex:i withObject:mdic];
//                    [marrSearch addObject:mdic];
//                }
//                // 将NSArray替换为NSMutableArray
//                else if ([objTemp isKindOfClass:NSArray.class]) {
//                    NSMutableArray *marr = [NSMutableArray arrayWithArray:(NSArray *)objTemp];
//                    [marrTemp replaceObjectAtIndex:i withObject:marr];
//                    [marrSearch addObject:marr];
//                }
//                // 删除NSNull
//                else if ([objTemp isKindOfClass:NSNull.class]) {
//                    [marrTemp removeObjectAtIndex:i];
//                }
//            }
//        }
//        else {
//            // 到这里就出错了
//        }
//        [marrSearch removeObjectAtIndex:0];
//    }
//    return objResult;
//}
//
@end
