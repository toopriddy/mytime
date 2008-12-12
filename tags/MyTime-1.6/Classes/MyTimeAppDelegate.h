//
//  MyTimeAppDelegate.h
//  MyTime
//
//  Created by Brent Priddy on 7/22/08.
//  Copyright PG Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyTimeViewController;

@interface MyTimeAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
	UIWindow *window;
	UITabBarController *tabBarController;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;

@end

