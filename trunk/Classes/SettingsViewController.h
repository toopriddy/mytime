//
//  SettingsViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/13/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BackupView.h"
#import "NumberViewControllerDelegate.h"

@interface SettingsViewController : UIViewController <UITableViewDelegate, 
                                                      UITableViewDataSource,
													  NumberViewControllerDelegate,
													  UIActionSheetDelegate> 
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
