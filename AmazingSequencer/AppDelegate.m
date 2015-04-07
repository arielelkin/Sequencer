//
//  AppDelegate.m
//  The Amazing Audio Engine
//
//  Created by Ariel Elkin on 26/03/2014.
//  Copyright (c) 2014 Ariel Elkin. All rights reserved.
//

#import "AppDelegate.h"
#import "WelcomeVC.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    WelcomeVC *vc = [WelcomeVC new];
    [self.window setRootViewController:vc];

    return YES;
}

@end
