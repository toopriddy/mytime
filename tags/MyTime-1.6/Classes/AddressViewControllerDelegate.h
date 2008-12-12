//
//  AddressViewControllerDelegate.h
//  MyTime
//
//  Created by Brent Priddy on 8/10/08.
//  Copyright 2008 PG Software. All rights reserved.
//

@class AddressViewController;

@protocol AddressViewControllerDelegate<NSObject>

@required

- (void)addressViewControllerDone:(AddressViewController *)publicationViewController;

@end
