//
//  UITableViewMultilineTextCell.h
//  MyTime
//
//  Created by Brent Priddy on 9/20/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UITableViewMultilineTextCell : UITableViewCell <UITextViewDelegate> {
	UILabel *textView;
}

@property (nonatomic, retain) UILabel *textView;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setText:(NSString *)text;
+ (CGFloat)heightForWidth:(CGFloat)width withText:(NSString *)text;

@end
