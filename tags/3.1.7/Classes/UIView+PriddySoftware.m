//
//  UIView+PriddySoftware.m
//  MyTime
//
//  Created by Brent Priddy on 8/8/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "UIView+PriddySoftware.h"

@implementation UIView (PriddySoftwareFindAndResignFirstResponder)
- (BOOL)findAndResignFirstResponder
{
    if (self.isFirstResponder) 
	{
        [self resignFirstResponder];
        return YES;     
    }
    for (UIView *subView in self.subviews) 
	{
        if ([subView findAndResignFirstResponder])
            return YES;
    }
    return NO;
}
@end
