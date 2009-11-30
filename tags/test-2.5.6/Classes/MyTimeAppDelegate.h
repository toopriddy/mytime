//
//  MyTimeAppDelegate.h
//  MyTime
//
//  Created by Brent Priddy on 7/22/08.
//  Copyright Priddy Software, LLC 2008. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "SecurityViewController.h"

// for moving around the UITableViewIndex
static BOOL tableViewIndexMoveIn(id self, SEL _cmd);
static BOOL tableViewIndexMoveOut(id self, SEL _cmd);

typedef enum {
	ADD_CALL,
	RESTORE_BACKUP
} UrlActionType;

@class MyTimeViewController;

@interface MyTimeAppDelegate : NSObject <UIApplicationDelegate, 
                                         UITabBarControllerDelegate,
										 UIActionSheetDelegate,
										 SecurityViewControllerDelegate,
										 MFMailComposeViewControllerDelegate> 
{
	UIWindow *window;
	UITabBarController *tabBarController;
	NSMutableDictionary *callToImport;
	NSMutableDictionary *settingsToRestore;
	UINavigationController *securityNavigationController;
	UrlActionType _actionSheetType;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) NSMutableDictionary *callToImport;
@property (nonatomic, retain) NSMutableDictionary *settingsToRestore;
@property (nonatomic, retain) UINavigationController *securityNavigationController;

+ (MyTimeAppDelegate *)sharedInstance;

@end

