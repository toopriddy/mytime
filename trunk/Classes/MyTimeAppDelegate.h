//
//  MyTimeAppDelegate.h
//  MyTime
//
//  Created by Brent Priddy on 7/22/08.
//  Copyright PG Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	ADD_CALL,
	RESTORE_BACKUP
} UrlActionType;

@class MyTimeViewController;

@interface MyTimeAppDelegate : NSObject <UIApplicationDelegate, 
                                         UITabBarControllerDelegate,
										 UIActionSheetDelegate> 
{
	UIWindow *window;
	UITabBarController *tabBarController;
	NSMutableDictionary *callToImport;
	NSMutableDictionary *settingsToRestore;
	UrlActionType _actionSheetType;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) NSMutableDictionary *callToImport;
@property (nonatomic, retain) NSMutableDictionary *settingsToRestore;

@end

