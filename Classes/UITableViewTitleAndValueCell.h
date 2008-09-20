//
//  UITableViewTitleAndValueCell.h
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 PG Software. All rights reserved.
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

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

@end

