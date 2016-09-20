//
//  AppDelegate.m
//  ABBVideoDownloadPlayer
//
//  Created by beyondsoft-聂小波 on 16/9/13.
//  Copyright © 2016年 NieXiaobo. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <WHCNetWorkKit/WHC_HttpManager.h>
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _window.rootViewController = [[UINavigationController alloc]initWithRootViewController:[ViewController new]];
    [_window makeKeyAndVisible];
    
    //UIApplicationBackgroundFetchIntervalMinimum表示尽可能频繁去获取，如果需要指定至少多少时间更新一次就需要给定一个时间值
    [application setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    [[WHC_HttpManager shared] registerNetworkStatusMoniterEvent];
    
    return YES;
    
}

//File: YourAppDelegate.m
//-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
//{
//    UINavigationController *navigationController = (UINavigationController*)self.window.rootViewController;
//    
//    completionHandler(UIBackgroundFetchResultNewData);
//    
//    for (WHC_OffLineVideoVC *videoVC in navigationController.childViewControllers) {
//        
//        
//        if ([videoVC isKindOfClass:[WHC_OffLineVideoVC class]]) {
//            
//            
//            
//            [videoVC fetchDataResult];
//        }
//        
//    }
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
