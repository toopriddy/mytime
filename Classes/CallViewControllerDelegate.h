//
//  CallViewControllerDelegate.h
//  MyTime
//
//  Created by Brent Priddy on 8/13/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//



@class CallViewController;

@protocol CallViewControllerDelegate<NSObject>

@required

- (void)callViewController:(CallViewController *)callViewController deleteCall:(NSMutableDictionary *)call keepInformation:(BOOL)keepInformation;

- (void)callViewController:(CallViewController *)callViewController saveCall:(NSMutableDictionary *)call;

@end
