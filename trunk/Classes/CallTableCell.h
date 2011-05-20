//
//  CallTableCell.h
//  MyTime
//
//  Created by Brent Priddy on 7/6/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MTCall.h"

@interface CallTableCell : UITableViewCell {
	MTCall *call;
	UILabel *mainLabel;
	UILabel *secondaryLabel;
	UILabel *infoLabel;
	BOOL _nameAsMainLabel;
}

@property (nonatomic, retain) MTCall *call;
@property (nonatomic, retain) UILabel *mainLabel;
@property (nonatomic, retain) UILabel *secondaryLabel;
@property (nonatomic, retain) UILabel *infoLabel;

+ (float)height;

- (void)useNameAsMainLabel;
- (void)useStreetAsMainLabel;

@end
