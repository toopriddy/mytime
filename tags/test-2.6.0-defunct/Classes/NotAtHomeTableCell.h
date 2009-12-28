//
//  NotAtHomeTableCell.h
//
//  Created by Brent Priddy on 10/14/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class NotAtHomeTableCell;

@protocol NotAtHomeTableCellDelegate<NSObject>
@required
- (void)notAtHomeTableCellAttemptsChanged:(NotAtHomeTableCell *)notAtHomeTableCell;
@end



@interface NotAtHomeTableCell : UITableViewCell 
{
@private
	UILabel *houseNumber;
	id<NotAtHomeTableCellDelegate> delegate;
	UISegmentedControl *attempts;
}

@property (nonatomic, assign) id<NotAtHomeTableCellDelegate> delegate;
@property (nonatomic, assign) IBOutlet UISegmentedControl *attempts;
@property (nonatomic, assign) IBOutlet UILabel *houseNumber;

- (IBAction)valueChanged;

	
@end
