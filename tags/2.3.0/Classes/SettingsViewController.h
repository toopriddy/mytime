//
//  SettingsViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/13/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <UIKit/UIKit.h>
#import "BackupView.h"
#import "NumberViewControllerDelegate.h"
#import "PublisherTypeViewController.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, 
                                                      UITableViewDataSource,
													  NumberViewControllerDelegate,
													  UIActionSheetDelegate,
													  PublisherTypeViewControllerDelegate> 
{
	UITableView *theTableView;
	BackupView *backupView;
}
@property (nonatomic,retain) UITableView *theTableView;

/**
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id)init;
- (void)dealloc;
@end
