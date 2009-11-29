//
//  UITableViewTitleAndValueCell.h
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UITableViewTitleAndValueCell : UITableViewCell {
	UILabel *titleLabel;
	UILabel *valueLabel;
}

@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *valueLabel;

- (void)setTitle:(NSString *)title;
- (void)setValue:(NSString *)value;

@end

