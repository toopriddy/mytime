//
//  SettingsTableViewController.h
//  MyTime
//
//  Created by Brent Priddy on 9/18/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "GenericTableViewController.h"

@interface SettingsTableViewController : GenericTableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate>
{
}

@end
