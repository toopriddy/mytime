//
//  PSSegmentedControlCellController.h
//  MyTime
//
//  Created by Brent Priddy on 2/1/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSBaseCellController.h"
#import "UITableViewSegmentedControlCell.h"

@interface PSSegmentedControlCellController : PSBaseCellController<UITableViewSegmentedControlCellDelegate>
{
}
@property (nonatomic, retain) NSArray *segmentedControlValues;
@property (nonatomic, retain) NSArray *segmentedControlTitles;
@end
