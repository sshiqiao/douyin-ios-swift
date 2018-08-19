//
//  AppDelegate.m
//  TestDemo
//
//  Created by Qiao Shi on 2018/8/16.
//  Copyright © 2018年 Qiao Shi. All rights reserved.
//

#import "AppDelegate.h"
#import "AwemeListController.h"
#import "NSString+Extension.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSDictionary *dic = [NSString readJson2DicWithFileName:@"awemes"];
    NSArray *array = [dic valueForKey:@"data"];
    NSMutableArray *data = [NSMutableArray array];
    [data addObject:@"http://116.62.9.17:8080/examples/2.mp4"];
//    [data addObject:@"https://aweme.snssdk.com/aweme/v1/play/?video_id=v0200ff00000bcv0okld2r6fb5itjj10&line=0&ratio=720p&media_type=4&vr_type=0&test_cdn=None&improve_bitrate=0"];
//    [data addObject:@"http://fxactvideodev.fenxuekeji.com/76917/video/development_d165bd58-8dd0-4b39-a40f-a46f2077b7ea.mp4"];
//    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSDictionary *dic = (NSDictionary *)obj;
//        dic = [dic valueForKey:@"video"];
//        dic = [dic valueForKey:@"play_addr"];
//        NSArray *array = [dic valueForKey:@"url_list"];
//        [data addObject:array.firstObject];
//    }];
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [[AwemeListController alloc] initWithVideoData:data currentIndex:0 pageIndex:0 pageSize:20];
    [self.window makeKeyAndVisible];    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
