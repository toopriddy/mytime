//
//  NotAtHomeHouseCell.h
//
//  Created by Brent Priddy on 1/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
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
