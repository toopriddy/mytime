//
//  MapViewCellDetailController.h
//  MyTime
//
//  Created by Brent Priddy on 8/30/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class MapViewCallDetailController;

@protocol MapViewCallDetailControllerDelegate
@required
- (void) mapViewCallDetailControllerSelected:(MapViewCallDetailController *)mapViewCallDetailController;
- (void) mapViewCallDetailControllerCanceled:(MapViewCallDetailController *)mapViewCallDetailController;
@end

@interface MapViewCallDetailController : UIViewController 
{
@private
    IBOutlet UILabel *address;
    IBOutlet UILabel *info;
    IBOutlet UILabel *name;

	NSMutableDictionary *call;
	NSObject<MapViewCallDetailControllerDelegate> *delegate;
}
@property (nonatomic, assign, setter=setCall:, getter=call) NSMutableDictionary *call;
@property (nonatomic, assign) NSObject<MapViewCallDetailControllerDelegate> *delegate;

- (IBAction)callDetailSelected;
- (IBAction)cancelSelected;

- (void)setCall:(NSMutableDictionary *)theCall;
- (NSMutableDictionary *)call;

@end
