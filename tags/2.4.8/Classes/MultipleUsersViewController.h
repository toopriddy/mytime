//
//  MultipleUsersViewController.h
//  MyTime
//
//  Created by Brent Priddy on 6/12/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GenericTableViewController.h"

@interface MultipleUsersViewController : GenericTableViewController <UIActionSheetDelegate>
{
}
- (BOOL)renameUser:(int)index toName:(NSString *)newName;
- (BOOL)addUser:(NSString *)name;
- (void)deleteUser:(int)index;
- (void)changeToUser:(int)index;
@end
