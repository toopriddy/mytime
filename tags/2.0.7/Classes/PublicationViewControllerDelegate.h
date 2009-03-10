//
//  PublicationViewDelegate.h
//  MyTime
//
//  Created by Brent Priddy on 8/10/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//


@class PublicationViewController;

@protocol PublicationViewControllerDelegate<NSObject>

@required

- (void)publicationViewControllerDone:(PublicationViewController *)publicationViewController;

@end