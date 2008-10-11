//
//  NumberViewControllerDelegate.h
//  MyTime
//
//  Created by Brent Priddy on 10/11/08.
//  Copyright 2008 PG Software. All rights reserved.
//

@class NumberViewController;

@protocol NumberViewControllerDelegate<NSObject>

@required

- (void)numberViewControllerDone:(NumberViewController *)numberViewController;

@end
