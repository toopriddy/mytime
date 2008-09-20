//
//  CallTableCell.h
//  MyTime
//
//  Created by Brent Priddy on 7/6/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CallTableCell : UITableViewCell {
	NSMutableDictionary *call;
	UILabel *streetLabel;
	UILabel *nameLabel;
	UILabel *infoLabel;
}

@property (nonatomic,retain) NSMutableDictionary *call;
@property (nonatomic,retain) UILabel *streetLabel;
@property (nonatomic,retain) UILabel *nameLabel;
@property (nonatomic,retain) UILabel *infoLabel;

+ (float)height;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setCall:(NSMutableDictionary *)call;

@end
