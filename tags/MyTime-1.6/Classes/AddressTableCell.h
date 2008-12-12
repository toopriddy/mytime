//
//  AddressTableCell.h
//  MyTime
//
//  Created by Brent Priddy on 10/6/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AddressTableCell : UITableViewCell {
	UILabel *topLabel;
	UILabel *bottomLabel;
}

@property (nonatomic,retain) UILabel *topLabel;
@property (nonatomic,retain) UILabel *bottomLabel;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setStreetNumber:(NSString *)streetNumber apartment:(NSString *)apartment street:(NSString *)street city:(NSString *)city state:(NSString *)state;

@end
