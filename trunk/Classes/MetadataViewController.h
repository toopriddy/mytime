//
//  MetadataViewController.h
//  MyTime
//
//  Created by Brent Priddy on 10/22/08.
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
#import "MetadataCustomViewController.h"
#import "MTAdditionalInformationType.h"

@class MetadataViewController;

@protocol MetadataViewControllerDelegate<NSObject>
@required
- (void)metadataViewControllerAdd:(MetadataViewController *)metadataViewController metadata:(MTAdditionalInformationType *)metadata;
- (void)metadataViewControllerAddPreferredMetadata:(MetadataViewController *)metadataViewController metadata:(MTAdditionalInformationType *)metadata;
- (void)metadataViewControllerRemoveMetadata:(MetadataViewController *)metadataViewController metadata:(MTAdditionalInformationType *)metadata;
@end

#import "GenericTableViewController.h"

@interface MetadataViewController : GenericTableViewController
{
	id<MetadataViewControllerDelegate> delegate;
}
@property (nonatomic,assign) id<MetadataViewControllerDelegate> delegate;

+ (NSArray *)metadataNames;
+ (void)DONOTUSEfixMetadataForUserDONOTUSE:(NSMutableDictionary *)user;

/**
 * initialize this view with the address information
 *
 * @param rect - the rect
 * @returns self
 */
- (id) init;
@end


