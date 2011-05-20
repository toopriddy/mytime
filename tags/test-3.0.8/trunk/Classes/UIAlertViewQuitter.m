//
//  UIAlertViewQuitter.m
//  MyTime
//
//  Created by Brent Priddy on 1/11/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "UIAlertViewQuitter.h"


@implementation UIAlertViewQuitter
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	exit(0);
}
@end


