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
#import <CoreData/CoreData.h>

// for moving around the UITableViewIndex
static BOOL tableViewIndexMoveIn(id self, SEL _cmd);
static BOOL tableViewIndexMoveOut(id self, SEL _cmd);

typedef enum {
	NORMAL_STARTUP = 0,
	ADD_CALL,
	RESTORE_BACKUP,
	AUTO_BACKUP,
	ADD_NOT_AT_HOME_TERRITORY
} UrlActionType;
@class MyTimeViewController;

@interface MyTimeAppDelegate : NSObject <UIApplicationDelegate, 
                                         UITabBarControllerDelegate,
										 UIActionSheetDelegate,
										 SecurityViewControllerDelegate,
										 MFMailComposeViewControllerDelegate,
										 UINavigationControllerDelegate,
                                         UIAlertViewDelegate> 
{
	UIWindow *window;
	UITabBarController *tabBarController;
	NSMutableDictionary *dataToImport;
	NSMutableDictionary *settingsToRestore;
	UINavigationController *modalNavigationController;
	UrlActionType _actionSheetType;
	BOOL forceEmail;
@private
    NSManagedObjectContext *managedObjectContext_;
    NSManagedObjectModel *managedObjectModel_;
    NSPersistentStoreCoordinator *persistentStoreCoordinator_;
}	
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UITabBarController *tabBarController;
@property (nonatomic, retain) NSMutableDictionary *dataToImport;
@property (nonatomic, retain) NSMutableDictionary *settingsToRestore;
@property (nonatomic, retain) UINavigationController *modalNavigationController;

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSString *)applicationDocumentsDirectory;

- (void)initializeMyTimeViews;

+ (MyTimeAppDelegate *)sharedInstance;

@end

