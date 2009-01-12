//
//  CallTableCell.h
//  MyTime
//
//  Created by Brent Priddy on 7/6/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CallTableCell : UITableViewCell {
	NSMutableDictionary *call;
	UILabel *mainLabel;
	UILabel *secondaryLabel;
	UILabel *infoLabel;
	BOOL _nameAsMainLabel;
}

@property (nonatomic,retain) NSMutableDictionary *call;
@property (nonatomic,retain) UILabel *mainLabel;
@property (nonatomic,retain) UILabel *secondaryLabel;
@property (nonatomic,retain) UILabel *infoLabel;

+ (float)height;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;

- (void)setCall:(NSMutableDictionary *)call;

- (void)useNameAsMainLabel;
- (void)useStreetAsMainLabel;

@end
