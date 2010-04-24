//
//  NotAtHomeHouseCell.h
//
//  Created by Brent Priddy on 1/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class NotAtHomeHouseCell;

@protocol NotAtHomeHouseCellDelegate
- (void)notAtHomeHouseCellAttemptsChanged:(NotAtHomeHouseCell *)cell;
@end

@interface NotAtHomeHouseCell : UITableViewCell 
{
	UILabel *countLabel;
	UILabel *houseLabel;
	NSObject<NotAtHomeHouseCellDelegate> *delegate;
	int attempts;
}
@property (nonatomic, retain) IBOutlet UILabel *countLabel;
@property (nonatomic, retain) IBOutlet UILabel *houseLabel;
@property (nonatomic, assign) NSObject<NotAtHomeHouseCellDelegate> *delegate;
@property (nonatomic, assign) int attempts;

- (IBAction)addPressed;
- (IBAction)subtractPressed;

@end
