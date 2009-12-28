//
//  MultipleUsersViewController.h
//  MyTime
//
//  Created by Brent Priddy on 6/12/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericTableViewController.h"

@class MultipleUsersViewController;

@protocol MultipleUsersViewControllerDelegate
- (void) multipleUsersViewController:(MultipleUsersViewController *)viewController selectedUser:(NSString *)name;
@end

@interface MultipleUsersViewController : GenericTableViewController <UIActionSheetDelegate>
{
	id<NSObject, MultipleUsersViewControllerDelegate> delegate;
}
@property (nonatomic, assign) id<NSObject, MultipleUsersViewControllerDelegate> delegate;

- (BOOL)renameUser:(int)index toName:(NSString *)newName;
- (BOOL)addUser:(NSString *)name;
- (void)deleteUser:(int)index;
- (void)changeToUser:(int)index;
@end
